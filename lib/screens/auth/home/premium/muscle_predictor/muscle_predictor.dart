import 'package:flutter/material.dart';

class MusclePredictor extends StatefulWidget {
  const MusclePredictor({super.key});

  @override
  State<MusclePredictor> createState() => _MusclePredictor();
}

class _MusclePredictor extends State<MusclePredictor> {
  bool _isTapped = false;

  void _handleTap() async {
    setState(() {
      _isTapped = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _isTapped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 60,
        width:  MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: _isTapped ? colorScheme.surfaceContainerHighest : colorScheme.onPrimary,
          border: Border.all(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
          'Muscle Predictor',
          style: theme.textTheme.labelMedium?.copyWith(
            color: _isTapped ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 5), // optional spacing
            Icon(
              Icons.star_border,
              color: _isTapped ? colorScheme.primary : colorScheme.onSurface,
            ),
          ],
          ),
      ),
    );
  }
}
