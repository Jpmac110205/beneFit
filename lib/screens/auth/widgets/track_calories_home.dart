import 'package:flutter/material.dart';

class TrackCaloriesHome extends StatefulWidget {
  const TrackCaloriesHome({super.key});

  @override
  State<TrackCaloriesHome> createState() => _TrackCaloriesHomeState();
}

class _TrackCaloriesHomeState extends State<TrackCaloriesHome> {
  bool _isTapped = false;

  void _handleTap() async {
    setState(() {
      _isTapped = true;
    });

    // Wait for a short duration (e.g., 200 ms)
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _isTapped = false;
    });

    // TODO: You can add your actual logic here, like opening a new screen
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
          'Track Calories',
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