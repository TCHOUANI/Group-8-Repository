 import 'dart:math' as math; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertFirebaseService {
  static final AlertFirebaseService _instance =
      AlertFirebaseService._internal();
  factory AlertFirebaseService() => _instance;
  AlertFirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _alertsCollection =>
      _firestore.collection('road_alerts');

  /// Create a new road alert
  Future<String?> createAlert(RoadAlert alert) async {
    try {
      final docRef = await _alertsCollection.add(alert.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating alert: $e');
      return null;
    }
  }

  /// Get all active alerts
  Future<List<RoadAlert>> getActiveAlerts() async {
    try {
      final querySnapshot =
          await _alertsCollection
              .where('isActive', isEqualTo: true)
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => RoadAlert.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }

  /// Get alerts by type
  Future<List<RoadAlert>> getAlertsByType(AlertType type) async {
    try {
      final querySnapshot =
          await _alertsCollection
              .where('type', isEqualTo: type.name)
              .where('isActive', isEqualTo: true)
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => RoadAlert.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error fetching alerts by type: $e');
      return [];
    }
  }

  /// Get alerts by severity
  Future<List<RoadAlert>> getAlertsBySeverity(AlertSeverity severity) async {
    try {
      final querySnapshot =
          await _alertsCollection
              .where('severity', isEqualTo: severity.name)
              .where('isActive', isEqualTo: true)
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => RoadAlert.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error fetching alerts by severity: $e');
      return [];
    }
  }

  /// Get alerts within a geographic radius (requires GeoFlutterFire or similar)
  Future<List<RoadAlert>> getAlertsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      // Basic implementation - for precise geo queries, consider using GeoFlutterFire
      final querySnapshot =
          await _alertsCollection.where('isActive', isEqualTo: true).get();

      final alerts =
          querySnapshot.docs
              .map(
                (doc) => RoadAlert.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      // Filter by distance (basic implementation)
      return alerts.where((alert) {
        if (alert.latitude == null || alert.longitude == null) return false;
        final distance = _calculateDistance(
          latitude,
          longitude,
          alert.latitude!,
          alert.longitude!,
        );
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      print('Error fetching nearby alerts: $e');
      return [];
    }
  }

  /// Update an existing alert
  Future<bool> updateAlert(String alertId, Map<String, dynamic> updates) async {
    try {
      await _alertsCollection.doc(alertId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating alert: $e');
      return false;
    }
  }

  /// Deactivate an alert (soft delete)
  Future<bool> deactivateAlert(String alertId) async {
    try {
      await _alertsCollection.doc(alertId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error deactivating alert: $e');
      return false;
    }
  }

  /// Delete an alert permanently
  Future<bool> deleteAlert(String alertId) async {
    try {
      await _alertsCollection.doc(alertId).delete();
      return true;
    } catch (e) {
      print('Error deleting alert: $e');
      return false;
    }
  }

  /// Get real-time stream of active alerts
  Stream<List<RoadAlert>> getActiveAlertsStream() {
    return _alertsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => RoadAlert.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList(),
        );
  }

  /// Get real-time stream of alerts by type
  Stream<List<RoadAlert>> getAlertsByTypeStream(AlertType type) {
    return _alertsCollection
        .where('type', isEqualTo: type.name)
        .where('isActive', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => RoadAlert.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList(),
        );
  }

  /// Report an alert (user-generated)
  Future<String?> reportAlert({
    required AlertType type,
    required String title,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required AlertSeverity severity,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User must be authenticated to report alerts');
        return null;
      }

      final alert = RoadAlert(
        id: '', // Will be set by Firestore
        type: type,
        title: title,
        description: description,
        location: location,
        latitude: latitude,
        longitude: longitude,
        severity: severity,
        isActive: true,
        timestamp: DateTime.now(),
        reportedBy: user.uid,
        reportedByEmail: user.email,
      );

      return await createAlert(alert);
    } catch (e) {
      print('Error reporting alert: $e');
      return null;
    }
  }

  /// Get user's reported alerts
  Future<List<RoadAlert>> getUserReportedAlerts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot =
          await _alertsCollection
              .where('reportedBy', isEqualTo: user.uid)
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => RoadAlert.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error fetching user alerts: $e');
      return [];
    }
  }

  /// Upvote an alert (increase credibility)
  Future<bool> upvoteAlert(String alertId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _alertsCollection.doc(alertId).update({
        'upvotes': FieldValue.arrayUnion([user.uid]),
        'downvotes': FieldValue.arrayRemove([user.uid]),
      });
      return true;
    } catch (e) {
      print('Error upvoting alert: $e');
      return false;
    }
  }

  /// Downvote an alert (decrease credibility)
  Future<bool> downvoteAlert(String alertId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _alertsCollection.doc(alertId).update({
        'downvotes': FieldValue.arrayUnion([user.uid]),
        'upvotes': FieldValue.arrayRemove([user.uid]),
      });
      return true;
    } catch (e) {
      print('Error downvoting alert: $e');
      return false;
    }
  }

  /// Auto-expire old alerts (call this periodically)
  Future<void> expireOldAlerts({int hoursOld = 24}) async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(hours: hoursOld));
      final querySnapshot =
          await _alertsCollection
              .where('isActive', isEqualTo: true)
              .where('timestamp', isLessThan: Timestamp.fromDate(cutoffTime))
              .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'expiredAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error expiring old alerts: $e');
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreeToRadian(lat2 - lat1);
    final double dLon = _degreeToRadian(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _degreeToRadian(double degree) {
    return degree * (math.pi / 180);
  }
}

