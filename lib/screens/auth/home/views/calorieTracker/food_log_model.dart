import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_food_search_screen.dart';
import 'package:intl/intl.dart';

class FoodLogModel extends ChangeNotifier {
  List<Food> _userFoodLog = [];
  int _totalFoodsLogged = 0;

  List<Food> get userFoodLog => _userFoodLog;
  int get totalFoodsLogged => _totalFoodsLogged;

  String get currentWeekday => DateFormat('EEEE').format(DateTime.now());

  Future<void> cleanupOldFoodLogs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = currentWeekday;
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    for (final day in weekdays) {
      if (day == today) continue;

      final foodsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('calories')
          .doc(day)
          .collection('foods');

      final foodsSnapshot = await foodsRef.get();
      for (final doc in foodsSnapshot.docs) {
        await doc.reference.delete();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('calories')
          .doc(day)
          .set({
        'lastCleaned': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> deleteFood(Food food) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || food.docId == null) return;

    try {
      final weekday = currentWeekday;
      final foodDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('calories')
          .doc(weekday)
          .collection('foods')
          .doc(food.docId);

      await foodDocRef.delete();
      _userFoodLog.remove(food);
      notifyListeners();

      final dayDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('calories')
          .doc(weekday);

      final dayData = (await dayDocRef.get()).data() ?? {};
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userData = (await userDocRef.get()).data() ?? {};

      final newCalories = (dayData['totalCalories'] ?? 0) - food.calories;
      final newProtein = (dayData['totalProtein'] ?? 0) - food.protein;
      final newCarbs = (dayData['totalCarbs'] ?? 0) - food.carbs;
      final newFat = (dayData['totalFat'] ?? 0) - food.fat;
      final currentTotal = (userData['totalFoodsLogged'] ?? 1) as int;

      await Future.wait([
        dayDocRef.set({
          'totalCalories': newCalories < 0 ? 0 : newCalories,
          'totalProtein': newProtein < 0 ? 0 : newProtein,
          'totalCarbs': newCarbs < 0 ? 0 : newCarbs,
          'totalFat': newFat < 0 ? 0 : newFat,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
        userDocRef.set({
          'totalFoodsLogged': currentTotal > 0 ? currentTotal - 1 : 0,
        }, SetOptions(merge: true)),
      ]);

      _totalFoodsLogged = currentTotal > 0 ? currentTotal - 1 : 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting food: $e');
    }
  }

  Future<void> loadFoodsFromFirebase() async {
    await cleanupOldFoodLogs();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final foodsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('calories')
          .doc(currentWeekday)
          .collection('foods')
          .orderBy('timestamp', descending: true)
          .get();

      _userFoodLog = foodsSnapshot.docs.map((doc) {
        final data = doc.data();
        final double calories = (data['calories'] as num?)?.toDouble() ?? 0;
        final double protein = (data['protein'] as num?)?.toDouble() ?? 0;
        final double carbs = (data['carbs'] as num?)?.toDouble() ?? 0;
        final double fat = (data['fat'] as num?)?.toDouble() ?? 0;

        return Food(
          docId: doc.id,
          name: data['foodName'] ?? '',
          baseCalories: calories,
          baseProtein: protein,
          baseCarbs: carbs,
          baseFat: fat,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          fdcId: null,
          servingSizes: [],
          selectedServing: null,
        );
      }).toList();

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userSnapshot = await userDocRef.get();
      _totalFoodsLogged = (userSnapshot.data()?['totalFoodsLogged'] ?? 0) as int;

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading foods from Firebase: $e");
    }
  }

  Future<void> addFood(Food food) async {
    _userFoodLog.add(food);
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final weekday = currentWeekday;
    final dayDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('calories')
        .doc(weekday);

    final foodRef = dayDocRef.collection('foods').doc();
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await foodRef.set({
        'foodName': food.name,
        'protein': food.protein,
        'carbs': food.carbs,
        'fat': food.fat,
        'calories': food.calories,
        'timestamp': Timestamp.fromDate(food.timestamp),
      });

      final daySnapshot = await dayDocRef.get();
      final userSnapshot = await userDocRef.get();
      final dayData = daySnapshot.data() ?? {};
      final currentTotal = (userSnapshot.data()?['totalFoodsLogged'] ?? 0) as int;

      final newCalories = (dayData['totalCalories'] ?? 0) + food.calories;
      final newProtein = (dayData['totalProtein'] ?? 0) + food.protein;
      final newCarbs = (dayData['totalCarbs'] ?? 0) + food.carbs;
      final newFat = (dayData['totalFat'] ?? 0) + food.fat;

      await Future.wait([
        dayDocRef.set({
          'totalCalories': newCalories,
          'totalProtein': newProtein,
          'totalCarbs': newCarbs,
          'totalFat': newFat,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
        userDocRef.set({
          'totalFoodsLogged': currentTotal + 1,
        }, SetOptions(merge: true)),
      ]);

      _totalFoodsLogged = currentTotal + 1;
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving food to Firebase: $e");
    }
  }

  Future<void> resetWeeklyData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    for (final day in weekdays) {
      final dayRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('calories')
          .doc(day);

      final foods = await dayRef.collection('foods').get();
      for (final doc in foods.docs) {
        await doc.reference.delete();
      }

      await dayRef.set({
        'totalCalories': 0,
        'totalProtein': 0,
        'totalCarbs': 0,
        'totalFat': 0,
      });
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userDocRef.set({'totalFoodsLogged': 0}, SetOptions(merge: true));

    _userFoodLog.clear();
    _totalFoodsLogged = 0;
    notifyListeners();
  }
}
