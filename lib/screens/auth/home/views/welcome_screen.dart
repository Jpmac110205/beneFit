import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game/bloc/bloc/bloc/authentication_bloc.dart';
import 'package:game/screens/auth/home/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:game/screens/auth/home/sign_up_bloc/bloc/sign_up_bloc.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // App Logo / Title
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  Image.asset(
                    'images/d2.png',
                    height: 220,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Fitness Journey Starts Here',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              child: TabBar(
                controller: tabController,
                unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
                labelColor: colorScheme.onSurface,
                indicator: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Text('Sign In'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Expanded Tab Content
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  BlocProvider<SignInBloc>(
                    create: (context) => SignInBloc(
                      context.read<AuthenticationBloc>().userRepository,
                    ),
                    child: const SignInScreen(),
                  ),
                  BlocProvider<SignUpBloc>(
                    create: (context) => SignUpBloc(
                      context.read<AuthenticationBloc>().userRepository,
                    ),
                    child: const SignUpScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
