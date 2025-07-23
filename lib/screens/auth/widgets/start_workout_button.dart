import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/workout_tracker.dart';
import 'package:game/screens/auth/widgets/start_workout_home.dart';
import 'package:game/screens/auth/widgets/exercise.dart';

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

    // Push to StartWorkoutHome and wait for result
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => StartWorkoutHome(
          workout: widget.workout,
        ),
      ),
    );

    // Check what came back
    if (result != null) {
  final updatedExercises = result['exercises'] as List<Exercise>;
  final finished = result['finished'] as bool;
  final duration = result['duration'] as int? ?? 0;

  setState(() {
    widget.workout.exercises = updatedExercises;

    if (finished) {
      widget.workout.timesCompleted++;
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
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 60,
        width: 120,
        decoration: BoxDecoration(
          color: _isTapped ? Colors.white : Colors.grey[200],
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Start Workout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
