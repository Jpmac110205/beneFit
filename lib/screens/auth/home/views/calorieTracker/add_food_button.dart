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
      backgroundColor: Colors.transparent, 
      isScrollControlled: true, 
      builder: (context) => const _AddFoodModalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final activeBackgroundColor = colorScheme.primary;
    final activeBorderColor = colorScheme.primary;
    final activeTextColor = colorScheme.onPrimary;

    final inactiveBackgroundColor = colorScheme.onPrimary; 
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
          boxShadow: [
          BoxShadow(
            color: colorScheme.primary,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
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
            boxShadow: [
            BoxShadow(
              color: colorScheme.primary,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          ),
          child: const AddFoodSearchScreen(),
        );
      },
    );
  }
}
