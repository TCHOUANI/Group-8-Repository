/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class ReportVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Configuration constants
  static const double LOCATION_THRESHOLD_METERS = 100.0;
  static const int REQUIRED_REPORTS = 1;
  static const int VERIFICATION_TIME_WINDOW_HOURS = 1;
  static const int CLEANUP_INTERVAL_HOURS = 24;

  // Singleton pattern
  static final ReportVerificationService _instance = ReportVerificationService._internal();
  factory ReportVerificationService() => _instance;
  ReportVerificationService._internal();

  /// Calculate distance between two GPS coordinates
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Find similar reports within the specified radius and time window
  Future<List<QueryDocumentSnapshot>> findSimilarReports({
    required String reportType,
    required double latitude,
    required double longitude,
    String? excludeReportId,
  }) async {
    try {
      DateTime timeThreshold = DateTime.now().subtract(
        Duration(hours: VERIFICATION_TIME_WINDOW_HOURS)
      );

      QuerySnapshot querySnapshot = await _firestore
          .collection('pending_reports')
          .where('type', isEqualTo: reportType)
          .where('timestamp', isGreaterThan: timeThreshold)
          .where('status', isEqualTo: 'pending_verification')
          .get();

      List<QueryDocumentSnapshot> similarReports = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Skip the current report if specified
        if (excludeReportId != null && doc.id == excludeReportId) {
          continue;
        }

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        if (data['location']?['coordinates'] != null) {
          double reportLat = data['location']['coordinates']['latitude']?.toDouble() ?? 0.0;
          double reportLon = data['location']['coordinates']['longitude']?.toDouble() ?? 0.0;
          
          double distance = calculateDistance(latitude, longitude, reportLat, reportLon);
          
          if (distance <= LOCATION_THRESHOLD_METERS) {
            similarReports.add(doc);
          }
        }
      }

      return similarReports;
    } catch (e) {
      print('Error finding similar reports: $e');
      return [];
    }
  }

  /// Check if a report location has enough reports for verification
  Future<bool> canCreateAlert({
    required String reportType,
    required double latitude,
    required double longitude,
  }) async {
    List<QueryDocumentSnapshot> similarReports = await findSimilarReports(
      reportType: reportType,
      latitude: latitude,
      longitude: longitude,
    );

    return similarReports.length >= (REQUIRED_REPORTS - 1);
  }

  /// Get verification status for a location
  Future<Map<String, dynamic>> getVerificationStatus({
    required String reportType,
    required double latitude,
    required double longitude,
  }) async {
    List<QueryDocumentSnapshot> similarReports = await findSimilarReports(
      reportType: reportType,
      latitude: latitude,
      longitude: longitude,
    );

    int currentCount = similarReports.length + 1; // +1 for the current report
    bool canVerify = similarReports.length >= (REQUIRED_REPORTS - 1);

    return {
      'currentCount': currentCount,
      'requiredCount': REQUIRED_REPORTS,
      'canVerify': canVerify,
      'similarReports': similarReports.map((doc) => doc.id).toList(),
      'timeWindow': VERIFICATION_TIME_WINDOW_HOURS,
      'locationRadius': LOCATION_THRESHOLD_METERS,
    };
  }

  /// Verify reports and update their status
  Future<bool> verifyReports({
    required List<String> reportIds,
    required String alertId,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (String reportId in reportIds) {
        DocumentReference reportRef = _firestore
            .collection('pending_reports')
            .doc(reportId);
        
        batch.update(reportRef, {
          'status': 'verified',
          'linkedAlertId': alertId,
          'verifiedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error verifying reports: $e');
      return false;
    }
  }

  /// Clean up old pending reports that haven't been verified
  Future<void> cleanupOldPendingReports() async {
    try {
      DateTime cleanupThreshold = DateTime.now().subtract(
        Duration(hours: CLEANUP_INTERVAL_HOURS)
      );

      QuerySnapshot oldReports = await _firestore
          .collection('pending_reports')
          .where('timestamp', isLessThan: cleanupThreshold)
          .where('status', isEqualTo: 'pending_verification')
          .get();

      WriteBatch batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in oldReports.docs) {
        batch.update(doc.reference, {
          'status': 'expired',
          'expiredAt': FieldValue.serverTimestamp(),
        });
      }

      if (oldReports.docs.isNotEmpty) {
        await batch.commit();
        print('Cleaned up ${oldReports.docs.length} expired pending reports');
      }
    } catch (e) {
      print('Error cleaning up old reports: $e');
    }
  }

  /// Get reports awaiting verification in an area
  Future<List<Map<String, dynamic>>> getReportsAwaitingVerification({
    required double latitude,
    required double longitude,
    double radiusMeters = 1000.0,
  }) async {
    try {
      DateTime timeThreshold = DateTime.now().subtract(
        Duration(hours: VERIFICATION_TIME_WINDOW_HOURS)
      );

      QuerySnapshot querySnapshot = await _firestore
          .collection('pending_reports')
          .where('timestamp', isGreaterThan: timeThreshold)
          .where('status', isEqualTo: 'pending_verification')
          .get();

      List<Map<String, dynamic>> nearbyReports = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        if (data['location']?['coordinates'] != null) {
          double reportLat = data['location']['coordinates']['latitude']?.toDouble() ?? 0.0;
          double reportLon = data['location']['coordinates']['longitude']?.toDouble() ?? 0.0;
          
          double distance = calculateDistance(latitude, longitude, reportLat, reportLon);
          
          if (distance <= radiusMeters) {
            // Get verification status for this report
            Map<String, dynamic> verificationStatus = await getVerificationStatus(
              reportType: data['type'],
              latitude: reportLat,
              longitude: reportLon,
            );

            nearbyReports.add({
              'id': doc.id,
              'data': data,
              'distance': distance,
              'verificationStatus': verificationStatus,
            });
          }
        }
      }

      // Sort by distance
      nearbyReports.sort((a, b) => a['distance'].compareTo(b['distance']));

      return nearbyReports;
    } catch (e) {
      print('Error getting reports awaiting verification: $e');
      return [];
    }
  }

  /// Get statistics about verification system
  Future<Map<String, dynamic>> getVerificationStats() async {
    try {
      DateTime timeThreshold = DateTime.now().subtract(
        Duration(hours: VERIFICATION_TIME_WINDOW_HOURS)
      );

      // Get pending reports count
      QuerySnapshot pendingReports = await _firestore
          .collection('pending_reports')
          .where('status', isEqualTo: 'pending_verification')
          .where('timestamp', isGreaterThan: timeThreshold)
          .get();

      // Get verified reports count
      QuerySnapshot verifiedReports = await _firestore
          .collection('pending_reports')
          .where('status', isEqualTo: 'verified')
          .where('verifiedAt', isGreaterThan: timeThreshold)
          .get();

      // Get expired reports count
      QuerySnapshot expiredReports = await _firestore
          .collection('pending_reports')
          .where('status', isEqualTo: 'expired')
          .get();

      // Group by report type
      Map<String, int> reportsByType = {};
      for (QueryDocumentSnapshot doc in pendingReports.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String type = data['type'] ?? 'unknown';
        reportsByType[type] = (reportsByType[type] ?? 0) + 1;
      }

      return {
        'pendingCount': pendingReports.docs.length,
        'verifiedCount': verifiedReports.docs.length,
        'expiredCount': expiredReports.docs.length,
        'reportsByType': reportsByType,
        'verificationThreshold': REQUIRED_REPORTS,
        'timeWindowHours': VERIFICATION_TIME_WINDOW_HOURS,
        'locationThresholdMeters': LOCATION_THRESHOLD_METERS,
      };
    } catch (e) {
      print('Error getting verification stats: $e');
      return {};
    }
  }

  /// Check if user has already reported similar issue in the area
  Future<bool> hasUserReportedSimilarIssue({
    required String userId,
    required String reportType,
    required double latitude,
    required double longitude,
  }) async {
    try {
      DateTime timeThreshold = DateTime.now().subtract(
        Duration(hours: VERIFICATION_TIME_WINDOW_HOURS)
      );

      QuerySnapshot userReports = await _firestore
          .collection('pending_reports')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: reportType)
          .where('timestamp', isGreaterThan: timeThreshold)
          .get();

      for (QueryDocumentSnapshot doc in userReports.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        if (data['location']?['coordinates'] != null) {
          double reportLat = data['location']['coordinates']['latitude']?.toDouble() ?? 0.0;
          double reportLon = data['location']['coordinates']['longitude']?.toDouble() ?? 0.0;
          
          double distance = calculateDistance(latitude, longitude, reportLat, reportLon);
          
          if (distance <= LOCATION_THRESHOLD_METERS) {
            return true; // User has already reported similar issue in this area
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking user duplicate reports: $e');
      return false;
    }
  }

  /// Create a verification summary for display
  String createVerificationSummary(Map<String, dynamic> status) {
    int current = status['currentCount'] ?? 0;
    int required = status['requiredCount'] ?? REQUIRED_REPORTS;
    bool canVerify = status['canVerify'] ?? false;

    if (canVerify) {
      return '✅ Ready for verification ($current/$required reports)';
    } else {
      int needed = required - current;
      return '⏳ Needs $needed more report${needed > 1 ? 's' : ''} ($current/$required)';
    }
  }
}*/