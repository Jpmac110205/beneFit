import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PlaceholderBarChart extends StatefulWidget {
  final String macro;

  const PlaceholderBarChart({super.key, required this.macro});

  @override
  _PlaceholderBarChartState createState() => _PlaceholderBarChartState();
}

class _PlaceholderBarChartState extends State<PlaceholderBarChart> {
  double goal = 0.0;
  List<double> barValues = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant PlaceholderBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.macro != widget.macro) {
      _loadData();
    }
  }
  

  /// Fetch both the goal and weekly macro values
  void _loadData() async {
    final int goalValue = await grabGoals(widget.macro);
    final Map<String, List<double>> weeklyData = await fetchWeeklyMacros(widget.macro);

    if (!mounted) return;
    setState(() {
      goal = goalValue.toDouble();
      // Only use the selected macro's values
      barValues = weeklyData[widget.macro] ?? List.filled(7, 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Dynamically set maxY based on your data and goal
    final double maxY = [
      ...barValues,
      goal
    ].reduce((a, b) => a > b ? a : b) + 50;

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: maxY, // <-- Use dynamic maxY
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(days[value.toInt() % 7], style: TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(
            barValues.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: barValues[i],
                  color: Colors.green,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: goal,
                color: colorScheme.onSurface,
                strokeWidth: 2,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (_) => 'Goal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fetch macro goal
Future<int> grabGoals(String macro) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0;

  final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!snapshot.exists) return 0;

  final data = snapshot.data() as Map<String, dynamic>;
  final proteinPercent = (data['proteinPercent'] ?? 0) as num;
  final calorieGoal = (data['calorieGoal'] ?? 0) as num;
  final fatPercent = (data['fatPercent'] ?? 0) as num;
  final carbPercent = (data['carbsPercent'] ?? 0) as num;

  final proteinGoal = ((proteinPercent / 100) * calorieGoal / 4).round();
  final fatGoal = ((fatPercent / 100) * calorieGoal / 9).round();
  final carbGoal = ((carbPercent / 100) * calorieGoal / 4).round();

  if (macro == 'protein') return proteinGoal;
  if (macro == 'fat') return fatGoal;
  if (macro == 'carbs') return carbGoal;
  return 0;
}

/// Fetch weekly macros
Future<Map<String, List<double>>> fetchWeeklyMacros(String macro) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return {
    'protein': List.filled(7, 0.0),
    'fat': List.filled(7, 0.0),
    'carbs': List.filled(7, 0.0),
  };
  }

  final daysOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // Fetch all docs in parallel
  final docs = await Future.wait(daysOrder.map((day) =>
    FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('calories')
      .doc(day)
      .get()
  ));

  List<double> proteinList = [];
  List<double> fatList = [];
  List<double> carbList = [];

  for (var doc in docs) {
    final data = doc.data();

    proteinList.add((data?['totalProtein'] ?? 0).toDouble());
    fatList.add((data?['totalFat'] ?? 0).toDouble());
    carbList.add((data?['totalCarbs'] ?? 0).toDouble());
  }


  return {
    'protein': proteinList,
    'fat': fatList,
    'carbs': carbList,
  };
}
