import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/add_food_search_screen.dart';


class FoodLogModel extends ChangeNotifier {
  final List<Food> _userFoodLog = [];

  List<Food> get userFoodLog => _userFoodLog;

  void addFood(Food food) {
    _userFoodLog.add(food);
    notifyListeners();
  }

  void clearLog() {
    _userFoodLog.clear();
    notifyListeners();
  }
}
