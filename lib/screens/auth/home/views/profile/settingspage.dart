import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:game/screens/auth/home/views/profile/manageAccount.dart';
import 'package:game/screens/auth/home/views/theme_notifier.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loadingTheme = true;

  @override
  void initState() {
    super.initState();
    _loadThemeFromFirebase();
  }

  Future<void> _loadThemeFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final isDarkMode = doc.data()?['isDarkMode'] as bool? ?? false;

      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
      themeNotifier.setTheme(isDarkMode);
    }

    setState(() => _loadingTheme = false);
  }

  Future<void> _updateDarkModePreference(bool isDarkMode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'isDarkMode': isDarkMode},
        SetOptions(merge: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if (_loadingTheme) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
        backgroundColor: colorScheme.onPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,   
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dark Mode', style: theme.textTheme.bodyMedium),
                    Switch(
                      value: themeNotifier.isDarkMode,
                      activeThumbColor: theme.colorScheme.primary, // Use activeColor instead
                      inactiveThumbColor: theme.disabledColor,
                      onChanged: (value) {
                        themeNotifier.setTheme(value);
                        _updateDarkModePreference(value);
                      },
                    )
                  ],
                ),
                const SizedBox(height: 50),
                contactSupportButton(context),
                const SizedBox(height: 25),
                PrivacyPolicyButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
Future<void> sendEmail() async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'jpmac1102@outlook.com',
    query: Uri.encodeFull('subject=App Feedback'),
  );

  if (await canLaunchUrl(emailLaunchUri)) {
    await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch email client';
  }
}


Widget manageAccountButton(BuildContext context) {
  final theme = Theme.of(context);

  return ElevatedButton(
    onPressed: () {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ManageAccount(),
          transitionsBuilder: (_, animation, __, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
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
      backgroundColor: theme.cardColor,
      side: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
    child: Text(
      'Manage Account',
      style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyLarge?.color),
    ),
  );
}

Widget contactSupportButton(BuildContext context) {
  final theme = Theme.of(context);

  return ElevatedButton(
    onPressed: () {
      sendEmail(); // just call the function directly
    },
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(200, 50),
      padding: const EdgeInsets.all(12),
      backgroundColor: theme.cardColor,
      side: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
    child: Text(
      'Contact Support',
      style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyLarge?.color),
    ),
  );
}
Widget PrivacyPolicyButton(BuildContext context) {
  final theme = Theme.of(context);

  return ElevatedButton(
    onPressed: () {
    },
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(200, 50),
      padding: const EdgeInsets.all(12),
      backgroundColor: theme.cardColor,
      side: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
    child: Text(
      'Privacy Policy',
      style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyLarge?.color),
    ),
  );
}