// Enhanced RoadAlert model with Firebase integration
class RoadAlert {
  final String id;
  final AlertType type;
  final String title;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final AlertSeverity severity;
  final bool isActive;
  final DateTime timestamp;
  final DateTime? updatedAt;
  final DateTime? deactivatedAt;
  final DateTime? expiredAt;
  final String? reportedBy;
  final String? reportedByEmail;
  final List<String> upvotes;
  final List<String> downvotes;
  final Map<String, dynamic>? metadata;

  RoadAlert({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    required this.severity,
    required this.isActive,
    required this.timestamp,
    this.updatedAt,
    this.deactivatedAt,
    this.expiredAt,
    this.reportedBy,
    this.reportedByEmail,
    this.upvotes = const [],
    this.downvotes = const [],
    this.metadata,
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity.name,
      'isActive': isActive,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deactivatedAt':
          deactivatedAt != null ? Timestamp.fromDate(deactivatedAt!) : null,
      'expiredAt': expiredAt != null ? Timestamp.fromDate(expiredAt!) : null,
      'reportedBy': reportedBy,
      'reportedByEmail': reportedByEmail,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'metadata': metadata,
    };
  }

  // Create from Firestore document
  factory RoadAlert.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return RoadAlert(
      id: documentId,
      type: AlertType.values.firstWhere((e) => e.name == data['type']),
      title: data['title'] ?? '',
      description: data['description'],
      location: data['location'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == data['severity'],
      ),
      isActive: data['isActive'] ?? true,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
      deactivatedAt:
          data['deactivatedAt'] != null
              ? (data['deactivatedAt'] as Timestamp).toDate()
              : null,
      expiredAt:
          data['expiredAt'] != null
              ? (data['expiredAt'] as Timestamp).toDate()
              : null,
      reportedBy: data['reportedBy'],
      reportedByEmail: data['reportedByEmail'],
      upvotes: List<String>.from(data['upvotes'] ?? []),
      downvotes: List<String>.from(data['downvotes'] ?? []),
      metadata: data['metadata'],
    );
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  // Get credibility score
  int get credibilityScore => upvotes.length - downvotes.length;

  // Copy with method for updates
  RoadAlert copyWith({
    String? id,
    AlertType? type,
    String? title,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    AlertSeverity? severity,
    bool? isActive,
    DateTime? timestamp,
    DateTime? updatedAt,
    DateTime? deactivatedAt,
    DateTime? expiredAt,
    String? reportedBy,
    String? reportedByEmail,
    List<String>? upvotes,
    List<String>? downvotes,
    Map<String, dynamic>? metadata,
  }) {
    return RoadAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      severity: severity ?? this.severity,
      isActive: isActive ?? this.isActive,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      expiredAt: expiredAt ?? this.expiredAt,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedByEmail: reportedByEmail ?? this.reportedByEmail,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum AlertType { accident, weather, roadClosure, traffic, construction }

enum AlertSeverity { low, medium, high }