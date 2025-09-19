import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/screens/auth/home/steps_tracker_bloc/bloc/steps_tracker_bloc.dart';
import 'package:game/screens/auth/home/steps_tracker_bloc/bloc/steps_tracker_event.dart';
import 'package:game/screens/auth/home/steps_tracker_bloc/bloc/steps_tracker_state.dart';
import 'package:game/screens/auth/home/views/homepage/charts.dart';
import 'package:game/screens/auth/home/views/workoutTracker/workout_tracker.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class DailyChallenge {
  String name;
  int expRewarded;
  bool isAbleToBeCollected;
  bool isCompletedToday;

  DailyChallenge({
    required this.name,
    required this.expRewarded,
    required this.isAbleToBeCollected,
    required this.isCompletedToday,
  });

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      name: map['name'] ?? 'Unknown',
      expRewarded: map['expRewarded'] ?? 0,
      isAbleToBeCollected: map['isAbleToBeCollected'] ?? false,
      isCompletedToday: map['isCompletedToday'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'expRewarded': expRewarded,
      'isAbleToBeCollected': isAbleToBeCollected,
      'isCompletedToday': isCompletedToday,
    };
  }
}



class HomeContentScreen extends StatefulWidget {
  final WorkoutStats? selectedWorkout;
  final void Function(WorkoutStats)? onWorkoutSelected;

  const HomeContentScreen({
    super.key,
    required this.selectedWorkout,
    this.onWorkoutSelected,
  });

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  List<DailyChallenge> challenges = [];
  bool isLoading = true;

@override
void initState() {
  super.initState();
  _initData();
}

Future<void> _initData() async {
  await resetDailyChallengesIfNeeded();
  await _loadChallengesAndUpdate();
}

Future<void> resetDailyChallengesIfNeeded() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final userDoc = await userDocRef.get();

  final lastReset = (userDoc.data()?['lastDailyReset'] as Timestamp?)?.toDate();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (lastReset == null || lastReset.isBefore(today)) {
    // Reset challenges
    final challengeSnapshot = await userDocRef.collection('dailyChallenges').get();
    for (final doc in challengeSnapshot.docs) {
      await doc.reference.update({
        'isAbleToBeCollected': false,
        'isCompletedToday': false,
      });
    }

    // Update last reset timestamp
    await userDocRef.update({
      'lastDailyReset': Timestamp.fromDate(today),
    });

    print('✅ Daily challenges reset');
  }
}




  Future<void> _loadChallengesAndUpdate() async {
    await _initializeChallengesIfNeeded();
    await _loadUserChallenges();
    await _updateCollectStatus();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _initializeChallengesIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('dailyChallenges')
        .get();

    if (snapshot.docs.isEmpty) {
      final defaultChallenges = [
        DailyChallenge(
          name: 'Add 5 Foods',
          expRewarded: 10,
          isCompletedToday: false,
          isAbleToBeCollected: false,
        ),
        DailyChallenge(
          name: 'Complete a Workout',
          expRewarded: 15,
          isCompletedToday: false,
          isAbleToBeCollected: false,
        ),
        DailyChallenge(
          name: 'Walk 5k Steps',
          expRewarded: 20,
          isCompletedToday: false,
          isAbleToBeCollected: false,
        ),
      ];

      for (var challenge in defaultChallenges) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('dailyChallenges')
            .doc(challenge.name)
            .set(challenge.toMap());
      }
    }
  }

  Future<void> _loadUserChallenges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('dailyChallenges')
        .get();

    final loaded = snapshot.docs
        .map((doc) => DailyChallenge.fromMap(doc.data()))
        .toList();
    if (!mounted) return;
    setState(() {
      challenges = loaded;
    });
  }

  Future<void> _updateCollectStatus() async {
  final hasEnoughFoods = await countFoodsInDay();
  final didWorkoutToday = await pullWorkoutRecency();
  final hasEnoughSteps = await pullStepsTracker();

  if (!mounted) return;
  setState(() {
    challenges = challenges.map((challenge) {
      if (challenge.name == 'Add 5 Foods') {
        return DailyChallenge(
          name: challenge.name,
          expRewarded: challenge.expRewarded,
          isCompletedToday: challenge.isCompletedToday,
          isAbleToBeCollected:
              hasEnoughFoods && !challenge.isCompletedToday,
        );
      } else if (challenge.name == 'Complete a Workout') {
        return DailyChallenge(
          name: challenge.name,
          expRewarded: challenge.expRewarded,
          isCompletedToday: challenge.isCompletedToday,
          isAbleToBeCollected:
              didWorkoutToday && !challenge.isCompletedToday,
        );
      }
      else if (challenge.name == 'Walk 5k Steps') {
  return DailyChallenge(
    name: challenge.name,
    expRewarded: challenge.expRewarded,
    isCompletedToday: challenge.isCompletedToday,
    isAbleToBeCollected: hasEnoughSteps && !challenge.isCompletedToday,
  );
} else {
        return challenge;
      }
    }).toList();
  });
}

