import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class CircularIconButton extends StatelessWidget {
  final IconData? icon;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color borderColor;
  final double borderWidth;
  final Offset iconOffset;
  final Color? backgroundColor;
  final Widget? child;

  const CircularIconButton({
    Key? key,
    this.icon,
    required this.size,
    required this.iconSize,
    required this.iconColor,
    required this.borderColor,
    required this.borderWidth,
    this.iconOffset = Offset.zero,
    this.backgroundColor,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child: child ??
            (icon != null
                ? Transform.translate(
                    offset: iconOffset,
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: iconColor,
                    ),
                  )
                : null),
      ),
    );
  }
}
class MacroPieChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;

  const MacroPieChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fat;

    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: protein,
              title: 'Protein\n${((protein / total) * 100).toStringAsFixed(1)}%',
              radius: 110,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: carbs,
              title: 'Carbs\n${((carbs / total) * 100).toStringAsFixed(1)}%',
              radius: 110,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: fat,
              title: 'Fat\n${((fat / total) * 100).toStringAsFixed(1)}%',
              radius: 110,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}
