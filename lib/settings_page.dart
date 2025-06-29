 // lib/settings_page.dart (Fixed)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_profile_page.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/main.dart';
import 'settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Keep other settings state variables if they are not migrated to SettingsProvider
  bool _enableAlerts = true;
  bool _smsNotifications = true;
  bool _gpsAccess = true;
  bool _backgroundDataSync = false;

  // User profile data (keep if not managed by a separate provider)
  String _userFullName = 'John Doe';
  String _userPhoneNumber = '+1234567890';
  String _userSelectedLanguage = 'English';
  String _userSelectedAlertType = 'In-App Notification';
  bool _userRoadHazardAlerts = true; // This value needs to be passed
  bool _userLocationTracking = true; // This value needs to be passed
  bool _userRoadSignTips = false; // This value needs to be passed

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userSelectedLanguage = LocaleProvider.getLanguageStringFromLocale(
        Provider.of<LocaleProvider>(context, listen: false).locale ?? const Locale('en'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
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
            _buildSectionHeader(l10n.notificationsHeader),
            const SizedBox(height: 8),
            _buildToggleItem(
              l10n.enableAlerts,
              l10n.enableAlertsSubtitle,
              _enableAlerts,
              (value) => setState(() => _enableAlerts = value),
            ),
            _buildToggleItem(
              l10n.voiceAlerts,
              l10n.voiceAlertsSubtitle,
              settingsProvider.voiceAlerts,
              (value) => settingsProvider.setVoiceAlerts(value),
            ),
            _buildToggleItem(
              l10n.smsNotifications,
              l10n.smsNotificationsSubtitle,
              _smsNotifications,
              (value) => setState(() => _smsNotifications = value),
            ),
            _buildNavigationItem(
              l10n.alertSoundOptions,
              l10n.alertSoundOptionsSubtitle,
              () {
                // Navigate to Alert Sound Options
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.userPreferencesHeader),
            const SizedBox(height: 8),
            _buildNavigationItem(
              l10n.editProfile,
              l10n.editProfileSubtitle,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      fullName: _userFullName,
                      phoneNumber: _userPhoneNumber,
                      selectedLanguage: _userSelectedLanguage,
                      selectedAlertType: _userSelectedAlertType,
                      roadHazardAlerts: _userRoadHazardAlerts, // ADDED THIS LINE
                      locationTracking: _userLocationTracking, // ADDED THIS LINE
                      roadSignTips: _userRoadSignTips,       // ADDED THIS LINE
                    ),
                  ),
                );
              },
            ),
            _buildNavigationItem(
              l10n.language,
              _userSelectedLanguage,
              () {
                _showLanguagePickerDialog(context, localeProvider);
              },
            ),
            _buildNavigationItem(
              l10n.alertType,
              _userSelectedAlertType,
              () {
                // Navigate to Alert Type selection
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.permissionsHeader),
            const SizedBox(height: 8),
            _buildToggleItem(
              l10n.gpsAccess,
              l10n.gpsAccessSubtitle,
              _gpsAccess,
              (value) => setState(() => _gpsAccess = value),
            ),
            _buildToggleItem(
              l10n.backgroundDataSync,
              l10n.backgroundDataSyncSubtitle,
              _backgroundDataSync,
              (value) => setState(() => _backgroundDataSync = value),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.safetyFeaturesHeader),
            const SizedBox(height: 8),
            _buildToggleItem(
              l10n.roadHazardAlerts,
              l10n.roadHazardAlertsSubtitle,
              _userRoadHazardAlerts,
              (value) => setState(() => _userRoadHazardAlerts = value),
            ),
            _buildToggleItem(
              l10n.locationTracking,
              l10n.locationTrackingSubtitle,
              _userLocationTracking,
              (value) => setState(() => _userLocationTracking = value),
            ),
            _buildToggleItem(
              l10n.roadSignTips,
              l10n.roadSignTipsSubtitle,
              _userRoadSignTips,
              (value) => setState(() => _userRoadSignTips = value),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(l10n.accountActionsHeader),
            const SizedBox(height: 8),
            _buildNavigationItem(
              l10n.privacyPolicy,
              l10n.privacyPolicySubtitle,
              () {
                // Navigate to Privacy Policy
              },
            ),
            _buildNavigationItem(
              l10n.termsOfService,
              l10n.termsOfServiceSubtitle,
              () {
                // Navigate to Terms of Service
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.signedOutSuccessfully)),
                  );
                },
                child: Text(
                  l10n.signOut,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blueAccent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildNavigationItem(String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showLanguagePickerDialog(BuildContext context, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: localeProvider.locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    localeProvider.setLocale(value);
                    Navigator.pop(context);
                    setState(() {
                      _userSelectedLanguage = 'English';
                    });
                  }
                },
              ),
              RadioListTile<Locale>(
                title: const Text('Español'),
                value: const Locale('es'),
                groupValue: localeProvider.locale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    localeProvider.setLocale(value);
                    Navigator.pop(context);
                    setState(() {
                      _userSelectedLanguage = 'Español';
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}