import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Goals extends StatefulWidget {
  const Goals({super.key});

  @override
  State<Goals> createState() => _GoalsWidget();
}

class _GoalsWidget extends State<Goals> {
  final TextEditingController _calorieController = TextEditingController();

  double proteinPercent = 30;
  double carbsPercent = 40;
  double fatPercent = 30;

  @override
  void initState() {
    super.initState();
    loadUserPercentages();
  }

  int get calories => int.tryParse(_calorieController.text) ?? 0;

  int get proteinGrams => ((proteinPercent / 100) * calories / 4).round();
  int get carbsGrams => ((carbsPercent / 100) * calories / 4).round();
  int get fatGrams => ((fatPercent / 100) * calories / 9).round();

  void loadUserPercentages() async {
    final docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final data = docSnap.data();
    if (data != null) {
      setState(() {
        proteinPercent = data['proteinPercent']?.toDouble() ?? 30.0;
        carbsPercent = data['carbsPercent']?.toDouble() ?? 40.0;
        fatPercent = data['fatPercent']?.toDouble() ?? 30.0;
        _calorieController.text = data['calorieGoal']?.toString() ?? '';
      });
    }
  }

  void _updateMacro(String macro, double newValue) {
    double remaining = 100 - newValue;

    setState(() {
      switch (macro) {
        case 'Protein':
          proteinPercent = newValue;
          double otherTotal = carbsPercent + fatPercent;
          if (otherTotal == 0) {
            carbsPercent = remaining / 2;
            fatPercent = remaining / 2;
          } else {
            carbsPercent = (carbsPercent / otherTotal) * remaining;
            fatPercent = remaining - carbsPercent;
          }
          break;

        case 'Carbs':
          carbsPercent = newValue;
          double otherTotal = proteinPercent + fatPercent;
          if (otherTotal == 0) {
            proteinPercent = remaining / 2;
            fatPercent = remaining / 2;
          } else {
            proteinPercent = (proteinPercent / otherTotal) * remaining;
            fatPercent = remaining - proteinPercent;
          }
          break;

        case 'Fat':
          fatPercent = newValue;
          double otherTotal = proteinPercent + carbsPercent;
          if (otherTotal == 0) {
            proteinPercent = remaining / 2;
            carbsPercent = remaining / 2;
          } else {
            proteinPercent = (proteinPercent / otherTotal) * remaining;
            carbsPercent = remaining - proteinPercent;
          }
          break;
      }
    });

    _saveMacrosToFirebase();
  }

  void _saveMacrosToFirebase() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'proteinPercent': proteinPercent,
      'carbsPercent': carbsPercent,
      'fatPercent': fatPercent,
      'calorieGoal': calories,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Goals', style: TextStyle(color: colorScheme.primary)),
        backgroundColor: colorScheme.onPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Calorie Goal", style: theme.textTheme.titleMedium),
              TextField(
                controller: _calorieController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter calories',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => _saveMacrosToFirebase()),
              ),
              const SizedBox(height: 20),

              Text("Macro Percentages", style: theme.textTheme.titleMedium),
              _macroSlider("Protein", proteinPercent),
              _macroSlider("Carbs", carbsPercent),
              _macroSlider("Fat", fatPercent),

              const SizedBox(height: 20),
              const Divider(),
              Text("Macro Grams", style: theme.textTheme.titleMedium),
              Text("Protein: $proteinGrams g", style: theme.textTheme.bodyLarge),
              Text("Carbs: $carbsGrams g", style: theme.textTheme.bodyLarge),
              Text("Fat: $fatGrams g", style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
    );
  }

  Widget _macroSlider(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toStringAsFixed(1)}%", style: Theme.of(context).textTheme.bodyMedium),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 1000,
          label: "${value.toStringAsFixed(1)}%",
          onChanged: (newValue) {
            if (newValue <= 100) _updateMacro(label, newValue);
          },
        ),
      ],
    );
  }
}