Future<bool> pullStepsTracker() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('dailyChallenges')
      .doc('Walk 5k Steps')
      .get();

  final health = Health();
  final steps = await getStepCount(health);

  if (steps >= 5000) {
    await snapshot.reference.update({
      'isAbleToBeCollected': true,
    });
    return true;
  }

  return false;
}



  Future<bool> pullWorkoutRecency() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final workoutSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('workouts')
      .get();

  for (final workoutDoc in workoutSnapshot.docs) {
    final data = workoutDoc.data();
    final daysSinceLast = data['daysSinceLast'] ?? -1;

    if (daysSinceLast == 0) {
      return true;
    }
  }

  return false;
}



  Future<void> _collectChallenge(DailyChallenge challenge) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  // 1. Mark the challenge as completed and uncollectable
  await userDocRef
      .collection('dailyChallenges')
      .doc(challenge.name)
      .update({
    'isCompletedToday': true,
    'isAbleToBeCollected': false,
  });

  // 2. Get the current totalExp
  final userSnapshot = await userDocRef.get();
  final currentExp = userSnapshot.data()?['totalExp'] ?? 0;

  // 3. Update totalExp
  await userDocRef.update({
    'totalExp': currentExp + challenge.expRewarded,
  });

  // 4. Refresh UI state
  await _loadUserChallenges();
  await _updateCollectStatus(); // Make sure this matches your actual method name
}


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final boxMaxWidth = constraints.maxWidth * 0.9 > 400
                      ? 400.0
                      : constraints.maxWidth * 0.9;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHeaderImage(boxMaxWidth),
                        const SizedBox(height: 30),
                        _buildChallengeBox(colorScheme),
                        const SizedBox(height: 30),
                        const MarcoBarGraph(),
                        const SizedBox(height: 30),
                        const StepsTracker(),
                        const SizedBox(height: 150),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeaderImage(double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 250),
      child: Image.asset(
        'images/d2.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_not_supported, size: 100),
      ),
    );
  }

  Widget _buildChallengeBox(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Challenges',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...challenges.map((challenge) => _buildChallengeRow(challenge, colorScheme)),
        ],
      ),
    );
  }

  Widget _buildChallengeRow(DailyChallenge challenge, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${challenge.name} (${challenge.expRewarded} EXP)',
              style: TextStyle(
                fontSize: 16,
                color: challenge.isCompletedToday
                    ? Colors.grey
                    : colorScheme.onSurface,
                decoration: challenge.isCompletedToday
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: challenge.isAbleToBeCollected
                ? () => _collectChallenge(challenge)
                : null,
            child: const Text('Collect'),
          ),
        ],
      ),
    );
  }
}


Future<bool> countFoodsInDay() async {
  final user = FirebaseAuth.instance.currentUser;
  final now = DateTime.now();
  final dayOfWeek = getDayOfWeek(now.weekday);

  final foodsCollectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('calories')
      .doc(dayOfWeek)
      .collection('foods');

  final querySnapshot = await foodsCollectionRef.get();
  return querySnapshot.docs.length >= 5;
}


