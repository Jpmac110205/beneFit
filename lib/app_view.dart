import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:game/bloc/bloc/bloc/authentication_bloc.dart';
import 'package:game/screens/auth/home/sign_in_bloc/bloc/sign_in_bloc.dart';
import 'package:game/screens/auth/home/views/homepage/home_screen.dart';
import 'package:game/screens/auth/home/views/welcome_screen.dart';
import 'package:game/screens/auth/home/views/theme_notifier.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    // Using Builder to get a new context with access to ThemeNotifier
    return Builder(
      builder: (context) {
        final themeNotifier = Provider.of<ThemeNotifier>(context);

        return MaterialApp(
          title: 'BeneFIT',
          debugShowCheckedModeBanner: false,
          themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              surface: Colors.grey.shade300,
              onSurface: Colors.black,
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.grey.shade300,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black87),
              titleLarge: TextStyle(color: Colors.black),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              surface: Colors.grey.shade900,
              onSurface: Colors.white,
              primary: Colors.green,
              onPrimary: Colors.black,
            ),
            scaffoldBackgroundColor: Colors.grey.shade900,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
              titleLarge: TextStyle(color: Colors.white),
            ),
          ),
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state.status == AuthenticationStatus.authenticated) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => SignInBloc(
                        context.read<AuthenticationBloc>().userRepository,
                      ),
                    ),
                  ],
                  child: const HomeScreen(),
                );
              } else {
                return const WelcomeScreen();
              }
            },
          ),
        );
      },
    );
  }
}
