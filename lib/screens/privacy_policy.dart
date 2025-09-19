import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: TextStyle(color: colorScheme.primary)),
        backgroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            _privacyPolicyText,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}

// Paste your privacy policy text here as a Dart string
const String _privacyPolicyText = '''
Effective Date: September 18th, 2025
We at BeneFIT respect your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and share your information when you use our mobile application.

1. Information We Collect
We collect the following information to provide, improve, and personalize your experience:
Personal Information
* Email address
* Username
App Activity and Progress
* Challenges completed
* Badges earned
* Foods tracked
* Workouts added (including sets, weights)
* Current rank for each exercise
* Macro-specific goals
* Activity streaks
* Total experience points (EXP)
* User account level
* Premium subscription status
Social and Interaction Data
* Friends lists
* Leaderboards
* Incoming and outgoing friend requests
* Activity status
Device and Health Data
* Steps and activity data from health apps (if enabled)
* Device information (device type, OS version)
* IP address
Third-Party Services
* Firebase Authentication and Firestore for account management and data storage
* Analytics services for usage tracking (if applicable)

2. How We Use Your Information
We use your data to:
* Provide and improve the functionality of the App
* Track your workouts, challenges, and progress
* Display your rank, streaks, and badges in the App
* Manage social interactions, friends, and leaderboards
* Personalize your experience, including macro and workout goals
* Maintain account security and prevent fraud
* Communicate with you regarding updates, support, or promotions
* Comply with legal obligations

3. How We Share Your Information
We may share your data:
* With other users for social features, leaderboards, and friend requests
* With service providers who help operate the App (e.g., Firebase)
* If required by law or legal process
* In the event of a business transfer (merger, acquisition, sale)
We do not sell your personal information to third parties.

4. Data Storage and Security
* Your information is stored securely in Firebase Authentication and Firestore.
* We use encryption and other security measures to protect your data.
* We retain your information as long as your account is active or as necessary to provide services.

5. Your Rights
Depending on your location, you may have the right to:
* Access and review your personal data
* Request correction or deletion of your data
* Opt-out of marketing communications
* Withdraw consent for data collection at any time
To exercise these rights, please contact us at [your email address].

6. Children’s Privacy
Our App is not intended for children under 13 (or the applicable age in your region). We do not knowingly collect personal information from children.

7. Updates to This Policy
We may update this Privacy Policy from time to time. The “Effective Date” will indicate the latest version. Please check this page periodically for updates.

8. Contact Us
If you have questions or concerns about this Privacy Policy or our data practices, contact us at:
Email: jpmac1102@outlook.com

''';