String getDayOfWeek(int weekdayNumber) {
  switch (weekdayNumber) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return 'Unknown';
  }
}
class StepsTracker extends StatelessWidget {
  const StepsTracker({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => StepBloc()..add(LoadTodaySteps()),
      child: BlocBuilder<StepBloc, StepState>(
        builder: (context, state) {
          return Container(
            height: 175,
            width: MediaQuery.of(context).size.width - 50,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                  Text(
                  'Step Tracker',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 60),
                Transform.translate(
                  offset: const Offset(0, 10), // move down by 20 pixels
                  child: Transform.rotate(
                    angle: -65 * 3.1415926535 / 180,
                    child: Icon(
                      FontAwesomeIcons.shoePrints,
                      size: 45,
                      color: Colors.green,
                    ),
                  ),
                ),

                  ]
                ),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 16),
                      Flexible(
                        child: _buildStepContent(state, colorScheme),
                      ),
                      const SizedBox(width: 20),

                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(StepState state, ColorScheme colorScheme) {
  if (state is StepLoadInProgress) {
    return const Center(child: CircularProgressIndicator());
  } else if (state is StepLoadSuccess) {
    return Row(
      mainAxisSize: MainAxisSize.min,  // prevent Row from taking full width
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${state.steps}',
          style: TextStyle(
            fontSize: 44,
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'steps today',
          style: TextStyle(
            fontSize: 20,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  } else if (state is StepLoadFailure) {
    return Text(
      'Error: ${state.message}',
      style: TextStyle(
        fontSize: 16,
        color: colorScheme.error,
      ),
    );
  } else {
    return Text(
      'Loading steps...',
      style: TextStyle(
        fontSize: 16,
        color: colorScheme.primary,
      ),
    );
  }
}

}

// Fetch step count from Health API
Future<int> getStepCount(Health health) async {
  try {
    final granted = await requestMotionPermission();
    if (!granted) {
      return 0;
    }

    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day);

    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
      startTime: startTime,
      endTime: now,
      types: [HealthDataType.STEPS],
    );

    int totalSteps = 0;
    for (var point in healthData) {
      debugPrint("Raw step value type: ${point.value.runtimeType}, value: ${point.value}");
      totalSteps += extractStepsFromHealthValue(point.value);
    }

    debugPrint("Total steps today: $totalSteps from ${healthData.length} points.");
    return totalSteps;
  } catch (e, stack) {
    debugPrint("getStepCount error: $e");
    debugPrint(stack.toString());
    return 0;
  }
}

int extractStepsFromHealthValue(dynamic val) {
  try {
    if (val == null) return 0;

    if (val is int) return val;
    if (val is double) return val.toInt();

    try {
      final numericVal = (val as dynamic).numericValue;
      if (numericVal is num) {
        return numericVal.toInt();
      }
    } catch (_) {
    }

    final strVal = val.toString();
    final match = RegExp(r'\d+').firstMatch(strVal);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 0;
    }

    debugPrint("Could not extract steps from value: $val");
  } catch (e) {
    debugPrint('extractStepsFromHealthValue error: $e');
  }

  return 0;
}


// Requests motion/activity recognition permission and returns whether granted
Future<bool> requestMotionPermission() async {
  final status = await Permission.activityRecognition.status;
  if (status.isDenied || status.isRestricted) {
    final result = await Permission.activityRecognition.request();
    return result.isGranted;
  }
  return status.isGranted;
}


class MarcoBarGraph extends StatefulWidget {
  const MarcoBarGraph({super.key});

  @override
  _MarcoBarGraphState createState() => _MarcoBarGraphState();
}

class _MarcoBarGraphState extends State<MarcoBarGraph> {
  String macro = 'protein';
  double goal = 0.0;
  final barValues = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0];

  @override
  void initState() {
    super.initState();
    _fetchGoal();
  }

  void _fetchGoal() async {
  String macroForGoal = macro;
  if (macroForGoal == 'carbs') macroForGoal = 'carb'; // map plural to singular
  int value = await grabGoals(macroForGoal);
  setState(() {
    goal = value.toDouble();
  });
}




  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 350,
      width: MediaQuery.of(context).size.width - 50,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macro-Specific Stats',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          PlaceholderBarChart(macro: macro), // Pass macro here
          const SizedBox(height: 16),
          Center(
            child: DropdownButton<String>(
              value: macro,
              items: <String>['protein', 'fat', 'carbs'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: colorScheme.primary)),
                );
              }).toList(),
               onChanged: (String? newValue) {
            setState(() {
              macro = newValue!;
            });
          },
            ),
          ),
        ],
      ),
    );
  }
}
