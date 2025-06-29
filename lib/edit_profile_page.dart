 import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home_screen.dart';

// Firebase Service Class
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

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
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Upload profile image to Firebase Storage
  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');
      final ref = _storage
          .ref()
          .child('profile_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(imageFile);
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
      // Image might not exist or already deleted
      print('Failed to delete image: $e');
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
        'selectedLanguage': 'English',
        'selectedAlertType': 'In-App Notification',
        'roadHazardAlerts': false,
        'locationTracking': false,
        'roadSignTips': false,
        'profileImageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData);
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }
}

class EditProfilePage extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  final String selectedLanguage;
  final String selectedAlertType;
  final bool roadHazardAlerts;
  final bool locationTracking;
  final bool roadSignTips;
  final String? profileImageUrl;

  const EditProfilePage({
    Key? key,
    required this.fullName,
    required this.phoneNumber,
    required this.selectedLanguage,
    required this.selectedAlertType,
    required this.roadHazardAlerts,
    required this.locationTracking,
    required this.roadSignTips,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Text controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Dropdown values
  String _selectedLanguage = 'English';
  String _selectedAlertType = 'In-App Notification';

  // Toggle switches state
  bool _roadHazardAlerts = false;
  bool _locationTracking = false;
  bool _roadSignTips = false;

  // Profile image
  String? _profileImageUrl;
  File? _selectedImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  // Loading state
  bool _isLoading = false;

  // Available options
  final List<String> _languages = ['English', 'French', 'Arabic'];
  final List<String> _alertTypes = [
    'In-App Notification',
    'Push Notification',
    'SMS',
    'Email',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Initialize with passed values
    _fullNameController.text = widget.fullName;
    _phoneController.text = widget.phoneNumber;
    _selectedLanguage = widget.selectedLanguage;
    _selectedAlertType = widget.selectedAlertType;
    _roadHazardAlerts = widget.roadHazardAlerts;
    _locationTracking = widget.locationTracking;
    _roadSignTips = widget.roadSignTips;
    _profileImageUrl = widget.profileImageUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Save profile data to both SharedPreferences and Firebase
  Future<void> _saveProfileData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Save to SharedPreferences for offline access
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', _fullNameController.text.trim());
      await prefs.setString('phoneNumber', _phoneController.text.trim());
      await prefs.setString('selectedLanguage', _selectedLanguage);
      await prefs.setString('selectedAlertType', _selectedAlertType);
      await prefs.setBool('roadHazardAlerts', _roadHazardAlerts);
      await prefs.setBool('locationTracking', _locationTracking);
      await prefs.setBool('roadSignTips', _roadSignTips);
      String? imageUrl = _profileImageUrl;

      // Upload new image if selected
      if (_selectedImageFile != null) {
        // Delete old image if exists
        if (_profileImageUrl != null) {
          await FirebaseService.deleteProfileImage(_profileImageUrl!);
        }
        // Upload new image
        imageUrl = await FirebaseService.uploadProfileImage(_selectedImageFile!);
      }
      if (imageUrl != null) {
        await prefs.setString('profileImageUrl', imageUrl);
      }

      // Save to Firebase
      await FirebaseService.saveUserProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        selectedLanguage: _selectedLanguage,
        selectedAlertType: _selectedAlertType,
        roadHazardAlerts: _roadHazardAlerts,
        locationTracking: _locationTracking,
        roadSignTips: _roadSignTips,
        profileImageUrl: imageUrl,
      );

      // Set the flag that the profile has been completed
      await prefs.setBool('has_completed_profile', true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );

      // Navigate back to the home screen after saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changePhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _removePhoto() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_profileImageUrl != null) {
        await FirebaseService.deleteProfileImage(_profileImageUrl!);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('profileImageUrl');
        setState(() {
          _profileImageUrl = null;
          _selectedImageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo removed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove photo: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _changePhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _selectedImageFile != null
                          ? FileImage(_selectedImageFile!)
                          : (_profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null) as ImageProvider?,
                      child: _selectedImageFile == null && _profileImageUrl == null
                          ? Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade400,
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Full Name Input
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Phone Number Input
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Language Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _languages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Alert Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedAlertType,
              decoration: InputDecoration(
                labelText: 'Alert Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _alertTypes.map((String alertType) {
                return DropdownMenuItem<String>(
                  value: alertType,
                  child: Text(alertType),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedAlertType = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Toggle Switches
            SwitchListTile(
              title: const Text('Road Hazard Alerts'),
              value: _roadHazardAlerts,
              onChanged: (bool value) {
                setState(() {
                  _roadHazardAlerts = value;
                });
              },
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Location Tracking'),
              value: _locationTracking,
              onChanged: (bool value) {
                setState(() {
                  _locationTracking = value;
                });
              },
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Road Sign Tips'),
              value: _roadSignTips,
              onChanged: (bool value) {
                setState(() {
                  _roadSignTips = value;
                });
              },
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),
            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _saveProfileData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Save Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}