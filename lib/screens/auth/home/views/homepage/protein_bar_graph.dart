import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProteinBarChart extends StatelessWidget {
  final List<double> dailyProtein;
  final double proteinGoal;

  const ProteinBarChart({
    super.key,
    required this.dailyProtein,
    required this.proteinGoal,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (dailyProtein.reduce((a, b) => a > b ? a : b) + 30),
            minY: 0,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    return Text(
                      days[value.toInt()],
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: true),
            barGroups: List.generate(dailyProtein.length, (index) {
              final value = dailyProtein[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                    color: value >= proteinGoal ? Colors.green : Colors.red,
                  ),
                ],
              );
            }),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: proteinGoal,
                  color: Colors.blueAccent,
                  strokeWidth: 2,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    labelResolver: (_) => 'Goal: ${proteinGoal.toInt()}g',
                    alignment: Alignment.topRight,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
