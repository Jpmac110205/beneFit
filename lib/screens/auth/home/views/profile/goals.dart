import 'package:flutter/material.dart';

class Goals extends StatefulWidget {
  const Goals({super.key});

  @override
  State<Goals> createState() => _GoalsWidget();
}

class _GoalsWidget extends State<Goals> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Goals', style: TextStyle(color: colorScheme.primary)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Target Calories \n Weight Tracking \n Progress \n Show Streak \n Badge Selection',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}
