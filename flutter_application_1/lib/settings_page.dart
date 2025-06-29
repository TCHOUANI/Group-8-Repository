import 'package:flutter/material.dart';
import 'edit_profile_page.dart'; // Import the edit profile page

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state variables
  bool _enableAlerts = true;
  bool _voiceAlerts = false;
  bool _smsNotifications = true;
  bool _gpsAccess = true;
  bool _backgroundDataSync = false;

  // User profile data - these will be passed to EditProfilePage
  String _userFullName = 'John Doe';
  String _userPhoneNumber = '+1234567890';
  String _userSelectedLanguage = 'English';
  String _userSelectedAlertType = 'In-App Notification';
  bool _userRoadHazardAlerts = true;
  bool _userLocationTracking = true;
  bool _userRoadSignTips = false;

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
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            const SizedBox(height: 8),
            _buildToggleItem(
              'Enable Alerts',
              'Receive real-time alerts about road conditions',
              _enableAlerts,
              (value) => setState(() => _enableAlerts = value),
            ),
            _buildToggleItem(
              'Voice Alerts',
              'Hear alerts spoken aloud for hands-free awareness',
              _voiceAlerts,
              (value) => setState(() => _voiceAlerts = value),
            ),
            _buildToggleItem(
              'SMS Notifications',
              'Get alerts via SMS for critical updates',
              _smsNotifications,
              (value) => setState(() => _smsNotifications = value),
            ),
            _buildNavigationItem(
              'Alert Sound Options',
              'Choose a sound for new alert notifications',
              () => _showAlertSoundOptions(),
            ),

            const SizedBox(height: 24),

            // Language Section
            _buildSectionHeader('Language'),
            const SizedBox(height: 8),
            _buildNavigationItem(
              'Language Preferences',
              '',
              () => _showLanguageOptions(),
            ),

            const SizedBox(height: 24),

            // Location Section
            _buildSectionHeader('Location'),
            const SizedBox(height: 8),
            _buildToggleItem(
              'GPS Access',
              'Allow the app to access your GPS location',
              _gpsAccess,
              (value) => setState(() => _gpsAccess = value),
            ),
            _buildNavigationItem(
              'Preferred Travel Zones',
              'Set zones for relevant road condition updates',
              () => _showTravelZones(),
            ),

            const SizedBox(height: 24),

            // Edit Profile Section
            _buildSectionHeader('Edit Profile'),
            const SizedBox(height: 8),
            _buildNavigationItem('Edit Profile', '', () => _editProfile()),
            _buildNavigationItem(
              'Sign Out',
              '',
              () => _signOut(),
              isDestructive: true,
            ),

            const SizedBox(height: 24),

            // Privacy & Permissions Section
            _buildSectionHeader('Privacy & Permissions'),
            const SizedBox(height: 8),
            _buildNavigationItem(
              'Data Usage Policy',
              '',
              () => _showDataUsagePolicy(),
            ),
            _buildNavigationItem(
              'Manage App Permissions',
              '',
              () => _managePermissions(),
            ),
            _buildToggleItem(
              'Background Data Sync',
              'Control background data synchronization',
              _backgroundDataSync,
              (value) => setState(() => _backgroundDataSync = value),
            ),

            const SizedBox(height: 24),

            // Help & Support Section
            _buildSectionHeader('Help & Support'),
            const SizedBox(height: 8),
            _buildNavigationItem('FAQ', '', () => _showFAQ()),
            _buildNavigationItem(
              'Contact Support',
              '',
              () => _contactSupport(),
            ),
            _buildNavigationItem('Report an Issue', '', () => _reportIssue()),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1A237E),
            activeTrackColor: const Color(0xFF1A237E).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDestructive ? Colors.red : Colors.black87,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handler methods for various settings
  void _showAlertSoundOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert Sound Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Default'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Chime'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Bell'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Notification'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Language Preferences'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Français'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Ewondo'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTravelZones() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Travel Zones feature coming soon!')),
    );
  }

  void _editProfile() async {
    // Navigate to edit profile page with all required parameters
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfilePage(
              fullName: _userFullName,
              phoneNumber: _userPhoneNumber,
              selectedLanguage: _userSelectedLanguage,
              selectedAlertType: _userSelectedAlertType,
              roadHazardAlerts: _userRoadHazardAlerts,
              locationTracking: _userLocationTracking,
              roadSignTips: _userRoadSignTips,
            ),
      ),
    );

    // Handle the returned data from EditProfilePage
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _userFullName = result['fullName'] ?? _userFullName;
        _userPhoneNumber = result['phoneNumber'] ?? _userPhoneNumber;
        _userSelectedLanguage =
            result['selectedLanguage'] ?? _userSelectedLanguage;
        _userSelectedAlertType =
            result['selectedAlertType'] ?? _userSelectedAlertType;
        _userRoadHazardAlerts =
            result['roadHazardAlerts'] ?? _userRoadHazardAlerts;
        _userLocationTracking =
            result['locationTracking'] ?? _userLocationTracking;
        _userRoadSignTips = result['roadSignTips'] ?? _userRoadSignTips;
      });
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle sign out logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out successfully')),
                );
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDataUsagePolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data Usage Policy feature coming soon!')),
    );
  }

  void _managePermissions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage Permissions feature coming soon!')),
    );
  }

  void _showFAQ() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('FAQ feature coming soon!')));
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact Support feature coming soon!')),
    );
  }

  void _reportIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report Issue feature coming soon!')),
    );
  }
}
