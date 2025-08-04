import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/workoutTracker/workout_tracker.dart';
import 'package:game/screens/auth/home/views/workoutTracker/start_workout_home.dart';
import 'package:game/screens/auth/home/views/workoutTracker/exercise.dart';

class StartWorkoutButton extends StatefulWidget {
  final WorkoutStats workout;
  final void Function(int secondsElapsed)? onWorkoutFinished;

  const StartWorkoutButton({
    super.key,
    required this.workout,
    this.onWorkoutFinished,
  });

  @override
  State<StartWorkoutButton> createState() => _StartWorkoutButtonState();
}

class _StartWorkoutButtonState extends State<StartWorkoutButton> {
  bool _isTapped = false;

  Future<void> _handleTap() async {
  setState(() {
    _isTapped = true;
  });

  await Future.delayed(const Duration(milliseconds: 200));

  setState(() {
    _isTapped = false;
  });

  final result = await Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(
      builder: (_) => StartWorkoutHome(workout: widget.workout),
    ),
  );

  if (result != null) {
    final rawExercises = result['exercises'];
    final finished = result['finished'] as bool? ?? false;
    final duration = result['duration'] as int? ?? 0;

    List<Exercise> updatedExercises = [];

    if (rawExercises is List) {
      updatedExercises = rawExercises.map((e) {
        if (e is Exercise) return e;
        if (e is Map<String, dynamic>) return Exercise.fromMap(e);
        throw const FormatException('Invalid exercise format');
      }).toList();
    }

    setState(() {
      widget.workout.exercises = updatedExercises;

      if (finished) {
        widget.workout.daysSinceLast = 0;

        if (widget.onWorkoutFinished != null) {
          widget.onWorkoutFinished!(duration);
        }
      }
    });
  }
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
          color: _isTapped
              ? colorScheme.onPrimary // Typically a highlight color on tap
              : colorScheme.surfaceContainerHighest, // subtle background color
          border: Border.all(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'Start Workout',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
