import 'package:flutter/material.dart';

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


