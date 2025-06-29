// lib/live_road_alert_page.dart (Updated with Accelerometer)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'alert_firebase_service.dart';
import 'package:flutter_application_1/models/enums.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Import the sensors_plus package
import 'dart:math' as math; // For math functions like .abs()
import 'report_page.dart';

class LiveRoadAlertsPage extends StatefulWidget {
  const LiveRoadAlertsPage({Key? key}) : super(key: key);

  @override
  State<LiveRoadAlertsPage> createState() => _LiveRoadAlertsPageState();
}

class _LiveRoadAlertsPageState extends State<LiveRoadAlertsPage>
    with TickerProviderStateMixin {
  final AlertFirebaseService _alertService = AlertFirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RoadAlert> _alerts = [];
  List<RoadAlert> _filteredAlerts = [];
  List<String> _newAlertIds = [];
  AlertType? _selectedFilter;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _notificationController;
  late Animation<double> _notificationAnimation;

  // Location tracking variables for the driver
  double? _currentDriverLatitude;
  double? _currentDriverLongitude;
  StreamSubscription<Position>? _positionStreamSubscription;
  Set<String> _notifiedAlerts = {};
  static const double PROXIMITY_THRESHOLD_METERS = 100.0;

  // Audio players for voice notes and proximity alerts
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _proximityAudioPlayer = AudioPlayer();
  String? _playingVoiceNoteId;
  final Set<String> _proximityAlertTriggered = {};
  final Set<String> _voiceNotePlayedAutomatically = {};

  // ACCELEROMETER RELATED VARIABLES
  StreamSubscription? _accelerometerSubscription;
  static const double ACCELERATION_THRESHOLD = 5.0; // Adjust this value based on testing (m/s^2)
  static const Duration DEBOUNCE_DURATION = Duration(seconds: 3); // Time to ignore new impacts after one is detected
  DateTime? _lastPotholeDetectionTime; // To implement debouncing

  @override
  void initState() {
    super.initState();
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _notificationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _notificationController,
        curve: Curves.elasticOut,
      ),
    );
    _loadAlerts();
    _listenToAlerts();
    _startDriverLocationTracking();
    _startAccelerometerListening(); // Start listening to accelerometer

    // Listen for completion of the voice note player
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        setState(() {
          _playingVoiceNoteId = null; // Reset playing state when audio finishes
        });
        _showSnackBar('Voice note finished.', Colors.green);
      }
    });
  }

  @override
  void dispose() {
    // _titleController.dispose(); // These controllers are not in this page
    // _descriptionController.dispose(); // These controllers are not in this page
    // _locationController.dispose(); // These controllers are not in this page
    _notificationController.dispose();
    _positionStreamSubscription?.cancel();
    _accelerometerSubscription?.cancel(); // Dispose accelerometer subscription
    _audioPlayer.dispose();
    _proximityAudioPlayer.dispose();
    super.dispose();
  }

  // --- ACCELEROMETER LISTENING AND DETECTION LOGIC ---
  void _startAccelerometerListening() {
    print('[Accelerometer] Starting accelerometer listener.');
    _accelerometerSubscription = userAccelerometerEventStream(samplingPeriod: SensorInterval.normalInterval).listen(
      (UserAccelerometerEvent event) {
        // We are primarily interested in the Z-axis (vertical) acceleration for potholes.
        // The value represents acceleration minus gravity.
        final double zAcceleration = event.z;

        // print('Accelerometer Z-axis: $zAcceleration'); // Uncomment for raw data debugging

        // Basic pothole detection logic: look for sharp spikes in Z-axis
        // Consider both positive and negative spikes for up/down motion
        if (zAcceleration.abs() > ACCELERATION_THRESHOLD) {
          // Implement debouncing to avoid multiple detections for a single event
          if (_lastPotholeDetectionTime == null ||
              DateTime.now().difference(_lastPotholeDetectionTime!) > DEBOUNCE_DURATION) {
            
            _lastPotholeDetectionTime = DateTime.now();
            print('[Accelerometer] Potential pothole detected! Z-accel: $zAcceleration');
            _reportAutomatedPothole(zAcceleration.abs()); // Report the pothole
          }
        }
      },
      onError: (e) {
        print('[Accelerometer] Error getting accelerometer data: $e');
        _showSnackBar('Error getting accelerometer data: $e', Colors.red);
      },
      onDone: () {
        print('[Accelerometer] Accelerometer stream finished.');
      },
    );
  }

  Future<void> _reportAutomatedPothole(double magnitude) async {
    // Only report if location is available
    if (_currentDriverLatitude == null || _currentDriverLongitude == null) {
      print('[Accelerometer] Cannot report automated pothole: Location not available.');
      return;
    }

    // You might want to reverse geocode the location for a more descriptive string
    // This is a placeholder for now.
    String detectedLocation = 'Lat: ${_currentDriverLatitude!.toStringAsFixed(4)}, Lon: ${_currentDriverLongitude!.toStringAsFixed(4)}';

    // Determine severity based on magnitude (simple example)
    AlertSeverity detectedSeverity = AlertSeverity.medium;
    if (magnitude > ACCELERATION_THRESHOLD * 1.5) { // e.g., 1.5x threshold for high
      detectedSeverity = AlertSeverity.high;
    } else if (magnitude < ACCELERATION_THRESHOLD * 0.8) { // e.g., 0.8x threshold for low
      detectedSeverity = AlertSeverity.low;
    }

    final automatedAlert = RoadAlert(
      id: FirebaseFirestore.instance.collection('alerts').doc().id,
      type: AlertType.pothole, // Assuming accelerometer primarily detects potholes
      title: 'Automated Pothole Detection (Magnitude: ${magnitude.toStringAsFixed(2)} m/s²)',
      description: 'Detected by device accelerometer. Possible road imperfection.',
      location: detectedLocation,
      latitude: _currentDriverLatitude,
      longitude: _currentDriverLongitude,
      severity: detectedSeverity,
      isActive: true,
      timestamp: DateTime.now(),
      isSystemGenerated: true, // Mark as system-generated
      voiceNoteUrl: null, // No voice note for automated reports
    );

    try {
      print('[Accelerometer] Reporting automated pothole: ${automatedAlert.title} at ${automatedAlert.location}');
      await _alertService.addAlert(automatedAlert);
      _showSnackBar('Potential pothole detected and reported automatically!', Colors.blue);
    } catch (e) {
      print('[Accelerometer] Error reporting automated pothole: $e');
      _showSnackBar('Failed to report automated pothole: $e', Colors.red);
    }
  }
  // --- END ACCELEROMETER RELATED LOGIC ---


  void _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final alerts = await _alertService.getActiveAlerts();
      setState(() {
        _alerts = alerts;
        _filteredAlerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load alerts: $e';
        _isLoading = false;
      });
    }
  }

  void _listenToAlerts() {
    _alertService.getActiveAlertsStream().listen(
      (alerts) {
        List<String> currentAlertIds = _alerts.map((alert) => alert.id).toList();
        List<RoadAlert> newlyAddedAlerts = alerts
            .where((alert) => !currentAlertIds.contains(alert.id))
            .toList();

        if (newlyAddedAlerts.isNotEmpty) {
          _showNewAlertNotification(newlyAddedAlerts);
          _newAlertIds.addAll(newlyAddedAlerts.map((alert) => alert.id));
          for (var alert in newlyAddedAlerts) {
            if (alert.voiceNoteUrl != null &&
                alert.voiceNoteUrl!.isNotEmpty &&
                !_voiceNotePlayedAutomatically.contains(alert.id)) {
              _playVoiceNoteAutomatically(alert);
              _voiceNotePlayedAutomatically.add(alert.id);
              break;
            }
          }
        }

        setState(() {
          _alerts = alerts;
          _applyCurrentFilter();
        });
        _checkProximityToAlerts();
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Real-time updates failed: $error';
        });
      },
    );
  }

  Future<void> _startDriverLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled. Enable for proximity alerts.', Colors.orange);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions denied. Proximity alerts limited.', Colors.red);
        return;
      }
    }
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (Position position) {
        setState(() {
          _currentDriverLatitude = position.latitude;
          _currentDriverLongitude = position.longitude;
        });
        _checkProximityToAlerts();
      },
      onError: (e) {
        print('Error getting driver location stream: $e');
        _showSnackBar('Error tracking location for proximity alerts.', Colors.red);
      },
    );
  }

  void _checkProximityToAlerts() {
    if (_currentDriverLatitude == null || _currentDriverLongitude == null) {
      return;
    }

    final Set<String> currentProximityAlerts = {};

    for (var alert in _filteredAlerts) {
      if (alert.latitude != null && alert.longitude != null) {
        double distance = Geolocator.distanceBetween(
          _currentDriverLatitude!,
          _currentDriverLongitude!,
          alert.latitude!,
          alert.longitude!,
        );

        if (distance <= PROXIMITY_THRESHOLD_METERS) {
          currentProximityAlerts.add(alert.id);

          if (!_proximityAlertTriggered.contains(alert.id)) {
            _showProximityAlertNotification(alert, distance);
            _proximityAlertTriggered.add(alert.id);

            if (alert.voiceNoteUrl != null &&
                alert.voiceNoteUrl!.isNotEmpty &&
                !_voiceNotePlayedAutomatically.contains(alert.id)) {
              _playVoiceNoteAutomatically(alert);
              _voiceNotePlayedAutomatically.add(alert.id);
            }
          }
        }
      }
    }

    _proximityAlertTriggered.retainWhere((alertId) => currentProximityAlerts.contains(alertId));

    setState(() {
      // Re-render cards based on current proximity
    });
  }

  Future<void> _showProximityAlertNotification(RoadAlert alert, double distance) async {
    try {
      await _proximityAudioPlayer.setAsset('assets/sounds/proximity_alert.mp3');
      _proximityAudioPlayer.play();
    } catch (e) {
      print("Error playing proximity sound: $e");
    }

    await HapticFeedback.vibrate();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getAlertIcon(alert.type), color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ALERT! ${_getAlertTitle(alert.type)} nearby (${alert.location}). Distance: ${distance.toStringAsFixed(0)}m',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNewAlertNotification(List<RoadAlert> newAlerts) {
    _notificationController.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _notificationController.reverse();
        }
      });
    });

    String message = newAlerts.length == 1
        ? 'New ${_getAlertTitle(newAlerts.first.type).toLowerCase()} reported nearby!'
        : '${newAlerts.length} new alerts reported nearby!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.new_releases, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _scrollToNewAlerts();
              },
              child: const Text('VIEW', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToNewAlerts() {
    print('Scrolling to new alerts: $_newAlertIds');
    setState(() {
      _selectedFilter = null;
    });
  }

  void _applyCurrentFilter() {
    setState(() {
      if (_selectedFilter == null) {
        _filteredAlerts = _alerts;
      } else {
        _filteredAlerts = _alerts.where((alert) => alert.type == _selectedFilter).toList();
      }
    });
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

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.pothole:
        return Icons.warning;
      case AlertType.accident:
        return Icons.car_crash;
      case AlertType.roadblock:
        return Icons.block;
      case AlertType.construction:
        return Icons.construction;
      case AlertType.traffic:
        return Icons.traffic;
      case AlertType.weather:
        return Icons.cloud;
      case AlertType.roadClosure:
        return Icons.do_not_disturb_on;
      case AlertType.other:
        return Icons.info;
    }
  }

  String _getAlertTitle(AlertType type) {
    switch (type) {
      case AlertType.pothole:
        return 'Pothole Alert';
      case AlertType.accident:
        return 'Accident Alert';
      case AlertType.roadblock:
        return 'Roadblock Alert';
      case AlertType.construction:
        return 'Construction Alert';
      case AlertType.traffic:
        return 'Traffic Alert';
      case AlertType.weather:
        return 'Weather Alert';
      case AlertType.roadClosure:
        return 'Road Closure Alert';
      case AlertType.other:
        return 'Other Alert';
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
    }
  }

  Future<void> _playVoiceNote(RoadAlert alert) async {
    if (alert.voiceNoteUrl == null || alert.voiceNoteUrl!.isEmpty) {
      _showSnackBar('No voice note available for this alert.', Colors.red);
      return;
    }

    if (_playingVoiceNoteId == alert.id) {
      await _audioPlayer.pause();
      setState(() {
        _playingVoiceNoteId = null;
      });
      print('Paused voice note for alert: ${alert.id}');
    } else {
      if (_playingVoiceNoteId != null) {
        await _audioPlayer.stop();
      }
      try {
        await _audioPlayer.setUrl(alert.voiceNoteUrl!);
        await _audioPlayer.play();
        setState(() {
          _playingVoiceNoteId = alert.id;
        });
        _showSnackBar('Playing voice note from URL: ${alert.voiceNoteUrl}', Colors.blue);
        print('Playing voice note for alert: ${alert.id}, URL: ${alert.voiceNoteUrl}');
      } catch (e) {
        print('Error playing voice note: $e');
        _showSnackBar('Error playing voice note: $e', Colors.red);
        setState(() {
          _playingVoiceNoteId = null;
        });
      }
    }
  }

  Future<void> _playVoiceNoteAutomatically(RoadAlert alert) async {
    if (alert.voiceNoteUrl == null || alert.voiceNoteUrl!.isEmpty) {
      print('No voice note URL for automatic playback for alert: ${alert.id}');
      return;
    }

    if (_playingVoiceNoteId != null && _playingVoiceNoteId != alert.id) {
      await _audioPlayer.stop();
      setState(() {
        _playingVoiceNoteId = null;
      });
      print('Stopped currently playing voice note for new automatic playback.');
    }

    try {
      await _audioPlayer.setUrl(alert.voiceNoteUrl!);
      await _audioPlayer.play();
      setState(() {
        _playingVoiceNoteId = alert.id;
      });
      _showSnackBar('Automatically playing voice note for alert: ${_getAlertTitle(alert.type)}', Colors.blue);
      print('Automatically playing voice note from URL: ${alert.voiceNoteUrl}');
    } catch (e) {
      print('Error automatically playing voice note: $e');
      _showSnackBar('Error automatically playing voice note: $e', Colors.red);
      setState(() {
        _playingVoiceNoteId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Road Alerts'),
        actions: [
          DropdownButton<AlertType>(
            value: _selectedFilter,
            hint: const Text('Filter by Type'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Alerts')),
              ...AlertType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(_getAlertTitle(type)),
                  )),
            ],
            onChanged: (type) {
              setState(() {
                _selectedFilter = type;
                _applyCurrentFilter();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _filteredAlerts.isEmpty
                  ? const Center(child: Text('No active alerts found.'))
                  : ListView.builder(
                      itemCount: _filteredAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = _filteredAlerts[index];
                        final isNew = _newAlertIds.contains(alert.id);
                        final isProximity = _proximityAlertTriggered.contains(alert.id);
                        final isPlayingVoiceNote = _playingVoiceNoteId == alert.id;

                        return Card(
                          color: isProximity ? Colors.red.withOpacity(0.1) : (isNew ? Colors.blue.withOpacity(0.05) : null),
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(_getAlertIcon(alert.type), color: _getSeverityColor(alert.severity)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        alert.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    if (isNew)
                                      ScaleTransition(
                                        scale: _notificationAnimation,
                                        child: const Icon(Icons.star, color: Colors.amber),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (alert.description != null && alert.description!.isNotEmpty)
                                  Text(
                                    alert.description!,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                const SizedBox(height: 8),
                                Text('Location: ${alert.location ?? 'N/A'}'),
                                if (alert.latitude != null && alert.longitude != null)
                                  Text(
                                      'Lat: ${alert.latitude!.toStringAsFixed(4)}, Lon: ${alert.longitude!.toStringAsFixed(4)}'),
                                Text('Severity: ${alert.severity.name.toUpperCase()}'),
                                Text('Reported: ${alert.timeAgo}'),
                                Text('Credibility Score: ${alert.credibilityScore}'),
                                Text('Verifications: ${alert.verificationCount ?? 0}'),
                                
                                // Play Voice Note Button
                                if (alert.voiceNoteUrl != null && alert.voiceNoteUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () => _playVoiceNote(alert),
                                      icon: Icon(isPlayingVoiceNote ? Icons.pause : Icons.play_arrow),
                                      label: Text(isPlayingVoiceNote ? 'Pause Voice Note' : 'Play Voice Note'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isPlayingVoiceNote ? Colors.orange : Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),

                                // Action buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.thumb_up),
                                      label: const Text('Verify'),
                                      onPressed: () async {
                                        final String currentUserId = 'test_user_id'; 
                                        final success = await _alertService.verifyAlert(alert.id, currentUserId);
                                        if (success) {
                                          _showSnackBar('Alert verified!', Colors.blue);
                                          _loadAlerts(); 
                                        } else {
                                          _showSnackBar('Failed to verify alert.', Colors.red);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
