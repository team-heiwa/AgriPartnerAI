import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkMode = false;
  String _language = 'ja';
  String _units = 'metric';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildSectionHeader('Profile'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            title: const Text('John Farmer'),
            subtitle: const Text('john.farmer@agripartner.com'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showProfileDialog,
          ),
          const Divider(),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_language == 'ja' ? 'Japanese' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),
          ListTile(
            title: const Text('Units'),
            subtitle: Text(_units == 'metric' ? 'Metric' : 'Imperial'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showUnitsDialog,
          ),
          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts and updates'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Notification Settings'),
            subtitle: const Text('Configure alert types'),
            trailing: const Icon(Icons.chevron_right),
            enabled: _notificationsEnabled,
            onTap: _notificationsEnabled ? _showNotificationSettings : null,
          ),
          const Divider(),

          // Privacy Section
          _buildSectionHeader('Privacy & Security'),
          SwitchListTile(
            title: const Text('Location Services'),
            subtitle: const Text('Allow app to access location'),
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Data & Privacy'),
            subtitle: const Text('Manage your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showDataPrivacyDialog,
          ),
          ListTile(
            title: const Text('Security'),
            subtitle: const Text('PIN, biometrics, and more'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showSecurityDialog,
          ),
          const Divider(),

          // App Information
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Build 100)'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTermsOfService,
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPrivacyPolicy,
          ),
          ListTile(
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showHelpSupport,
          ),
          const Divider(),

          // Actions
          _buildSectionHeader('Account'),
          ListTile(
            title: const Text('Sign Out'),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: _signOut,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: 'John Farmer'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: 'john.farmer@agripartner.com'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Japanese'),
              value: 'ja',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Metric (km, kg, °C)'),
              value: 'metric',
              groupValue: _units,
              onChanged: (value) {
                setState(() {
                  _units = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Imperial (mi, lb, °F)'),
              value: 'imperial',
              groupValue: _units,
              onChanged: (value) {
                setState(() {
                  _units = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  void _showDataPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data & Privacy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Download My Data'),
              subtitle: const Text('Get a copy of your data'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data export requested')),
                );
              },
            ),
            ListTile(
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete your account'),
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteAccount();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SecuritySettingsScreen(),
      ),
    );
  }

  void _showTermsOfService() {
    // Open terms of service
  }

  void _showPrivacyPolicy() {
    // Open privacy policy
  }

  void _showHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpSupportScreen(),
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform sign out
              context.go('/dashboard');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform account deletion
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _alertsEnabled = true;
  bool _droneUpdates = true;
  bool _weatherAlerts = true;
  bool _reportReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Field Alerts'),
            subtitle: const Text('Pest, disease, and health alerts'),
            value: _alertsEnabled,
            onChanged: (value) {
              setState(() {
                _alertsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Drone Updates'),
            subtitle: const Text('Flight status and completion'),
            value: _droneUpdates,
            onChanged: (value) {
              setState(() {
                _droneUpdates = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Weather Alerts'),
            subtitle: const Text('Severe weather warnings'),
            value: _weatherAlerts,
            onChanged: (value) {
              setState(() {
                _weatherAlerts = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Report Reminders'),
            subtitle: const Text('Weekly report generation'),
            value: _reportReminders,
            onChanged: (value) {
              setState(() {
                _reportReminders = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricsEnabled = false;
  bool _pinEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face ID'),
            value: _biometricsEnabled,
            onChanged: (value) {
              setState(() {
                _biometricsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('PIN Lock'),
            subtitle: const Text('Require PIN to access app'),
            value: _pinEnabled,
            onChanged: (value) {
              setState(() {
                _pinEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Change PIN'),
            trailing: const Icon(Icons.chevron_right),
            enabled: _pinEnabled,
            onTap: _pinEnabled ? () {} : null,
          ),
          const Divider(),
          ListTile(
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Not enabled'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('User Guide'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Contact Support'),
            subtitle: const Text('support@agripartner.com'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Live Chat'),
            subtitle: const Text('Available 9 AM - 5 PM JST'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}