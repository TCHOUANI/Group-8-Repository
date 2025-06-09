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
    } catch (e) {
      throw Exception('Failed to save profile data: $e');
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
                  _handlePhotoSelection(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _handlePhotoSelection(ImageSource.gallery);
                },
              ),
              if (_profileImageUrl != null || _selectedImageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
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

  Future<void> _handlePhotoSelection(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo selected from ${source == ImageSource.camera ? 'camera' : 'gallery'}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImageFile = null;
      _profileImageUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Picture Section
                  _buildProfilePictureSection(),

                  const SizedBox(height: 40),

                  // Form Fields
                  _buildTextField('Full Name', _fullNameController),
                  const SizedBox(height: 20),

                  _buildTextField('Phone Number', _phoneController),
                  const SizedBox(height: 20),

                  _buildDropdownField(
                    'Preferred Language',
                    _selectedLanguage,
                    _languages,
                    (value) {
                      setState(() => _selectedLanguage = value!);
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildDropdownField(
                    'Alert Preference',
                    _selectedAlertType,
                    _alertTypes,
                    (value) {
                      setState(() => _selectedAlertType = value!);
                    },
                  ),
                  const SizedBox(height: 30),

                  // Toggle Switches Section
                  _buildToggleSection(),

                  const SizedBox(height: 40),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _changePhoto,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange.shade300, Colors.orange.shade400],
                  ),
                ),
                child: ClipOval(
                  child: _selectedImageFile != null
                      ? Image.file(
                          _selectedImageFile!,
                          fit: BoxFit.cover,
                        )
                      : _profileImageUrl != null
                          ? Image.network(
                              _profileImageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                );
                              },
                            )
                          : Container(
                              padding: const EdgeInsets.all(8),
                              child: CustomPaint(
                                painter: ProfilePainter(),
                                size: const Size(104, 104),
                              ),
                            ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _fullNameController.text.isNotEmpty
              ? _fullNameController.text
              : 'User Name',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: _changePhoto,
          child: const Text(
            'Change Photo',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
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
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
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
          child: DropdownButtonFormField<String>(
            value: currentValue,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSection() {
    return Column(
      children: [
        _buildToggleItem('Road Hazard Alerts', _roadHazardAlerts, (value) {
          setState(() => _roadHazardAlerts = value);
        }),
        const SizedBox(height: 16),
        _buildToggleItem('Location Tracking', _locationTracking, (value) {
          setState(() => _locationTracking = value);
        }),
        const SizedBox(height: 16),
        _buildToggleItem('Road Sign Tips', _roadSignTips, (value) {
          setState(() => _roadSignTips = value);
        }),
      ],
    );
  }

  Widget _buildToggleItem(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1A237E),
            activeTrackColor: const Color(0xFF1A237E).withOpacity(0.3),
            inactiveThumbColor: Colors.grey[300],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Changes Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2463),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveChanges() async {
    // Validate form
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _saveProfileData();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to HomeScreen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Custom painter for the profile illustration (unchanged)
class ProfilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw face
    paint.color = const Color(0xFFD2B48C);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.4),
        width: size.width * 0.6,
        height: size.height * 0.65,
      ),
      paint,
    );

    // Draw hair
    paint.color = const Color(0xFF8B4513);
    final hairPath = Path();
    hairPath.moveTo(size.width * 0.2, size.height * 0.15);
    hairPath.quadraticBezierTo(
      size.width * 0.1,
      size.width * 0.3,
      size.width * 0.15,
      size.height * 0.5,
    );
    hairPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.65,
    );
    hairPath.lineTo(size.width * 0.6, size.height * 0.65);
    hairPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width * 0.85,
      size.height * 0.5,
    );
    hairPath.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.3,
      size.width * 0.8,
      size.height * 0.15,
    );
    hairPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.05,
      size.width * 0.2,
      size.height * 0.15,
    );
    canvas.drawPath(hairPath, paint);

    // Draw eyes
    paint.color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.35), 2, paint);
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.35), 2, paint);

    // Draw nose
    paint.color = const Color(0xFFCD853F);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.42), 1.5, paint);

    // Draw mouth
    paint.color = const Color(0xFF8B4513);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    final mouthPath = Path();
    mouthPath.moveTo(size.width * 0.45, size.height * 0.5);
    mouthPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.52,
      size.width * 0.55,
      size.height * 0.5,
    );
    canvas.drawPath(mouthPath, paint);

    // Draw top/shirt
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.4,
        size.height * 0.3,
      ),
      paint,
    );

    // Draw straps
    paint.color = Colors.white;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.7),
      Offset(size.width * 0.42, size.height * 0.6),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.7),
      Offset(size.width * 0.58, size.height * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}