import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/workoutTracker/create_new_workout.dart';
import 'package:game/screens/auth/home/views/workoutTracker/workout_tracker.dart';

class AddWorkoutButton extends StatefulWidget {
  final Function(WorkoutStats) onWorkoutAdded;

  const AddWorkoutButton({super.key, required this.onWorkoutAdded});

  @override
  State<AddWorkoutButton> createState() => _AddWorkoutButtonState();
}

class _AddWorkoutButtonState extends State<AddWorkoutButton> {
  bool _isTapped = false;

  void _handleTap() async {
    setState(() {
      _isTapped = true;
    });

    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      _isTapped = false;
    });

    final newWorkout = await showModalBottomSheet<WorkoutStats>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.95,
        child: CreateNewWorkout(),
      ),
    );

    if (newWorkout != null) {
      widget.onWorkoutAdded(newWorkout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 80,
        width: 160,
        decoration: BoxDecoration(
          color: _isTapped ? colorScheme.onPrimary : colorScheme.primary,
          border: Border.all(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'Add Workout',
          style: TextStyle(
            color: _isTapped ? colorScheme.primary : colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
