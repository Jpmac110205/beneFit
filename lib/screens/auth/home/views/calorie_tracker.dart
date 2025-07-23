import 'package:flutter/material.dart';
import 'package:game/screens/auth/widgets/add_food_button.dart';
import 'package:game/screens/auth/widgets/circle.dart';
import 'package:game/screens/auth/widgets/space.dart';

const int targetCalories = 2000;

List<Food> foodList = [
  Food(name: 'Chicken Breast', protein: 31, carbs: 0, fat: 3, fiber: 0, sugar: 0),
  Food(name: 'Rice', protein: 4, carbs: 45, fat: 0, fiber: 1, sugar: 0),
  Food(name: 'Broccoli', protein: 3, carbs: 6, fat: 0, fiber: 2, sugar: 1),
  Food(name: 'Eggs', protein: 6, carbs: 1, fat: 5, fiber: 0, sugar: 0),
  Food(name: 'Almonds', protein: 6, carbs: 6, fat: 14, fiber: 3, sugar: 1),
];

class CalorieTrackerScreen extends StatelessWidget {
  const CalorieTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Calculate totals before building the UI
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    int totalFiber = 0;
    int totalSugar = 0;

    for (var food in foodList) {
      totalProtein += food.protein;
      totalCarbs += food.carbs;
      totalFat += food.fat;
      totalFiber += food.fiber;
      totalSugar += food.sugar;
    }

    int totalCalories = (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BigCircleScreenContent(),
              const VerticalSpace(height: 30),
              const AddFoodButton(),
              const VerticalSpace(height: 30),

              // Macros summary box
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Protein: $totalProtein g\n'
                  'Carbohydrates: $totalCarbs g\n'
                  'Fat: $totalFat g\n'
                  'Fiber: $totalFiber g\n'
                  'Sugar: $totalSugar g\n\n'
                  'Total Calories: $totalCalories\n'
                  'Target Calories: $targetCalories',
                  style: const TextStyle(fontSize: 20),
                ),
              ),

              const SizedBox(height: 20),

              // Food list box
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Food List',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...foodList.map((food) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            children: [
                              TextSpan(
                                text: '${food.name} → ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'Protein: ${food.protein}g, '),
                              TextSpan(text: 'Carbs: ${food.carbs}g, '),
                              TextSpan(text: 'Fat: ${food.fat}g, '),
                              TextSpan(text: 'Fiber: ${food.fiber}g, '),
                              TextSpan(text: 'Sugar: ${food.sugar}g'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
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

class BigCircleScreenContent extends StatelessWidget {
  const BigCircleScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularIconButton(
      size: 350,
      iconSize: 0,
      iconColor: Colors.transparent,
      borderColor: Colors.green,
      borderWidth: 5,
      backgroundColor: Colors.white,
      child: Text(
        'Macros Display',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class Food {
  String name;
  int protein;
  int carbs;
  int fat;
  int fiber;
  int sugar;

  Food({
    required this.name,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sugar = 0,
  });
}
