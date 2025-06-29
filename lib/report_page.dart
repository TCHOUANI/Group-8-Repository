 // lib/report_page.dart (Modified)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:record/record.dart'; // Ensure this import is correct
import 'alert_firebase_service.dart';
import 'package:flutter_application_1/models/enums.dart'; // Assuming your enums/RoadAlert are here
import 'package:just_audio/just_audio.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  AlertType? _selectedAlertType;
  AlertSeverity? _selectedAlertSeverity = AlertSeverity.medium; // Default to medium

  bool _isRecording = false;
  String? _audioPath;
  // Use AudioRecorder from the record package
  final AudioRecorder _audioRecorder = AudioRecorder(); // Correct instantiation

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _audioRecorder.dispose(); // Correct dispose method call
    super.dispose();
  }

  Future<void> _recordAudio() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory appTemporaryDir = await getTemporaryDirectory();
        final String filePath = '${appTemporaryDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc), // Use RecordConfig
          path: filePath,
        ); // Correct start method call

        setState(() {
          _isRecording = true;
          _audioPath = filePath;
        });
        print('[_recordAudio] Recording started to path: $_audioPath');
      } else {
        _showSnackBar('Microphone permission denied.', Colors.red);
        print('[_recordAudio] Microphone permission denied.');
      }
    } catch (e) {
      print('[_recordAudio] Error starting recording: $e');
      _showSnackBar('Failed to start recording: $e', Colors.red);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop(); // Correct stop method call
      if (path != null) {
        setState(() {
          _isRecording = false;
          _audioPath = path;
        });
        print('[_stopRecording] Recording stopped. File path: $_audioPath');
        _showSnackBar('Recording stopped. Path: $_audioPath', Colors.green);
      } else {
        _showSnackBar('Failed to stop recording.', Colors.red);
        print('[_stopRecording] Failed to stop recording, path is null.');
      }
    } catch (e) {
      print('[_stopRecording] Error stopping recording: $e');
      _showSnackBar('Failed to stop recording: $e', Colors.red);
    }
  }

  Future<String?> _uploadAudioToFirebase(String filePath) async {
    print('[_uploadAudioToFirebase] Attempting to upload file from path: $filePath');
    try {
      File audioFile = File(filePath);
      if (!await audioFile.exists()) {
        print('[_uploadAudioToFirebase] ERROR: Audio file does not exist at $filePath');
        _showSnackBar('Audio file does not exist.', Colors.red);
        return null;
      }

      final String fileName = 'voice_notes/${DateTime.now().millisecondsSinceEpoch}.m4a';
      print('[_uploadAudioToFirebase] Uploading with file name: $fileName');
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      final UploadTask uploadTask = storageRef.putFile(audioFile);
      
      // Listen for state changes, errors, and completion
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload Task state: ${snapshot.state}, Bytes transferred: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });

      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        print('[_uploadAudioToFirebase] Voice note uploaded successfully! Download URL: $downloadUrl');
        _showSnackBar('Voice note uploaded successfully!', Colors.green);
        return downloadUrl;
      } else {
        print('[_uploadAudioToFirebase] ERROR: Voice note upload failed with state: ${snapshot.state}');
        _showSnackBar('Failed to upload voice note: Upload state: ${snapshot.state}', Colors.red);
        return null;
      }
    } catch (e) {
      print('[_uploadAudioToFirebase] CATCH ERROR: Error uploading audio to Firebase Storage: $e');
      _showSnackBar('Failed to upload voice note: $e', Colors.red);
      return null;
    }
  }

  Future<void> _submitAlert() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedAlertType == null) {
      _showSnackBar('Please select an alert type.', Colors.red);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      Position? currentPosition;
      try {
        currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        print('[_submitAlert] Current location: ${currentPosition.latitude}, ${currentPosition.longitude}');
      } catch (e) {
        _showSnackBar('Could not get current location. Please enable location services.', Colors.orange);
        print('[_submitAlert] Location error: $e');
        // Continue without location if it's not critical, or return if it is.
        // For this example, we'll allow submitting without precise location.
      }

      String? voiceNoteUrl;
      if (_audioPath != null) {
        print('[_submitAlert] _audioPath is not null, attempting to upload voice note.');
        voiceNoteUrl = await _uploadAudioToFirebase(_audioPath!);
        if (voiceNoteUrl == null) {
          _showSnackBar('Voice note upload failed. Alert not submitted.', Colors.red);
          setState(() {
            _isSubmitting = false; // Stop submission if voice note fails to upload
          });
          return; // Stop here if voice note upload failed
        }
      } else {
        print('[_submitAlert] No audio path to upload for voice note.');
      }

      final newAlert = RoadAlert(
        id: FirebaseFirestore.instance.collection('alerts').doc().id, // Generate a new ID
        type: _selectedAlertType!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        latitude: currentPosition?.latitude,
        longitude: currentPosition?.longitude,
        timestamp: DateTime.now(),
        severity: _selectedAlertSeverity!,
        isActive: true, // Explicitly set isActive to true
        isSystemGenerated: false,
        voiceNoteUrl: voiceNoteUrl, // Pass the voice note URL to the alert
      );

      print('[_submitAlert] Attempting to add alert to Firestore: ${newAlert.title}');
      await AlertFirebaseService().addAlert(newAlert);
      print('[_submitAlert] Alert successfully added to Firestore.');


      _showSnackBar('Alert reported successfully!', Colors.green);
      _formKey.currentState!.reset(); // Clear form fields
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _selectedAlertType = null;
        _selectedAlertSeverity = AlertSeverity.medium;
        _audioPath = null;
        _isRecording = false;
      });
      Navigator.of(context).pop(); // Go back to the previous page
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to report alert: $e';
      });
      print('[_submitAlert] Submission error: $_errorMessage');
      _showSnackBar('Failed to report alert: $_errorMessage', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper to get title based on AlertType for Dropdown
  String _getAlertTitle(AlertType type) {
    switch (type) {
      case AlertType.pothole:
        return 'Pothole';
      case AlertType.accident:
        return 'Accident';
      case AlertType.roadblock:
        return 'Roadblock';
      case AlertType.construction:
        return 'Construction';
      case AlertType.traffic:
        return 'Traffic';
      case AlertType.weather:
        return 'Weather';
      case AlertType.roadClosure:
        return 'Road Closure';
      case AlertType.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report New Alert'),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Alert Title',
                        hintText: 'e.g., Large pothole near city center',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title for the alert.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'e.g., It\'s about 2 feet wide and 6 inches deep.',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g., Main Street, Buea',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the location of the alert.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AlertType>(
                      value: _selectedAlertType,
                      decoration: const InputDecoration(
                        labelText: 'Alert Type',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select Alert Type'),
                      items: AlertType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getAlertTitle(type)),
                        );
                      }).toList(),
                      onChanged: (type) {
                        setState(() {
                          _selectedAlertType = type;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an alert type.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<AlertSeverity>(
                      value: _selectedAlertSeverity,
                      decoration: const InputDecoration(
                        labelText: 'Alert Severity',
                        border: OutlineInputBorder(),
                      ),
                      items: AlertSeverity.values.map((severity) {
                        return DropdownMenuItem(
                          value: severity,
                          child: Text(severity.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (severity) {
                        setState(() {
                          _selectedAlertSeverity = severity;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Voice Note (Optional):', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isRecording ? _stopRecording : _recordAudio,
                            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                            label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRecording ? Colors.red : Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        if (_audioPath != null && !_isRecording) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _audioPath = null;
                              });
                              _showSnackBar('Voice note cleared.', Colors.grey);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Optional: Add a play button for recorded audio before submitting
                          IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.blue),
                            onPressed: () async {
                              if (_audioPath != null) {
                                final AudioPlayer localPlayer = AudioPlayer();
                                try {
                                  await localPlayer.setFilePath(_audioPath!);
                                  await localPlayer.play();
                                  _showSnackBar('Playing recorded note...', Colors.blue);
                                  localPlayer.playerStateStream.listen((state) {
                                    if (state.processingState == ProcessingState.completed) {
                                      localPlayer.dispose();
                                    }
                                  });
                                } catch (e) {
                                  _showSnackBar('Error playing recorded note: $e', Colors.red);
                                  localPlayer.dispose();
                                }
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                    if (_audioPath != null && !_isRecording)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Recorded: ${(_audioPath!).split('/').last}',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitAlert,
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'Report Alert',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
