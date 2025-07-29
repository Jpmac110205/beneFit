import 'package:flutter/material.dart';

class TrackCaloriesHome extends StatefulWidget {
  const TrackCaloriesHome({super.key});

  @override
  State<TrackCaloriesHome> createState() => _TrackCaloriesHomeState();
}

class _TrackCaloriesHomeState extends State<TrackCaloriesHome> {
  bool _isTapped = false;

  void _handleTap() async {
    setState(() {
      _isTapped = true;
    });

    // Wait for a short duration (e.g., 200 ms)
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _isTapped = false;
    });

    // TODO: Add your actual logic here, like opening a new screen
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 60,
        width: 120,
        decoration: BoxDecoration(
          color: _isTapped ? colorScheme.onPrimary : colorScheme.surfaceContainerHighest,
          border: Border.all(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'Track Calories',
          style: theme.textTheme.labelMedium?.copyWith(
            color: _isTapped ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
