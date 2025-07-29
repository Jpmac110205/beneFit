import 'package:flutter/material.dart';

class ChallengesHome extends StatefulWidget {
  const ChallengesHome({super.key});

  @override
  State<ChallengesHome> createState() => _ChallengesHome();
}

class _ChallengesHome extends State<ChallengesHome> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Challenge Tracker',
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: colorScheme.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
            )
          )
        )
      )
    );
  }
}