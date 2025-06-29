import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Save user profile to Firestore
  static Future<void> saveUserProfile({
    required String fullName,
    required String phoneNumber,
    required String selectedLanguage,
    required String selectedAlertType,
    required bool roadHazardAlerts,
    required bool locationTracking,
    required bool roadSignTips,
    String? profileImageUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      final profileData = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'selectedLanguage': selectedLanguage,
        'selectedAlertType': selectedAlertType,
        'roadHazardAlerts': roadHazardAlerts,
        'locationTracking': locationTracking,
        'roadSignTips': roadSignTips,
        'profileImageUrl': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'email': user.email,
        'uid': user.uid,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  // Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        // Convert Timestamp to String for easier handling
        if (data['updatedAt'] is Timestamp) {
          data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Upload profile image to Firebase Storage
  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Create a unique filename
      final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('profile_images').child(fileName);

      // Upload file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(imageFile, metadata);
      
      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      });

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete profile image from Firebase Storage
  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Image might not exist or already deleted, log but don't throw
      print('Warning: Failed to delete image: $e');
    }
  }

  // Create user document on first sign up
  static Future<void> createUserDocument({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      final userData = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': user.email,
        'uid': user.uid,
        'selectedLanguage': 'English',
        'selectedAlertType': 'In-App Notification',
        'roadHazardAlerts': false,
        'locationTracking': false,
        'roadSignTips': false,
        'profileImageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Update user preferences only
  static Future<void> updateUserPreferences({
    required String selectedLanguage,
    required String selectedAlertType,
    required bool roadHazardAlerts,
    required bool locationTracking,
    required bool roadSignTips,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      final updateData = {
        'selectedLanguage': selectedLanguage,
        'selectedAlertType': selectedAlertType,
        'roadHazardAlerts': roadHazardAlerts,
        'locationTracking': locationTracking,
        'roadSignTips': roadSignTips,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  // Sign out user
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Delete user account (optional - requires careful handling)
  static Future<void> deleteUserAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user profile image if exists
      final userData = await getUserProfile();
      if (userData != null && userData['profileImageUrl'] != null) {
        await deleteProfileImage(userData['profileImageUrl']);
      }

      // Delete user authentication account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Listen to user profile changes (real-time updates)
  static Stream<Map<String, dynamic>?> getUserProfileStream() {
    final user = currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            // Convert Timestamp to String for easier handling
            if (data['updatedAt'] is Timestamp) {
              data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
            }
            if (data['createdAt'] is Timestamp) {
              data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
            }
            return data;
          }
          return null;
        });
  }

  // Update user's last seen timestamp
  static Future<void> updateLastSeen() async {
    try {
      final user = currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
            'lastSeen': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      // Don't throw error for last seen update
      print('Failed to update last seen: $e');
    }
  }

  // Batch update multiple fields
  static Future<void> batchUpdateProfile(Map<String, dynamic> updates) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Add timestamp to updates
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to batch update profile: $e');
    }
  }

  // Utility method to check if user document exists
  static Future<bool> userDocumentExists() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get user's display name or fallback
  static String getDisplayName(Map<String, dynamic>? userData) {
    if (userData != null && userData['fullName'] != null && userData['fullName'].toString().isNotEmpty) {
      return userData['fullName'];
    }
    return currentUser?.displayName ?? currentUser?.email ?? 'User';
  }

  // Validate and sanitize phone number
  static String sanitizePhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Basic validation - you can enhance this based on your requirements
    if (cleaned.length < 10) {
      throw Exception('Phone number must be at least 10 digits');
    }
    
    return cleaned;
  }

  // Get user profile with error handling and caching
  static Future<Map<String, dynamic>> getUserProfileSafe() async {
    try {
      final profile = await getUserProfile();
      if (profile != null) {
        return profile;
      }
      
      // Return default profile if none exists
      return {
        'fullName': '',
        'phoneNumber': '',
        'selectedLanguage': 'English',
        'selectedAlertType': 'In-App Notification',
        'roadHazardAlerts': false,
        'locationTracking': false,
        'roadSignTips': false,
        'profileImageUrl': null,
        'email': currentUser?.email ?? '',
        'uid': currentUser?.uid ?? '',
      };
    } catch (e) {
      print('Error getting user profile: $e');
      // Return default profile on error
      return {
        'fullName': '',
        'phoneNumber': '',
        'selectedLanguage': 'English',
        'selectedAlertType': 'In-App Notification',
        'roadHazardAlerts': false,
        'locationTracking': false,
        'roadSignTips': false,
        'profileImageUrl': null,
        'email': currentUser?.email ?? '',
        'uid': currentUser?.uid ?? '',
      };
    }
  }
}