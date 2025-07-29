import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/calorieTracker/add_food_search_screen.dart';

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

    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _isTapped = false;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Important for rounded corners!
      isScrollControlled: true, // To make it take up full height if needed
      builder: (context) => const _AddFoodModalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use theme colors instead of hardcoded green/white
    final activeBackgroundColor = colorScheme.primary;
    final activeBorderColor = colorScheme.primary;
    final activeTextColor = colorScheme.onPrimary;

    final inactiveBackgroundColor = colorScheme.onPrimary; // usually white or light bg
    final inactiveTextColor = colorScheme.primary;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 70,
        width: 140,
        decoration: BoxDecoration(
          color: _isTapped ? inactiveBackgroundColor : activeBackgroundColor,
          border: Border.all(color: activeBorderColor, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'Add Food',
          style: TextStyle(
            color: _isTapped ? inactiveTextColor : activeTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AddFoodModalSheet extends StatelessWidget {
  const _AddFoodModalSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const AddFoodSearchScreen(),
        );
      },
    );
  }
}
