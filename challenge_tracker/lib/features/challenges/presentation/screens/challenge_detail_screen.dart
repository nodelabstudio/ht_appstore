import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/streak_calculator.dart';
import '../../data/models/challenge_pack.dart';
import '../notifiers/challenge_list_notifier.dart';

/// Challenge detail screen showing progress, streak, and completion controls.
/// Implements CHAL-05, COMP-01, COMP-03 from requirements.
class ChallengeDetailScreen extends ConsumerWidget {
  final String challengeId;

  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(challengeByIdProvider(challengeId));

    if (challenge == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Challenge'),
        ),
        body: const Center(
          child: Text('Challenge not found'),
        ),
      );
    }

    final pack = ChallengePack.getById(challenge.packId);
    final emoji = pack?.emoji ?? '?';
    final isCompletedToday = StreakCalculator.isCompletedToday(
      challenge.completionDatesUtc,
    );
    final currentStreak = StreakCalculator.calculateStreak(
      challenge.completionDatesUtc,
      challenge.startDateUtc,
    );
    final startDateFormatted = AppDateUtils.formatDate(challenge.startDateUtc);

    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pack emoji - large
              Text(
                emoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 24),

              // Large progress ring (200px)
              CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 12.0,
                percent: challenge.progress.clamp(0.0, 1.0),
                center: Text(
                  '${challenge.completedDays}/30',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                progressColor: isCompletedToday
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 500,
              ),
              const SizedBox(height: 24),

              // Day X of 30
              Text(
                'Day ${challenge.currentDay} of 30',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              // Streak count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '$currentStreak day streak',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Start date
              Text(
                'Started $startDateFormatted',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              // Reminder toggle
              const Divider(height: 32),
              _ReminderToggle(
                challengeId: challengeId,
                reminderTimeMinutes: challenge.reminderTimeMinutes,
              ),
              const SizedBox(height: 16),

              // Completion state and controls
              if (isCompletedToday) ...[
                // Completed today state
                _CompletedTodayBadge(),
                const SizedBox(height: 16),
                _UndoButton(
                  challengeId: challengeId,
                  onUndo: () => _handleUndo(context, ref),
                ),
              ] else ...[
                // Not completed - show Done button
                _DoneButton(
                  challengeId: challengeId,
                  onDone: () => _handleMarkComplete(context, ref),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMarkComplete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(challengeListProvider.notifier).markComplete(challengeId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge completed for today!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUndo(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(challengeListProvider.notifier)
          .undoTodayCompletion(challengeId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completion undone'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// "Completed Today!" badge shown after completion
class _CompletedTodayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'Completed Today!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Large prominent Done button for marking completion
class _DoneButton extends StatelessWidget {
  final String challengeId;
  final VoidCallback onDone;

  const _DoneButton({
    required this.challengeId,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onDone,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Done',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Secondary Undo button for reverting same-day completion
class _UndoButton extends StatelessWidget {
  final String challengeId;
  final VoidCallback onUndo;

  const _UndoButton({
    required this.challengeId,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onUndo,
      icon: const Icon(Icons.undo),
      label: const Text('Undo'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade600,
      ),
    );
  }
}

/// Toggle for per-challenge daily reminder notification
class _ReminderToggle extends ConsumerWidget {
  final String challengeId;
  final int? reminderTimeMinutes;

  const _ReminderToggle({
    required this.challengeId,
    required this.reminderTimeMinutes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReminder = reminderTimeMinutes != null;

    return Row(
      children: [
        Icon(
          Icons.notifications_outlined,
          color: hasReminder
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Reminder',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (hasReminder)
                Text(
                  AppDateUtils.formatReminderTime(reminderTimeMinutes!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
            ],
          ),
        ),
        Switch(
          value: hasReminder,
          onChanged: (enabled) async {
            if (enabled) {
              final picked = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 9, minute: 0),
                helpText: 'Set Daily Reminder',
              );
              if (picked != null) {
                final minutes = AppDateUtils.timeOfDayToMinutes(picked);
                await ref
                    .read(challengeListProvider.notifier)
                    .updateReminderTime(challengeId, minutes);
              }
            } else {
              await ref
                  .read(challengeListProvider.notifier)
                  .updateReminderTime(challengeId, null);
            }
          },
        ),
      ],
    );
  }
}
