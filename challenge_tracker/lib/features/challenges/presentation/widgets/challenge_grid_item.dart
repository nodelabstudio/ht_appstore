import 'package:flutter/material.dart';
import '../../data/models/challenge.dart';
import '../../data/models/challenge_pack.dart';
import '../../../../core/utils/streak_calculator.dart';
import 'progress_ring.dart';

/// Single challenge tile in the home screen grid
class ChallengeGridItem extends StatelessWidget {
  /// The challenge to display
  final Challenge challenge;

  /// Callback when tile is tapped
  final VoidCallback onTap;

  const ChallengeGridItem({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final pack = ChallengePack.getById(challenge.packId);
    final emoji = pack?.emoji ?? '🎯';
    final isCompletedToday =
        StreakCalculator.isCompletedToday(challenge.completionDatesUtc);
    final streak = StreakCalculator.calculateStreak(
      challenge.completionDatesUtc,
      challenge.startDateUtc,
    );

    return Card(
      elevation: isCompletedToday ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompletedToday
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: emoji and completion indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  if (isCompletedToday)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),

              // Center: Progress ring with day count
              Expanded(
                child: Center(
                  child: ProgressRing(
                    progress: challenge.progress,
                    centerText: '${challenge.completedDays}',
                    size: 70,
                    lineWidth: 6,
                    progressColor: isCompletedToday
                        ? colorScheme.primary
                        : colorScheme.secondary,
                  ),
                ),
              ),

              // Bottom: Challenge name and streak
              Column(
                children: [
                  Text(
                    challenge.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildStreakIndicator(context, streak, isCompletedToday),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakIndicator(
    BuildContext context,
    int streak,
    bool isCompletedToday,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (streak == 0) {
      return Text(
        'Start today!',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: 16,
          color: isCompletedToday
              ? Colors.orange
              : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '$streak day${streak == 1 ? '' : 's'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isCompletedToday
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: isCompletedToday ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
