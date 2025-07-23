import 'package:flutter/cupertino.dart';

class VerticalSpace extends StatelessWidget {
  const VerticalSpace({super.key, this.height = 16.0});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class HorizontalSpace extends StatelessWidget {
  const HorizontalSpace({super.key, this.width = 16.0});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}