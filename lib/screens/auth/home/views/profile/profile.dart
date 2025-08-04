import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game/bloc/bloc/bloc/authentication_bloc.dart';
import 'package:game/bloc/bloc/bloc/authentication_event.dart' hide AuthenticationBloc;
import 'package:game/screens/auth/home/views/profile/goals.dart';
import 'package:game/screens/auth/home/views/profile/settingspage.dart';
import 'package:game/screens/auth/home/views/challenges/challenges_home.dart';
import 'package:provider/provider.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileWidget();
}

class _ProfileWidget extends State<Profile> {
  final List<ChallengeBadges> badgeList = [];

  String username = '';
  String name = '';
  int streak = 0;
  int accountLevel = 0;
  bool isLoading = true;
  String email = '';

  @override
  void initState() {
    super.initState();
    pullUserData();
  }


  Future<void> pullUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('No user logged in');
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          username = data['username'] ?? '';
          name = data['name'] ?? 'No Name';
          streak = data['streak'] ?? 0;
          accountLevel = data['accountLevel'] ?? 0;
          isLoading = false;
          email = data['email'] ?? '';
        });
      } else {
        throw Exception('User document does not exist');
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: colorScheme.primary)),
        backgroundColor: colorScheme.onPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // vertical center
                      crossAxisAlignment: CrossAxisAlignment.center, // horizontal center
                      children: [
                        BadgeDisplay(badgeList: [ChallengeBadges(
                          tier: 3,
                          challenge: 'Protein Streak',
                          description: "Hit protein goal (3,8,15) days in a row",
                          icon: Icons.restaurant_menu,
                        ),
                        ChallengeBadges(
                          tier: 2,
                          challenge: 'Rank Riser',
                          description: "Hit Platinum Rank (1,3,5) times",
                          icon: Icons.military_tech,
                        ),
                        ChallengeBadges(
                          tier: 3, 
                          challenge: 'Iron Marathon',
                          description: "Workout for more than 2 hours",
                          icon: Icons.timer,
                        ),],),
                        const SizedBox(height: 20),
                        _buildInfoTile('Username', username, colorScheme),
                        const SizedBox(height: 20),
                        _buildInfoTile('Email', email, colorScheme),
                        const SizedBox(height: 20),
                        _buildInfoTile('Name', name, colorScheme),
                        const SizedBox(height: 20),
                        _buildInfoTile('Streak', streak.toString(), colorScheme),
                        const SizedBox(height: 20),
                        _buildInfoTile('Account Level', accountLevel.toString(), colorScheme),
                        const SizedBox(height: 40),
                        settingsButton(context, colorScheme),
                        const SizedBox(height: 20),
                        goalsButton(context, colorScheme),
                        const SizedBox(height: 20),
                        signOutButton(context, colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.onPrimary,
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget settingsButton(BuildContext context, ColorScheme colorScheme) {
      final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SettingsPage(),
            transitionsBuilder: (_, animation, __, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(-1.0, 0.0), // Slide in from left
                end: Offset.zero,
              ).animate(animation);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
        padding: const EdgeInsets.all(12),
        backgroundColor: colorScheme.surface,
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      child: const Text('Settings'),
    );
  }

  Widget goalsButton(BuildContext context, ColorScheme colorScheme) {
      final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const Goals()),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
        padding: const EdgeInsets.all(12),
        backgroundColor: colorScheme.surface,
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      child: const Text('Goals'),
    );
  }
  Widget signOutButton(BuildContext context, ColorScheme colorScheme) {
  return ElevatedButton(
    onPressed: () => { _signOut(context),
    Navigator.of(context).pop(context),
    },
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(200, 50),
      padding: const EdgeInsets.all(12),
      backgroundColor: Colors.red,
    ),
    child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
  );
}
  Future<void> _signOut(BuildContext context) async {
  context.read<AuthenticationBloc>().add(const AuthenticationLogoutRequested());
}
}

