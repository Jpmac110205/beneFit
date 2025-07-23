import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game/screens/auth/widgets/workout_ranked_calc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: RankedScreen()));
}

class RankedScreen extends StatefulWidget {
  const RankedScreen({super.key});

  @override
  State<RankedScreen> createState() => _RankedScreenState();
}

class _RankedScreenState extends State<RankedScreen> {
  static const List<String> predefinedWorkoutNames = [
    'Deadlift',
    'Squat',
    'Bench Press',
    'Overhead Press',
    'Pull-Up',
  ];

  final List<String> rankOrder = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Master'];

  // ✅ Fix 1: Initialize using predefined workouts
  List<Ranked> workouts = _initialWorkouts();

  static List<Ranked> _initialWorkouts() {
    return predefinedWorkoutNames.map((exercise) {
      return Ranked(
        workout: exercise,
        liftWeight: 0,
        reps: 0,
        bodyWeight: 180,
      );
    }).toList();
  }

  List<BMI> bmiList = [BMI(weight: 180, height: 70)];
  String selectedWorkoutName = 'Deadlift';
  String currentDisplayRank = 'Bronze';
  int rankAnimationIndex = 0;
  bool isAnimating = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutsFromFirestore();
  }

  // ✅ Fix 2: Now sets isLoading = false at the end
  void _loadWorkoutsFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ranked')
        .get();

    final firestoreMap = {
      for (var doc in snapshot.docs)
        doc.id: Ranked(
          workout: doc.id,
          liftWeight: doc['liftWeight'] ?? 0,
          reps: doc['reps'] ?? 0,
          bodyWeight: doc['bodyWeight'] ?? 0,
        )
    };

    List<Ranked> merged = predefinedWorkoutNames.map((name) {
      return firestoreMap[name] ??
          Ranked(workout: name, liftWeight: 0, reps: 0, bodyWeight: 180);
    }).toList();

    setState(() {
      workouts = merged;
      _evaluateAllWorkouts();
      isLoading = false; 
    });
    animateToFinalRank(workouts.firstWhere((w) => w.workout == selectedWorkoutName).ranked);
  }

  void _evaluateAllWorkouts() {
    for (var workout in workouts) {
      final result = evaluateRank(
        liftWeight: workout.liftWeight,
        reps: workout.reps,
        bodyweight: workout.bodyWeight.toDouble(),
        exercise: workout.workout,
      );
      workout.ranked = result['rank'];
      workout.percentage = result['percentile'].toString();
    }
  }

  void animateToFinalRank(String finalRank) {
    if (isAnimating) return;
    isAnimating = true;
    rankAnimationIndex = 0;

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() => currentDisplayRank = rankOrder[rankAnimationIndex]);
      if (rankOrder[rankAnimationIndex] == finalRank) {
        timer.cancel();
        isAnimating = false;
      } else {
        rankAnimationIndex = (rankAnimationIndex + 1) % rankOrder.length;
      }
    });
  }

  void _editWorkout(Ranked workout) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final liftController = TextEditingController(text: workout.liftWeight.toString());
    final bodyController = TextEditingController(text: workout.bodyWeight.toString());
    final repsController = TextEditingController(text: workout.reps.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${workout.workout}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: bodyController, decoration: const InputDecoration(labelText: 'Bodyweight (lbs)'), keyboardType: TextInputType.number),
            TextField(controller: liftController, decoration: const InputDecoration(labelText: 'Lift Weight (lbs)'), keyboardType: TextInputType.number),
            TextField(controller: repsController, decoration: const InputDecoration(labelText: 'Reps'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() {
                workout.bodyWeight = int.tryParse(bodyController.text) ?? 0;
                workout.liftWeight = int.tryParse(liftController.text) ?? 0;
                workout.reps = int.tryParse(repsController.text) ?? 0;

                final result = evaluateRank(
                  liftWeight: workout.liftWeight,
                  reps: workout.reps,
                  bodyweight: workout.bodyWeight.toDouble(),
                  exercise: workout.workout,
                );
                workout.ranked = result['rank'];
                workout.percentage = result['percentile'].toString();
              });

              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('ranked')
                    .doc(workout.workout)
                    .set({
                  'liftWeight': workout.liftWeight,
                  'reps': workout.reps,
                  'bodyWeight': workout.bodyWeight,
                });
              }

              Navigator.of(context).pop();

              // ✅ Trigger the animation after saving
              animateToFinalRank(workout.ranked);
            },

            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              animateToFinalRank(workout.ranked);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _editBMI(int index) {
    final weightController = TextEditingController(text: bmiList[index].weight.toString());
    final heightController = TextEditingController(text: bmiList[index].height.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit BMI Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (lbs)')),
            TextField(controller: heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (inches)')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                final weight = int.tryParse(weightController.text) ?? 0;
                final height = int.tryParse(heightController.text) ?? 0;
                bmiList[index] = BMI(weight: weight, height: height);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final selectedWorkout = workouts.firstWhere((w) => w.workout == selectedWorkoutName);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('Ranked Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedWorkoutName,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Select Workout', border: OutlineInputBorder()),
                      items: workouts.map((w) => DropdownMenuItem<String>(value: w.workout, child: Text(w.workout))).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedWorkoutName = value!;
                          final workout = workouts.firstWhere((w) => w.workout == selectedWorkoutName);
                          animateToFinalRank(workout.ranked);
                        });
                      },
                    ),
                    ListTile(
                      title: Text('Lift: ${selectedWorkout.liftWeight} lbs | Body: ${selectedWorkout.bodyWeight} lbs | Reps: ${selectedWorkout.reps}'),
                      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _editWorkout(selectedWorkout)),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text('Rank: ${selectedWorkout.ranked}\nTop ${selectedWorkout.percentage}%', style: const TextStyle(fontSize: 18)),
                          Image.asset(
                            'images/${currentDisplayRank.toLowerCase()}.png',
                            width: 200,
                            height: 200,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 100),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text('BMI Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: bmiList.asMap().entries.map((entry) {
                    final bmi = entry.value;
                    return ListTile(
                      title: Text('Weight: ${bmi.weight} lbs | Height: ${bmi.height} in'),
                      subtitle: Text('BMI: ${bmi.bmi.toStringAsFixed(1)} | ${bmi.result}'),
                      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _editBMI(entry.key)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class Ranked {
  int liftWeight;
  int reps;
  String workout;
  String ranked;
  String percentage;
  int bodyWeight;

  Ranked({
    required this.bodyWeight,
    required this.liftWeight,
    required this.reps,
    required this.workout,
    this.ranked = '',
    this.percentage = '',
  });
}

class BMI {
  int weight;
  int height;
  late double bmi;
  late String result;

  BMI({required this.weight, required this.height}) {
    bmi = (height == 0) ? 0 : (weight * 703) / (height * height);
    result = bmi == 0 ? '' : bmi < 18.5 ? 'Underweight' : bmi < 24.9 ? 'Normal' : bmi < 29.9 ? 'Overweight' : 'Obese';
  }
}
