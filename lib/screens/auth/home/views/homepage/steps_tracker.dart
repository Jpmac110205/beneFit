import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StepTrackerProvider extends ChangeNotifier {
  int _steps = 0;
  int get steps => _steps;

  StepTrackerProvider() {
    _initPedometer();
  }

  void _initPedometer() {
    final stepCountStream = Pedometer.stepCountStream;
    stepCountStream.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    _steps = event.steps;
    notifyListeners();
  }

  void _onStepCountError(error) {
    print("Step count error: $error");
  }
}
