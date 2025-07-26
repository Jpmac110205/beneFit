import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:game/screens/auth/widgets/circle.dart';
import 'package:game/screens/auth/widgets/space.dart';
import 'package:game/screens/auth/widgets/track_calories_home.dart';
import 'package:game/screens/auth/home/views/workout_tracker.dart';
import 'package:game/screens/auth/home/views/ranked_tracker.dart';
import 'package:game/screens/auth/home/views/calorie_tracker.dart';
import 'package:game/screens/auth/home/views/friends_list.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;
  bool _isNotificationActive = false;
  bool _isProfileActive = false;

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
    Icons.people,
    Icons.home,
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.bowlFood,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _buttonKeys = List.generate(icons.length, (index) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateButtonCenters();
    });

    // Sync _currentIndex when user swipes pages
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? _currentIndex;
      if (page != _currentIndex) {
        setState(() {
          _currentIndex = page;
        });
      }
    });
  }

  void _calculateButtonCenters() {
    final RenderBox? navBarBox = _navBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (navBarBox == null) return;

    final navBarPosition = navBarBox.localToGlobal(Offset.zero);
    List<double> centers = [];

    for (var key in _buttonKeys) {
      final RenderBox? buttonBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (buttonBox == null) continue;

      final buttonPosition = buttonBox.localToGlobal(Offset.zero);
      final centerX = buttonPosition.dx + buttonBox.size.width / 2 - navBarPosition.dx;
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

    // Pass searchManager and setSelectedWorkout to screens that need them
    final screens = [
      const RankedScreen(),
      const FriendsListScreen(),
      HomeContentScreen(
        selectedWorkout: selectedWorkout,
        onWorkoutSelected: setSelectedWorkout,
      ),
      const WorkoutTrackerScreen(),
      const CalorieTrackerScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                children: screens,
                // page changes handled by listener in initState
              ),
            ),

            // Top bar
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _isProfileActive = !_isProfileActive);
                    },
                    child: CircularIconButton(
                      icon: Icons.person,
                      size: 80.0,
                      iconSize: 40.0,
                      iconColor: Colors.black,
                      borderColor: Colors.green,
                      borderWidth: 2.0,
                      backgroundColor: _isProfileActive ? Colors.white : Colors.grey[300],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isNotificationActive = !_isNotificationActive);
                    },
                    child: CircularIconButton(
                      icon: Icons.notifications,
                      size: 80.0,
                      iconSize: 40.0,
                      iconColor: Colors.black,
                      borderColor: Colors.green,
                      borderWidth: 2.0,
                      backgroundColor: _isNotificationActive ? Colors.white : Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom navigation bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                key: _navBarKey,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.green, width: 2),
                ),
                height: 130,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(icons.length, (index) {
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
                            size: 80,
                            iconSize: 40,
                            iconColor: _currentIndex == index ? Colors.green : Colors.black,
                            borderColor: Colors.green,
                            borderWidth: 2.0,
                            iconOffset: index == 3 ? const Offset(-5, 0) : Offset.zero,
                            backgroundColor: _currentIndex == index ? Colors.white : Colors.transparent,
                          ),
                        );
                      }),
                    ),
                    if (_buttonCenters.length == icons.length)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        bottom: 20,
                        left: _buttonCenters[_currentIndex] - 3.5,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Use flexible widths for smaller screens
    final boxWidth = screenWidth * 0.9 > 400 ? 400.0 : screenWidth * 0.9;
    final halfBoxWidth = (screenWidth * 0.9 - 20) / 2; // 20 for spacing

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Column(
        children: [
          const VerticalSpace(height: 30),
          Text(
            selectedWorkout?.name ?? 'BeneFit',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Colors.green,
                ),
          ),
          const VerticalSpace(height: 40),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 16),
              TrackCaloriesHome(),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHalfBox('Friends List Preview', width: halfBoxWidth),
              const HorizontalSpace(width: 20),
              _buildHalfBox('Ranked Tracker Preview', width: halfBoxWidth),
            ],
          ),
          const VerticalSpace(height: 30),
          _buildBox('Graphics and Achievements', width: boxWidth),
        ],
      ),
    );
  }

  Widget _buildBox(String text, {required double width}) {
    return Container(
      height: 250,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHalfBox(String text, {required double width}) {
    return Container(
      width: width,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
