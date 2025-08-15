import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game/screens/auth/home/views/workoutTracker/workout_tracker.dart';
import 'package:game/screens/auth/home/views/workoutTracker/exercise.dart';

bool isUserMoving = true;
StreamSubscription? accelerometerSubscription;
DateTime lastMotionDetected = DateTime.now();
DateTime lastUserInteraction = DateTime.now(); // <-- Added

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

  DateTime? startTime;
  DateTime? endTime;
  Duration elapsed = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initializeWorkoutData();
    
    startStopwatch();
  }
  int getWorkoutSeconds(DateTime? startTime, DateTime? endTime) {
  if (startTime != null && endTime != null) {
    return endTime.difference(startTime).inSeconds;
  }
  return 0;
}

Future<int> findTotalVolume() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || widget.workout.id == null) return 0;

  final workoutDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('workouts')
      .doc(widget.workout.id);

  final docSnapshot = await workoutDoc.get();
  if (!docSnapshot.exists) return 0;

  final workoutData = docSnapshot.data()!;
  final exercises = List<Map<String, dynamic>>.from(workoutData['exercises'] ?? []);

  int totalVolume = 0;

  for (var exercise in exercises) {
    final sets = List<Map<String, dynamic>>.from(exercise['sets'] ?? []);
    for (var set in sets) {
      final int? reps = set['reps'];
      final int? weight = set['weight'];
      if (reps != null && weight != null) {
        totalVolume += reps * weight;
      }
    }
  }

  // ✅ Store totalVolume in this workout document
  await workoutDoc.set({
    'totalVolume': totalVolume,
  }, SetOptions(merge: true)); // merge ensures it doesn't overwrite other fields

  return totalVolume;
}






  bool hasRecentInteraction() {
    return DateTime.now().difference(lastUserInteraction) < const Duration(minutes: 3);
  }

  void startStopwatch() {
    startTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (startTime != null && isUserMoving && hasRecentInteraction()) {
        setState(() {
          elapsed = DateTime.now().difference(startTime!);
        });
      }
    });
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

    repsControllers = exercises.map((e) {
      return e.sets.map((s) {
        return TextEditingController(text: s.reps?.toString() ?? '');
      }).toList();
    }).toList();

    weightControllers = exercises.map((e) {
      return e.sets.map((s) {
        return TextEditingController(text: s.weight?.toString() ?? '');
      }).toList();
    }).toList();
  }

  @override
  void dispose() {
    timer?.cancel();
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
    accelerometerSubscription?.cancel();
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
    if (exercises[exerciseIndex].sets.length <= 1) return;

    setState(() {
      exercises[exerciseIndex].sets.removeAt(setIndex);
      repsControllers[exerciseIndex][setIndex].dispose();
      weightControllers[exerciseIndex][setIndex].dispose();
      repsControllers[exerciseIndex].removeAt(setIndex);
      weightControllers[exerciseIndex].removeAt(setIndex);
    });
  }

  void finishSet(int exerciseIndex, int setIndex) {
    lastUserInteraction = DateTime.now();
    setState(() {
      final set = exercises[exerciseIndex].sets[setIndex];
      set.isComplete = !set.isComplete;
    });

    final isComplete = exercises[exerciseIndex].sets[setIndex].isComplete;
    updateSetCompletionStatus(exerciseIndex, setIndex, isComplete);
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
      elapsed = Duration.zero;
      startTime = null;
      for (var exercise in exercises) {
        for (var set in exercise.sets) {
          set.isComplete = false;
        }
      }
      initializeWorkoutData();
    });
  }
  

  void finishWorkout({required bool finished}) async {
  final secondsWorkedOut = elapsed.inSeconds;

  Navigator.of(context).pop({
    'finished': finished,
    'duration': secondsWorkedOut,
    'exercises': exercises,
  });

  if (finished) {
    await checkTimerTime(Duration(seconds: secondsWorkedOut));
    resetWorkout();
  }
}



  Future<void> updateSetCompletionStatus(int exerciseIndex, int setIndex, bool isComplete) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.workout.id == null) return;

    final workoutDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .doc(widget.workout.id);

    final docSnapshot = await workoutDoc.get();
    if (!docSnapshot.exists) return;

    final workoutData = docSnapshot.data()!;
    final exercisesData = List<Map<String, dynamic>>.from(workoutData['exercises'] ?? []);

    if (exerciseIndex >= exercisesData.length) return;

    final exerciseData = Map<String, dynamic>.from(exercisesData[exerciseIndex]);
    final setsData = List<Map<String, dynamic>>.from(exerciseData['sets'] ?? []);

    if (setIndex >= setsData.length) return;

    setsData[setIndex]['isComplete'] = isComplete;
    exerciseData['sets'] = setsData;
    exercisesData[exerciseIndex] = exerciseData;

    workoutData['exercises'] = exercisesData;

    await workoutDoc.set(workoutData);
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$secs';
    }
    return '$minutes:$secs';
  }

  Widget finishButton() {
    final theme = Theme.of(context);
    return FloatingActionButton.extended(
      onPressed: () {
        completeAllRemainingSets();
        finishWorkout(finished: true);
      },
      icon: const Icon(Icons.done_all),
      label: const Text('Finish All'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return WillPopScope(
      onWillPop: () async {
        finishWorkout(finished: false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.workout.name,
            style: const TextStyle(fontSize: 24, color: Colors.green),
          ),
          backgroundColor: colorScheme.onPrimary,
          iconTheme: IconThemeData(color: theme.colorScheme.primary),
          titleTextStyle: TextStyle(color: theme.colorScheme.onSurface),
          elevation: 1,
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              formatTime(elapsed),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(thickness: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exercises.length,
                itemBuilder: (context, exerciseIndex) {
                  final exercise = exercises[exerciseIndex];
                  return Card(
                    color: colorScheme.onPrimary,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: exercise.sets.length,
                            itemBuilder: (context, setIndex) {
                              final set = exercise.sets[setIndex];
                              final repsController = repsControllers[exerciseIndex][setIndex];
                              final weightController = weightControllers[exerciseIndex][setIndex];

                              final fillColor = set.isComplete
                                  ? theme.colorScheme.secondaryContainer
                                  : null;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: repsController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Reps',
                                          border: const OutlineInputBorder(),
                                          filled: set.isComplete,
                                          fillColor: fillColor,
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            set.reps = val.isEmpty ? null : int.tryParse(val);
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: weightController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: 'Weight',
                                          suffixText: 'lbs',
                                          border: const OutlineInputBorder(),
                                          filled: set.isComplete,
                                          fillColor: fillColor,
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            set.weight = val.isEmpty ? null : int.tryParse(val);
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color: set.isComplete
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: () => finishSet(exerciseIndex, setIndex),
                                      tooltip: set.isComplete ? 'Mark as incomplete' : 'Mark as complete',
                                    ),
                                    if (exercise.sets.length > 1)
                                      IconButton(
                                        icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                        onPressed: () => removeSet(exerciseIndex, setIndex),
                                        tooltip: 'Remove set',
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
          child: finishButton(),
        ),
      ),
    );
  }
}
Future<bool> checkTimerTime(Duration elapsed) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final docSnapshot = await docRef.get();

  final alreadyAchieved = docSnapshot.data()?['twoHourWorkout'] ?? false;

  // Only update if not already true and workout is over 2 hours
  if (!alreadyAchieved && elapsed.inSeconds >= 7200) {
    await docRef.set({'twoHourWorkout': true}, SetOptions(merge: true));
    return true;
  }

  return alreadyAchieved;
}