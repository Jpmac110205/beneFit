import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/screens/auth/home/premium/muscle_predictor/muscle_predictor.dart';
import 'package:game/screens/auth/home/views/challenges/challenges_home.dart';
import 'package:game/screens/auth/widgets/circle.dart';
import 'package:game/screens/auth/home/premium/ai/ai_assistant.dart';
import 'package:game/screens/auth/home/views/workoutTracker/workout_tracker.dart';
import 'package:game/screens/auth/home/views/Ranked/ranked_tracker.dart';
import 'package:game/screens/auth/home/views/calorieTracker/calorie_tracker.dart';
import 'package:game/screens/auth/home/views/friends/friends_list.dart';
import 'package:game/screens/auth/home/views/profile/profile.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;
  

  late final PageController _pageController;
  late final List<GlobalKey> _buttonKeys;
  List<double> _buttonCenters = [];
  final GlobalKey _navBarKey = GlobalKey();

  WorkoutStats? selectedWorkout;

  void setSelectedWorkout(WorkoutStats workout) {
    setState(() {
      selectedWorkout = workout;
    });
  }

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
    _pageController = PageController(initialPage: _currentIndex);
    _buttonKeys = List.generate(icons.length, (index) => GlobalKey());
    warmUpFoodApi();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateButtonCenters();
    });

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? _currentIndex;
      if (page != _currentIndex) {
        setState(() {
          _currentIndex = page;
        });
      }
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

  final centerX = buttonCenterGlobal - navBarLeftGlobal - 11; // relative center
  centers.add(centerX);
}

    setState(() {
      _buttonCenters = centers;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      size: 80.0,
                      iconSize: 40.0,
                      iconColor: theme.iconTheme.color!,
                      borderColor: Colors.green,
                      borderWidth: 2.0,
                      backgroundColor: theme.colorScheme.surface,
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
                      size: 80.0,
                      iconSize: 40.0,
                      iconColor: theme.iconTheme.color!,
                      borderColor: Colors.green,
                      borderWidth: 2.0,
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final buttonCount = icons.length;
                  const maxButtonSize = 80.0;
                  const minButtonSize = 50.0;
                  const spacing = 12.0;
                  final totalSpacing = spacing * (buttonCount - 1);
                  final availableWidth = maxWidth - totalSpacing;
                  double buttonSize = availableWidth / buttonCount;

                  if (buttonSize > maxButtonSize) buttonSize = maxButtonSize;
                  if (buttonSize < minButtonSize) buttonSize = minButtonSize;

                  return Container(
                    key: _navBarKey,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: SizedBox(
                      height: buttonSize + 40,
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(buttonCount, (index) {
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
                                child: CircularIconButton(
                                  icon: icons[index],
                                  size: buttonSize,
                                  iconSize: buttonSize * 0.5,
                                  iconColor: _currentIndex == index
                                      ? Colors.green
                                      : theme.iconTheme.color!,
                                  borderColor: Colors.green,
                                  borderWidth: 2.0,
                                  iconOffset: index == 3
                                      ? Offset(-buttonSize * 0.06, 0)
                                      : Offset.zero,
                                  backgroundColor: _currentIndex == index
                                      ? theme.colorScheme.surface
                                      : Colors.transparent,
                                ),
                              );
                            }),
                          ),
                          if (_buttonCenters.length == icons.length)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              bottom: 12,
                              left: _buttonCenters[_currentIndex] - 3.5,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: theme.iconTheme.color,
                                  shape: BoxShape.circle,
                                ),
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
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  final WorkoutStats? selectedWorkout;
  final void Function(WorkoutStats)? onWorkoutSelected;

  const HomeContentScreen({
    super.key,
    required this.selectedWorkout,
    this.onWorkoutSelected,
  });
  

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {

        final maxWidth = constraints.maxWidth;
        final boxMaxWidth = maxWidth * 0.9 > 400 ? 400.0 : maxWidth * 0.9;
        final halfBoxMaxWidth = (boxMaxWidth - 20) / 2;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: boxMaxWidth,
                    maxHeight: 250,
                  ),
                  child: Image.asset(
                    'images/d2.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 100),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AiAssistant(), 
                  SizedBox(width: 30),
                  MusclePredictor(),
                ],
              ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _buildBox(context, 'Daily Challenges',
                          width: halfBoxMaxWidth),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: _buildBox(context, 'Steps Tracker',
                          width: halfBoxMaxWidth),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildBox(context, 'Macro Specific Bar Graphs',
                    width: boxMaxWidth),
                    SizedBox(height: 30),
                
                SizedBox(height: 150),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBox(BuildContext context, String text, {required double width}) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 250),
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style:
              theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
