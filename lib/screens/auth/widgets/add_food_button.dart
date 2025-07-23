import 'package:flutter/material.dart';

class AddFoodButton extends StatefulWidget {
  const AddFoodButton({super.key});

  @override
  State<AddFoodButton> createState() => _AddFoodButtonState();
}

class _AddFoodButtonState extends State<AddFoodButton> {
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
        height: 70,
        width: 140,
        decoration: BoxDecoration(
          color: _isTapped ? Colors.white : Colors.green,
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'Add Food',
          style: TextStyle(
            color: _isTapped ? Colors.green : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}