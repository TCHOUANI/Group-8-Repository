 import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'alert_firebase_service.dart'; // Import the alert service

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _selectedReportType = '';
  String _selectedSeverity = ''; // New field for severity
  final TextEditingController _descriptionController = TextEditingController();
  bool _isRecording = false;
  bool _isSubmitting = false;
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AlertFirebaseService _alertService = AlertFirebaseService();
  
  // Simple location placeholder
  String _locationName = 'San Francisco, CA';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectReportType(String type) {
    setState(() {
      _selectedReportType = type;
    });
  }

  void _selectSeverity(String severity) {
    setState(() {
      _selectedSeverity = severity;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Simulate recording start
      print('Started recording voice note');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice recording started (demo mode)'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Simulate recording stop
      print('Stopped recording voice note');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice recording stopped (demo mode)'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Convert report type to AlertType
  AlertType _getAlertTypeFromReport(String reportType) {
    switch (reportType) {
      case 'accident':
        return AlertType.accident;
      case 'traffic':
        return AlertType.traffic;
      case 'pothole':
        return AlertType.roadClosure; // Treat potholes as road issues
      case 'construction':
        return AlertType.construction;
      case 'weather':
        return AlertType.weather;
      default:
        return AlertType.traffic; // Default fallback
    }
  }

  // Convert severity string to AlertSeverity
  AlertSeverity _getAlertSeverityFromString(String severity) {
    switch (severity) {
      case 'low':
        return AlertSeverity.low;
      case 'medium':
        return AlertSeverity.medium;
      case 'high':
        return AlertSeverity.high;
      default:
        return AlertSeverity.medium; // Default fallback
    }
  }

  // Determine severity based on report type (fallback if user doesn't select)
  AlertSeverity _getSeverityFromReport(String reportType) {
    switch (reportType) {
      case 'accident':
        return AlertSeverity.high;
      case 'traffic':
        return AlertSeverity.medium;
      case 'pothole':
        return AlertSeverity.medium;
      case 'construction':
        return AlertSeverity.low;
      case 'weather':
        return AlertSeverity.medium;
      default:
        return AlertSeverity.medium;
    }
  }

  // Generate appropriate title for the alert
  String _generateAlertTitle(String reportType) {
    switch (reportType) {
      case 'accident':
        return 'Traffic Accident Reported';
      case 'traffic':
        return 'Heavy Traffic Reported';
      case 'pothole':
        return 'Road Hazard: Pothole';
      case 'construction':
        return 'Construction Work Reported';
      case 'weather':
        return 'Weather-Related Issue';
      default:
        return 'Road Issue Reported';
    }
  }

  Future<void> _submitReport() async {
    // Validation
    if (_selectedReportType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a report type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSeverity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select issue severity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // First, submit the original report to the reports collection
      Map<String, dynamic> reportData = {
        'type': _selectedReportType,
        'severity': _selectedSeverity, // Include user-selected severity
        'description': _descriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'location': {
          'name': _locationName,
          'coordinates': null,
        },
        'hasVoiceNote': _isRecording,
        'userId': 'anonymous',
        'deviceInfo': {
          'platform': 'mobile',
          'submittedAt': DateTime.now().toIso8601String(),
        }
      };

      DocumentReference reportRef = await _firestore
          .collection('reports')
          .add(reportData);

      // Now create a corresponding alert using user-selected severity
      String? alertId = await _alertService.reportAlert(
        type: _getAlertTypeFromReport(_selectedReportType),
        title: _generateAlertTitle(_selectedReportType),
        description: _descriptionController.text.trim(),
        location: _locationName,
        latitude: 37.7749, // Default coordinates for San Francisco - update with actual location
        longitude: -122.4194,
        severity: _getAlertSeverityFromString(_selectedSeverity), // Use user-selected severity
      );

      if (alertId != null) {
        // Link the report to the alert
        await reportRef.update({'linkedAlertId': alertId});
        
        // Success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report submitted successfully!'),
                Text('Alert created and visible to other users'),
                Text('Report ID: ${reportRef.id.substring(0, 8)}...'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Navigate back after successful submission
        Navigator.pop(context, {
          'success': true,
          'reportId': reportRef.id,
          'alertId': alertId,
          'reportType': _selectedReportType,
          'severity': _selectedSeverity,
        });
      } else {
        // Report was created but alert creation failed (likely not signed in)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report submitted successfully!'),
                Text('Sign in to create public alerts'),
                Text('Report ID: ${reportRef.id.substring(0, 8)}...'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );

        Navigator.pop(context, {
          'success': true,
          'reportId': reportRef.id,
          'alertId': null,
          'reportType': _selectedReportType,
          'severity': _selectedSeverity,
        });
      }

    } catch (e) {
      print('Error submitting report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildReportTypeButton({
    required String title,
    required IconData icon,
    required Color color,
    required String type,
  }) {
    bool isSelected = _selectedReportType == type;

    return GestureDetector(
      onTap: () => _selectReportType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityButton({
    required String title,
    required String description,
    required Color color,
    required String severity,
    required IconData icon,
  }) {
    bool isSelected = _selectedSeverity == severity;

    return GestureDetector(
      onTap: () => _selectSeverity(severity),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Report Issue',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert Info Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your report will be visible to other users as a live alert',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Map Section
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF87CEEB),
                              Color(0xFFB0E0E6),
                              Color(0xFF98FB98),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Sample map content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 40,
                                    color: Colors.red[600],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _locationName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Text(
                                    'Current Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Location refresh button
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: Color(0xFF1A237E),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Report Type Selection
                  const Text(
                    'Select Report Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildReportTypeButton(
                        title: 'Pothole',
                        icon: Icons.warning,
                        color: Colors.orange,
                        type: 'pothole',
                      ),
                      _buildReportTypeButton(
                        title: 'Accident',
                        icon: Icons.car_crash,
                        color: Colors.red,
                        type: 'accident',
                      ),
                      _buildReportTypeButton(
                        title: 'Traffic',
                        icon: Icons.traffic,
                        color: Colors.amber[800]!,
                        type: 'traffic',
                      ),
                      _buildReportTypeButton(
                        title: 'Construction',
                        icon: Icons.construction,
                        color: Colors.brown,
                        type: 'construction',
                      ),
                      _buildReportTypeButton(
                        title: 'Weather',
                        icon: Icons.cloud_queue,
                        color: Colors.blue,
                        type: 'weather',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Severity Selection
                  const Text(
                    'Issue Severity *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: [
                      _buildSeverityButton(
                        title: 'Low Priority',
                        description: 'Minor issue, not urgent',
                        color: Colors.green,
                        severity: 'low',
                        icon: Icons.info_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildSeverityButton(
                        title: 'Medium Priority',
                        description: 'Moderate issue, should be addressed',
                        color: Colors.orange,
                        severity: 'medium',
                        icon: Icons.warning_amber,
                      ),
                      const SizedBox(height: 12),
                      _buildSeverityButton(
                        title: 'High Priority',
                        description: 'Serious issue, requires immediate attention',
                        color: Colors.red,
                        severity: 'high',
                        icon: Icons.priority_high,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description Section
                  const Text(
                    'Description *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Describe the issue in detail... This will be visible to other users.',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Voice Note Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: _toggleRecording,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red : Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _isRecording ? 'Stop Recording' : 'Record Voice Note',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        _isRecording
                            ? 'Recording in progress... (demo mode)'
                            : 'Optional: Add a voice message (demo mode)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80), // Space for submit button
                ],
              ),
            ),
          ),

          // Submit Button (Fixed at bottom)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Report & Create Alert',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}