 import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool roadHazardAlerts = false;
  bool locationTracking = false;
  bool roadSignTips = false;
  String selectedLanguage = 'English';
  String selectedAlertType = 'In-App Notification';
  String fullName = 'UseName';
  String phoneNumber = '+237 6XX XXX XXX';
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        fullName = prefs.getString('fullName') ?? 'Beh Chu Nelson';
        phoneNumber = prefs.getString('phoneNumber') ?? '+237 6XX XXX XXX';
        selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
        selectedAlertType =
            prefs.getString('selectedAlertType') ?? 'In-App Notification';
        roadHazardAlerts = prefs.getBool('roadHazardAlerts') ?? false;
        locationTracking = prefs.getBool('locationTracking') ?? false;
        roadSignTips = prefs.getBool('roadSignTips') ?? false;
        profileImageUrl = prefs.getString('profileImageUrl');
        isLoading = false;
      });
    } catch (e) {
      // Handle error - set default values
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load profile data'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Save toggle setting to SharedPreferences
  Future<void> _saveToggleSetting(String key, bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Setting updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save setting'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Handle toggle changes
  void _handleToggleChange(String settingKey, bool newValue) {
    setState(() {
      switch (settingKey) {
        case 'roadHazardAlerts':
          roadHazardAlerts = newValue;
          break;
        case 'locationTracking':
          locationTracking = newValue;
          break;
        case 'roadSignTips':
          roadSignTips = newValue;
          break;
      }
    });

    // Save to SharedPreferences
    _saveToggleSetting(settingKey, newValue);
  }

  // Refresh profile data when returning from edit page
  Future<void> _refreshProfileData() async {
    setState(() {
      isLoading = true;
    });
    await _loadProfileData();
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
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () async {
              // Navigate to EditProfilePage and wait for result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    fullName: fullName,
                    phoneNumber: phoneNumber,
                    selectedLanguage: selectedLanguage,
                    selectedAlertType: selectedAlertType,
                    roadHazardAlerts: roadHazardAlerts,
                    locationTracking: locationTracking,
                    roadSignTips: roadSignTips,
                    profileImageUrl: profileImageUrl,
                  ),
                ),
              );

              // Refresh profile data when returning from edit page
              if (result == true) {
                await _refreshProfileData();

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A237E)),
            )
          : RefreshIndicator(
              onRefresh: _refreshProfileData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header Section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFFDDB3),
                                  Colors.orange.shade400,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: profileImageUrl != null
                                  ? Image.network(
                                      profileImageUrl!,
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
                                        return Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFFFDDB3),
                                                Color(0xFFFFB366),
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Color(0xFF8B4513),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFFDDB3),
                                            Color(0xFFFFB366),
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xFF8B4513),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Phone Number
                          Text(
                            phoneNumber,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Settings Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Preferred Language (Display only)
                          _buildDisplayItem(
                            title: 'Preferred Language',
                            value: selectedLanguage,
                          ),

                          _buildDivider(),

                          // Alert Type (Display only)
                          _buildDisplayItem(
                            title: 'Alert Type',
                            value: selectedAlertType,
                          ),

                          _buildDivider(),

                          // Road Hazard Alerts Toggle (Functional)
                          _buildFunctionalToggleItem(
                            title: 'Road Hazard Alerts',
                            value: roadHazardAlerts,
                            onChanged: (value) => _handleToggleChange(
                              'roadHazardAlerts',
                              value,
                            ),
                          ),

                          _buildDivider(),

                          // Location Tracking Toggle (Functional)
                          _buildFunctionalToggleItem(
                            title: 'Location Tracking',
                            value: locationTracking,
                            onChanged: (value) => _handleToggleChange(
                              'locationTracking',
                              value,
                            ),
                          ),

                          _buildDivider(),

                          // Road Sign Tips Toggle (Functional)
                          _buildFunctionalToggleItem(
                            title: 'Road Sign Tips',
                            value: roadSignTips,
                            onChanged: (value) => _handleToggleChange(
                              'roadSignTips',
                              value,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Instruction Message
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Tap the edit icon to modify your profile details',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDisplayItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionalToggleItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1A237E),
            activeTrackColor: const Color(0xFF1A237E).withOpacity(0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }
}