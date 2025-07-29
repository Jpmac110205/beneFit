import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/calorieTracker/add_food_button.dart';
import 'package:game/screens/auth/widgets/circle.dart';
import 'package:game/screens/auth/home/views/calorieTracker/food_log_model.dart';
import 'package:game/screens/auth/widgets/space.dart';
import 'package:provider/provider.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final foodLogModel = Provider.of<FoodLogModel>(context, listen: false);
      foodLogModel.loadFoodsFromFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          appBar: AppBar(
            title: Text(
              'Calorie Tracker',
              style: TextStyle(color: colorScheme.primary),
            ),
            backgroundColor: colorScheme.onPrimary,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.primary),
          ),
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
                      color: colorScheme.onPrimary,
                      border: Border.all(color: colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Protein: ${totalProtein.toStringAsFixed(1)} g\n'
                      'Carbohydrates: ${totalCarbs.toStringAsFixed(1)} g\n'
                      'Fat: ${totalFat.toStringAsFixed(1)} g\n'
                      'Total Calories: ${totalCalories.toStringAsFixed(1)}\n'
                      'Target Calories: $targetCalories',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Food list box
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      border: Border.all(color: colorScheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Food List',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ...userFoodLog.map((food) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${food.name} → Calories: ${food.calories.toStringAsFixed(1)}, '
                                    'Protein: ${food.protein.toStringAsFixed(1)}g, '
                                    'Carbs: ${food.carbs.toStringAsFixed(1)}g, '
                                    'Fat: ${food.fat.toStringAsFixed(1)}g',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: colorScheme.error),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Entry?'),
                                        content: Text('Remove ${food.name} from your food log?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete')),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await foodLogModel.deleteFood(food);
                                    }
                                  },
                                ),
                              ],
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
      },
    );
  }
}

class BigCircleScreenContent extends StatelessWidget {
  const BigCircleScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircularIconButton(
      size: 350,
      iconSize: 0,
      iconColor: Colors.transparent,
      borderColor: colorScheme.primary,
      borderWidth: 5,
      backgroundColor: colorScheme.surface,
      child: Text(
        'Macros Display',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
