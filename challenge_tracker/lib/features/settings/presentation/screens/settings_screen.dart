import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../notifications/data/services/notification_service.dart';
import '../../../monetization/data/constants/monetization_constants.dart';
import '../providers/theme_provider.dart';

/// Settings screen with theme toggle, notification toggle, restore purchases,
/// support, legal links, and dynamic version.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _notificationsEnabled;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = NotificationService().globalEnabled;
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
    });
  }

  Future<void> _restorePurchases() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.active
          .containsKey(MonetizationConstants.proEntitlementId)) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully!'),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No previous purchases found.'),
          ),
        );
      }
    } on PlatformException {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to restore purchases. Please try again.'),
        ),
      );
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: MonetizationConstants.supportEmail,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not find an email client to open.'),
          ),
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse(MonetizationConstants.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchTermsOfService() async {
    final uri = Uri.parse(MonetizationConstants.termsOfServiceUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Appearance'),
            dense: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.settings_system_daydream_outlined),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (newSelection) {
                ref.read(themeProvider.notifier).setThemeMode(newSelection.first);
              },
            ),
          ),
          const Divider(),
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
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Purchases'),
            onTap: _restorePurchases,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Contact Support'),
            subtitle: const Text(MonetizationConstants.supportEmail),
            onTap: _launchEmail,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: _launchPrivacyPolicy,
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: _launchTermsOfService,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text(_appVersion.isEmpty ? '...' : _appVersion),
          ),
        ],
      ),
    );
  }
}
