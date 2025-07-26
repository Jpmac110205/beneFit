import 'package:flutter/material.dart';
import 'package:game/screens/auth/widgets/add_food_button.dart';
import 'package:game/screens/auth/widgets/circle.dart';
import 'package:game/screens/auth/widgets/food_log_model.dart';
import 'package:game/screens/auth/widgets/space.dart';
import 'package:provider/provider.dart';

class CalorieTrackerScreen extends StatelessWidget {
  const CalorieTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodLogModel>(
      builder: (context, foodLogModel, _) {
        final userFoodLog = foodLogModel.userFoodLog;

        int targetCalories = 2000;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;

        for (var food in userFoodLog) {
          totalProtein += food.protein;
          totalCarbs += food.carbs;
          totalFat += food.fat;
        }

        double totalCalories = (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9);

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (totalProtein >= 1 || totalCarbs >= 1 || totalFat >= 1)
                     MacroPieChart(protein: totalProtein, carbs: totalCarbs, fat: totalFat),
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
                      'Protein: ${double.parse(totalProtein.toStringAsFixed(1))} g\n'
                      'Carbohydrates: ${double.parse(totalCarbs.toStringAsFixed(1))} g\n'
                      'Fat: ${double.parse(totalFat.toStringAsFixed(1))} g\n'
                      'Total Calories: ${double.parse(totalCalories.toStringAsFixed(1))}\n'
                      'Target Calories: ${double.parse(targetCalories.toStringAsFixed(1))}',
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
                        ...userFoodLog.map((food) {
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
                                  TextSpan(text: 'Calories: ${double.parse(food.calories.toStringAsFixed(1))}'),
                                  TextSpan(text: 'Protein: ${double.parse(food.protein.toStringAsFixed(1))}g, '),
                                  TextSpan(text: 'Carbs: ${double.parse(food.carbs.toStringAsFixed(1))}g, '),
                                  TextSpan(text: 'Fat: ${double.parse(food.fat.toStringAsFixed(1))}g, '),
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
      }, // <== This closing brace needed a semicolon
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
