import 'package:flutter/material.dart';

/// Pre-permission education dialog shown before requesting notification permission.
///
/// This dialog explains the value of notifications to increase acceptance rate.
/// Shows before the system permission prompt.
class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const NotificationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stay on Track'),
      content: const Text(
        'Get daily reminders to complete your challenges and keep your streak alive.\n\n'
        'You can customize reminder times or turn them off anytime in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: onDeny,
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: onAllow,
          child: const Text('Enable Reminders'),
        ),
      ],
    );
  }

  /// Show the dialog and return whether user wants to enable notifications.
  ///
  /// Returns true if user tapped "Enable Reminders", false if "Not Now".
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationPermissionDialog(
        onAllow: () => Navigator.pop(context, true),
        onDeny: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }
}
