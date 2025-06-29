 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class RoadAlert {
  final String id;
  final String message;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String userId;
  final String alertType;
  final String? voiceNoteUrl; // Add this field

  RoadAlert({
    required this.id,
    required this.message,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.userId,
    required this.alertType,
    this.voiceNoteUrl, // Add this parameter
  });

  // Factory constructor for creating from Firestore document
  factory RoadAlert.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RoadAlert(
      id: doc.id,
      message: data['message'] ?? '',
      location: data['location'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      alertType: data['alertType'] ?? 'general',
      voiceNoteUrl: data['voiceNoteUrl'], // Add this line
    );
  }

  // Method to convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'alertType': alertType,
      'voiceNoteUrl': voiceNoteUrl, // Add this line
    };
  }
}

class AlertFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a new alert to Firestore
  Future<void> addAlert(RoadAlert alert) async {
    try {
      await _firestore.collection('alerts').add(alert.toMap());
      print('Alert added successfully');
    } catch (e) {
      print('Error adding alert: $e');
      throw e;
    }
  }

  // Stream to get real-time alerts
  Stream<List<RoadAlert>> getAlertsStream() {
    return _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoadAlert.fromFirestore(doc))
            .toList());
  }

  // Get alerts within a certain radius
  Future<List<RoadAlert>> getAlertsNearLocation(
      double latitude, double longitude, double radiusInKm) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('alerts').get();
      
      List<RoadAlert> nearbyAlerts = [];
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        RoadAlert alert = RoadAlert.fromFirestore(doc);
        
        // Calculate distance between user location and alert location
        double distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          alert.latitude,
          alert.longitude,
        ) / 1000; // Convert to kilometers
        
        if (distance <= radiusInKm) {
          nearbyAlerts.add(alert);
        }
      }
      
      // Sort by distance (closest first)
      nearbyAlerts.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          latitude, longitude, a.latitude, a.longitude,
        );
        double distanceB = Geolocator.distanceBetween(
          latitude, longitude, b.latitude, b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });
      
      return nearbyAlerts;
    } catch (e) {
      print('Error getting nearby alerts: $e');
      return [];
    }
  }

  // Delete an alert
  Future<void> deleteAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).delete();
      print('Alert deleted successfully');
    } catch (e) {
      print('Error deleting alert: $e');
      throw e;
    }
  }

  // Update an alert
  Future<void> updateAlert(String alertId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update(updates);
      print('Alert updated successfully');
    } catch (e) {
      print('Error updating alert: $e');
      throw e;
    }
  }
}