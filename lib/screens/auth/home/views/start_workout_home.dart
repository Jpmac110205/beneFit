import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/workout_tracker.dart';
import 'package:game/screens/auth/widgets/exercise.dart';

class StartWorkoutHome extends StatefulWidget {
  final WorkoutStats workout;

  const StartWorkoutHome({super.key, required this.workout});

  @override
  State<StartWorkoutHome> createState() => _StartWorkoutHomeState();
}

class _StartWorkoutHomeState extends State<StartWorkoutHome> {
  late List<Exercise> exercises;
  late List<List<TextEditingController>> repsControllers;
  late List<List<TextEditingController>> weightControllers;

  late Timer timer;
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    initializeWorkoutData();
    startStopwatch();
  }

  void initializeWorkoutData() {
    exercises = widget.workout.exercises.map((e) {
      return Exercise(
        name: e.name,
        sets: e.sets.map((s) {
          return ExerciseSet(
            reps: s.reps,
            weight: s.weight,
            isComplete: s.isComplete,
          );
        }).toList(),
      );
    }).toList();

    repsControllers = exercises
        .map((e) => e.sets
            .map((s) => TextEditingController(text: s.reps?.toString() ?? ''))
            .toList())
        .toList();

    weightControllers = exercises
        .map((e) => e.sets
            .map((s) => TextEditingController(text: s.weight?.toString() ?? ''))
            .toList())
        .toList();
  }

  void startStopwatch() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void stopStopwatch() {
    timer.cancel();
  }



  @override
  void dispose() {
    stopStopwatch();
    for (var list in repsControllers) {
      for (var controller in list) {
        controller.dispose();
      }
    }
    for (var list in weightControllers) {
      for (var controller in list) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void addSet(int exerciseIndex) {
    setState(() {
      exercises[exerciseIndex].sets.add(ExerciseSet(reps: null, weight: null));
      repsControllers[exerciseIndex].add(TextEditingController());
      weightControllers[exerciseIndex].add(TextEditingController());
    });
  }

  void removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      if (exercises[exerciseIndex].sets.length > 1) {
        exercises[exerciseIndex].sets.removeAt(setIndex);
        repsControllers[exerciseIndex][setIndex].dispose();
        weightControllers[exerciseIndex][setIndex].dispose();
        repsControllers[exerciseIndex].removeAt(setIndex);
        weightControllers[exerciseIndex].removeAt(setIndex);
      }
    });
  }

  void finishSet(int exerciseIndex, int setIndex) {
    setState(() {
      final set = exercises[exerciseIndex].sets[setIndex];
      set.isComplete = !set.isComplete;
    });
  }

  void completeAllRemainingSets() {
    setState(() {
      for (var exercise in exercises) {
        for (var set in exercise.sets) {
          set.isComplete = true;
        }
      }
    });
  }
  void resetWorkout() {
    setState(() {
      secondsElapsed = 0;
      for (var exercise in exercises) {
        for (var set in exercise.sets) {
          set.isComplete = false;
        }
      }
      initializeWorkoutData();
    });
  }

  void finishWorkout({required bool finished}) {
    stopStopwatch();
    Navigator.of(context).pop({
      'exercises': exercises,
      'finished': finished,
      'duration': secondsElapsed,
    });
    resetWorkout();
  }

  Widget finishButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        completeAllRemainingSets();
        finishWorkout(finished: true);
      },
      icon: const Icon(Icons.done_all),
      label: const Text('Finish All'),
      backgroundColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        finishWorkout(finished: false);
        return false; // prevent default pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.workout.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              formatTime(secondsElapsed),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const Divider(thickness: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exercises.length,
                itemBuilder: (context, exerciseIndex) {
                  final exercise = exercises[exerciseIndex];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: exercise.sets.length,
                            itemBuilder: (context, setIndex) {
                              final set = exercise.sets[setIndex];
                              final repsController =
                                  repsControllers[exerciseIndex][setIndex];
                              final weightController =
                                  weightControllers[exerciseIndex][setIndex];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: repsController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Reps',
                                          border:
                                              const OutlineInputBorder(),
                                          fillColor: set.isComplete
                                              ? Colors.green[100]
                                              : null,
                                          filled: set.isComplete,
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            set.reps = val.isEmpty
                                                ? null
                                                : int.tryParse(val);
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: weightController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                                decimal: true),
                                        decoration: InputDecoration(
                                          labelText: 'Weight',
                                          suffixText: 'lbs',
                                          border:
                                              const OutlineInputBorder(),
                                          fillColor: set.isComplete
                                              ? Colors.green[100]
                                              : null,
                                          filled: set.isComplete,
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            set.weight = val.isEmpty
                                                ? null
                                                : int.tryParse(val);
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color: set.isComplete
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      onPressed: () => finishSet(
                                          exerciseIndex, setIndex),
                                    ),
                                    if (exercise.sets.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => removeSet(
                                            exerciseIndex, setIndex),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Set'),
                              onPressed: () => addSet(exerciseIndex),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: finishButton(),
      ),
    );
  }
}
