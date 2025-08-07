import 'package:flutter/foundation.dart';
import 'exercise.dart';

class WorkoutProvider extends ChangeNotifier {
  String name = '';
  String description = '';
  List<Exercise> exercises = [];

  bool isWorkoutActive = false;

  DateTime? _startTime;
  Duration _elapsed = Duration.zero;

  Duration get elapsed => _elapsed;
  int get secondsWorkedOut => _elapsed.inSeconds;

  void startWorkout({
    required String newName,
    required String newDescription,
    required List<Exercise> newExercises,
  }) {
    name = newName;
    description = newDescription;
    exercises = newExercises;
    isWorkoutActive = true;
    _startTime = DateTime.now();
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void addSet(int exerciseIndex) {
    exercises[exerciseIndex].sets.add(ExerciseSet(reps: 0, weight: 0));
    notifyListeners();
  }

  void toggleSetCompleted(int exerciseIndex, int setIndex) {
    // Optional: Implement if sets can be marked complete
    notifyListeners();
  }

  void finishWorkout() {
    if (_startTime != null) {
      _elapsed = DateTime.now().difference(_startTime!);
    }
    isWorkoutActive = false;
    name = '';
    description = '';
    exercises = [];
    _startTime = null;
    notifyListeners();
  }

  // Optional: Call this periodically to update UI
  void updateElapsed() {
    if (_startTime != null) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    }
  }
}
