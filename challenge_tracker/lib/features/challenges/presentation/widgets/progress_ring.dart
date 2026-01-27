import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// Circular progress indicator for challenge completion visualization
class ProgressRing extends StatelessWidget {
  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Text to display in the center (typically day count)
  final String centerText;

  /// Size of the progress ring (diameter)
  final double size;

  /// Color of the progress indicator
  final Color? progressColor;

  /// Color of the background circle
  final Color? backgroundColor;

  /// Line width of the progress ring
  final double lineWidth;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.centerText,
    this.size = 80.0,
    this.progressColor,
    this.backgroundColor,
    this.lineWidth = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: lineWidth,
      percent: progress.clamp(0.0, 1.0),
      center: Text(
        centerText,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      progressColor: progressColor ?? colorScheme.primary,
      backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 600,
    );
  }
}
