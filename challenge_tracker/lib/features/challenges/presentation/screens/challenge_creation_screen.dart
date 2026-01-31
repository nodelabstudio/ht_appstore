import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/challenge_pack.dart';
import '../../presentation/notifiers/challenge_list_notifier.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../notifications/presentation/widgets/notification_permission_dialog.dart';
import '../../../notifications/data/services/notification_service.dart';

/// Screen for creating a new challenge from a selected pack
class ChallengeCreationScreen extends ConsumerStatefulWidget {
  /// The selected challenge pack
  final ChallengePack pack;

  const ChallengeCreationScreen({
    super.key,
    required this.pack,
  });

  @override
  ConsumerState<ChallengeCreationScreen> createState() =>
      _ChallengeCreationScreenState();
}

class _ChallengeCreationScreenState
    extends ConsumerState<ChallengeCreationScreen> {
  late DateTime _startDate;
  TimeOfDay? _reminderTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to today
    _startDate = DateTime.now();
    // Normalize to midnight
    _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Challenge'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pack info card
              _buildPackInfoCard(theme, colorScheme),
              const SizedBox(height: 24),

              // Start date section
              Text(
                'Start Date',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildDatePicker(theme, colorScheme),
              const SizedBox(height: 24),

              // Reminder section
              Text(
                'Daily Reminder (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildTimePicker(theme, colorScheme),
              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createChallenge,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Start Challenge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackInfoCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.pack.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pack.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.pack.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppDateUtils.formatDate(
                    _startDate.toUtc().millisecondsSinceEpoch ~/ 1000),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: _selectTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: _reminderTime != null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _reminderTime != null
                    ? AppDateUtils.formatReminderTime(
                        AppDateUtils.timeOfDayToMinutes(_reminderTime!))
                    : 'No reminder set',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _reminderTime != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (_reminderTime != null)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _reminderTime = null;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    final oneYearFromNow = today.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: thirtyDaysAgo,
      lastDate: oneYearFromNow,
      helpText: 'Select Start Date',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Set Daily Reminder',
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _createChallenge() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert start date to UTC timestamp (seconds since epoch)
      final startDateUtc = _startDate.toUtc().millisecondsSinceEpoch ~/ 1000;

      // Convert reminder time to minutes since midnight (if set)
      int? finalReminderTimeMinutes = _reminderTime != null
          ? AppDateUtils.timeOfDayToMinutes(_reminderTime!)
          : null;

      // Request notification permission if reminder time is set
      if (finalReminderTimeMinutes != null && mounted) {
        final userConsented =
            await NotificationPermissionDialog.show(context);
        if (userConsented) {
          final granted = await NotificationService().requestPermission();
          if (!granted) {
            finalReminderTimeMinutes = null;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Notification permission denied. Reminder not set. '
                    'You can enable notifications in iOS Settings.',
                  ),
                ),
              );
            }
          }
        } else {
          finalReminderTimeMinutes = null;
        }
      }

      // Create the challenge
      await ref.read(challengeListProvider.notifier).createChallenge(
            pack: widget.pack,
            startDateUtc: startDateUtc,
            reminderTimeMinutes: finalReminderTimeMinutes,
          );

      // Pop back to home screen on success
      if (mounted) {
        // Pop both creation and selection screens
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create challenge: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
