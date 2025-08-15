import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PlaceholderBarChart extends StatelessWidget {
  final List<double> barValues = [130, 185, 90, 280, 260, 120, 78];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: 300,
          titlesData: FlTitlesData(
  topTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
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
  leftTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
  rightTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
),
          barGroups: List.generate(
          barValues.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: barValues[i], // use actual value, not i+1
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
                y: 144, // line at y=5
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
