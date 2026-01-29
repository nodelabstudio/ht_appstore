import 'package:flutter/material.dart';
import '../../../notifications/data/services/notification_service.dart';

/// Minimal settings screen for Phase 2.
/// Phase 3 will expand with restore purchases, support, legal links.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = NotificationService().globalEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: Text(
              _notificationsEnabled
                  ? 'Daily reminders are enabled'
                  : 'All reminders are disabled',
            ),
            secondary: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _notificationsEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            value: _notificationsEnabled,
            onChanged: (enabled) async {
              final messenger = ScaffoldMessenger.of(context);
              setState(() {
                _notificationsEnabled = enabled;
              });
              if (!enabled) {
                await NotificationService().cancelAllNotifications();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('All reminders disabled'),
                  ),
                );
              } else {
                NotificationService().setGlobalEnabled(true);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Reminders enabled. Set reminder times on each challenge.',
                    ),
                  ),
                );
              }
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
