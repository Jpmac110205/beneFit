import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:game/app.dart';
import 'package:game/bloc/bloc/bloc/authentication_event.dart';
import 'package:game/screens/auth/home/views/calorieTracker/food_log_model.dart';
import 'package:game/screens/auth/home/views/theme_notifier.dart';
import 'package:game/simple_bloc_observer.dart';
import 'package:user_repository/user_repository.dart';
import 'package:provider/provider.dart';
import 'screens/auth/home/views/workoutTracker/workoutProvider.dart'; 
import 'screens/auth/home/views/friends/search_manager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();

  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadThemeFromFirebase();

  final userRepository = FirebaseUserRepo();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => SearchManager()),
        ChangeNotifierProvider(create: (_) => FoodLogModel()),
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
      ],
      child: RepositoryProvider.value(
        value: userRepository,
        child: BlocProvider(
          create: (context) => AuthenticationBloc(userRepository: userRepository),
          child: MyApp(userRepository),
        ),
      ),
    ),
  );
}
