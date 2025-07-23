import 'package:flutter/foundation.dart';
import 'exercise.dart';

class WorkoutProvider extends ChangeNotifier {
  String name = '';
  String description = '';
  List<Exercise> exercises = [];

  bool isWorkoutActive = false;

  void startWorkout({
    required String newName,
    required String newDescription,
    required List<Exercise> newExercises,
  }) {
    name = newName;
    description = newDescription;
    exercises = newExercises;
    isWorkoutActive = true;
    notifyListeners();
  }

  void addSet(int exerciseIndex) {
    exercises[exerciseIndex].sets.add(ExerciseSet(reps:exerciseIndex, weight: 0));
    notifyListeners();
  }

  void toggleSetCompleted(int exerciseIndex, int setIndex) {
    // Optional: You could add a 'completed' flag to ExerciseSet and toggle here
    notifyListeners();
  }

  void finishWorkout() {
    isWorkoutActive = false;
    name = '';
    description = '';
    exercises = [];
    notifyListeners();
  }

  // Add more helper methods like update reps/weight if needed
}
