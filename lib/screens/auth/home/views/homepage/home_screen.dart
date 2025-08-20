import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/screens/auth/home/views/challenges/challenges_home.dart';
import 'package:game/screens/auth/widgets/circle.dart';
import 'package:game/screens/auth/home/views/workoutTracker/workout_tracker.dart';
import 'package:game/screens/auth/home/views/Ranked/ranked_tracker.dart';
import 'package:game/screens/auth/home/views/calorieTracker/calorie_tracker.dart';
import 'package:game/screens/auth/home/views/friends/friends_list.dart';
import 'package:game/screens/auth/home/views/profile/profile.dart';
import 'package:game/screens/auth/home/views/homepage/daily_challenges.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 2;
  late final PageController _pageController;
  late final List<GlobalKey> _buttonKeys;
  final GlobalKey _navBarKey = GlobalKey();
  WorkoutStats? selectedWorkout;

  final List<IconData> icons = [
    Icons.emoji_events,
    Icons.checklist,
    Icons.home,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.bowlFood,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(initialPage: _currentIndex);
    _buttonKeys = List.generate(icons.length, (index) => GlobalKey());
    warmUpFoodApi();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateButtonCenters();
    });

    _pageController.addListener(() async {
      final page = _pageController.page?.round() ?? _currentIndex;
      if (page != _currentIndex) {
        setState(() => _currentIndex = page);
        await updateStreak();
        await markUserActive();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // App foreground → user is active
      await markUserActive();
      await updateStreak();
    } else if (state == AppLifecycleState.paused) {
      // App background → check inactivity
      await updateUserActiveStatus();
    }
  }

  void setSelectedWorkout(WorkoutStats workout) {
    setState(() {
      selectedWorkout = workout;
    });
  }

  Future<void> warmUpFoodApi() async {
    try {
      final apiKey = dotenv.env['USDA_API_KEY'];
      if (apiKey == null) return;

      const warmupQuery = 'banana';
      final searchUrl =
          'https://api.nal.usda.gov/fdc/v1/foods/search?query=${Uri.encodeComponent(warmupQuery)}&pageSize=1&api_key=$apiKey';

      final searchResponse = await http.get(Uri.parse(searchUrl));
      if (searchResponse.statusCode != 200) return;

      final foodList = json.decode(searchResponse.body)['foods'];
      if (foodList.isEmpty) return;

      final sampleFdcId = foodList.first['fdcId'];
      final detailUrl =
          'https://api.nal.usda.gov/fdc/v1/food/$sampleFdcId?api_key=$apiKey';

      await http.get(Uri.parse(detailUrl));
    } catch (e) {
      debugPrint('warmUpFoodApi error: $e');
    }
  }

  void _calculateButtonCenters() {
    final RenderBox? navBarBox =
        _navBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (navBarBox == null) return;

    List<double> centers = [];

    for (var key in _buttonKeys) {
      final RenderBox? buttonBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (buttonBox == null) continue;

      final buttonOffset = buttonBox.localToGlobal(Offset.zero);
      final navBarOffset = navBarBox.localToGlobal(Offset.zero);

      final buttonCenterGlobal = buttonOffset.dx + buttonBox.size.width / 2;
      final navBarLeftGlobal = navBarOffset.dx;

      final centerX = buttonCenterGlobal - navBarLeftGlobal - 11;
      centers.add(centerX);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screens = [
      const RankedScreen(),
      const ChallengesHome(),
      HomeContentScreen(
        selectedWorkout: selectedWorkout,
        onWorkoutSelected: setSelectedWorkout,
      ),
      const WorkoutTrackerScreen(),
      const CalorieTrackerScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                children: screens,
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()),
                      );
                    },
                    child: CircularIconButton(
                      icon: Icons.person,
                      size: 70.0,
                      iconSize: 40.0,
                      iconColor: theme.iconTheme.color!,
                      borderColor: Colors.green,
                      borderWidth: 2.0,
                      backgroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FriendsListScreen()),
                      );
                    },
                    child: CircularIconButton(
                      icon: Icons.group,
                      size: 70.0,
                      iconSize: 40.0,
                      iconColor: theme.iconTheme.color!,
                      borderColor: Colors.green,
                      borderWidth: 2.0,
                      backgroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                key: _navBarKey,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      color: colorScheme.onPrimary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(icons.length, (index) {
                          final isSelected = _currentIndex == index;
                          return GestureDetector(
                            key: _buttonKeys[index],
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              setState(() => _currentIndex = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                icons[index],
                                size: isSelected ? 30 : 26,
                                color: isSelected
                                    ? Colors.green
                                    : colorScheme.onSurface,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- FIREBASE FUNCTIONS ---

Future<void> updateStreak() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final userDoc = await userDocRef.get();
  final data = userDoc.data();
  if (data == null) return;

  final Timestamp? lastStreakTimestamp = data['lastStreakUpdate'] as Timestamp?;
  final int currentStreak = (data['streak'] ?? 0) as int;
  final now = DateTime.now();

  if (lastStreakTimestamp == null) {
    await userDocRef.update({
      'streak': 1,
      'lastStreakUpdate': Timestamp.fromDate(now),
    });
    return;
  }

  final lastStreakDate = lastStreakTimestamp.toDate();
  final difference = now.difference(lastStreakDate).inDays;

  if (difference == 1) {
    await userDocRef.update({
      'streak': currentStreak + 1,
      'lastStreakUpdate': Timestamp.fromDate(now),
    });
  } else if (difference > 1) {
    await userDocRef.update({
      'streak': 1,
      'lastStreakUpdate': Timestamp.fromDate(now),
    });
  }
}

Future<void> markUserActive() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  await userDocRef.update({
    'isActive': true,
    'lastActive': Timestamp.now(),
  });
}

Future<void> updateUserActiveStatus() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  await userDocRef.update({
    'isActive': false,
  });
}
