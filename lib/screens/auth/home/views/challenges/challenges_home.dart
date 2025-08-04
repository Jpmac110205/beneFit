import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/challenges/list_of_challenges.dart';
import 'package:game/screens/auth/home/views/challenges/friends_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengesHome extends StatefulWidget {
  const ChallengesHome({super.key});

  @override
  State<ChallengesHome> createState() => _ChallengesHomeState();
}

class _ChallengesHomeState extends State<ChallengesHome> {
  int userAccountLevel = 0;
  int userTotalExp = 0;
  double levelProgress = 0.0;
  final List<ChallengeBadges> badgeList = [
  ChallengeBadges(
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
  ),
];


  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadUserLevelAndProgress();
      }
  

  void loadUserLevelAndProgress() async {
  final docSnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  final data = docSnap.data();
  int currentLevel = data?['accountLevel'] ?? 1;
  int totalExp = data?['totalExp'] ?? 0;

  final levelData = accountLevelCalculator(currentLevel, totalExp);

  if (levelData['level'] > currentLevel) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'accountLevel': levelData['level']});
  }

  // Add a mounted check before setState
  if (!mounted) return;

  setState(() {
    userAccountLevel = levelData['level'];
    userTotalExp = totalExp;
    levelProgress = levelData['progress'];
  });
}

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
              children: [
                const SizedBox(height: 30),
                levelBar(context, colorScheme),
                const SizedBox(height: 30),
                BadgeDisplay(badgeList: badgeList),
                const SizedBox(height: 30),
                friendsLeaderboard(context, colorScheme),
                const SizedBox(height: 30),
                challengesTab(context, colorScheme),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget friendsLeaderboard(BuildContext context, ColorScheme colorScheme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getUserFriendsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data ?? [];

        return SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Friends Leaderboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (int i = 0; i < friends.length && i < 5; i++)
                        Text(
                          '${i + 1}. ${friends[i]['name']}: Level ${friends[i]['accountLevel']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: friends[i]['isUser'] == true
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: friends[i]['isUser'] == true
                                ? Colors.green
                                : colorScheme.onSurface,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget challengesTab(BuildContext context, ColorScheme colorScheme) {
  return SizedBox(
    width: MediaQuery.of(context).size.width - 50,
    child: Container(
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Challenges',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            FutureBuilder<List<ChallengeBadges>>(
              future: buildChallengeBadges(), // your async badge builder
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final challenges = snapshot.data ?? [];

                return Column(
                  children: challenges.map((challenge) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          formatBadgeImage(challenge, colorScheme),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  challenge.challenge,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: challenge.tier != 0
                                      ? Colors.green 
                                      : colorScheme.onSurface, 
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  challenge.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: 0.6,
                                  backgroundColor: colorScheme.surface,
                                  color: Colors.green,
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}


 Widget levelBar(BuildContext context, ColorScheme colorScheme) {
  int leftValue = userAccountLevel;
  int rightValue = userAccountLevel + 1;

  return SizedBox(
    width: MediaQuery.of(context).size.width - 50,
    height: 100,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleWithText(leftValue, colorScheme),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: LinearProgressIndicator(
                value: levelProgress,
                minHeight: 20,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          _circleWithText(rightValue, colorScheme),
        ],
      ),
    ),
  );
}


  Map<String, dynamic> accountLevelCalculator(int level, int exp) {
  int accountLevelCap = 50 + ((level - 1) * 15);
  int newLevel = level;
  int remainingExp = exp;

  while (remainingExp >= accountLevelCap) {
    remainingExp -= accountLevelCap;
    newLevel++;
    accountLevelCap = 50 + ((newLevel - 1) * 15);
  }
  

  double progress = remainingExp / accountLevelCap;

  return {
    'level': newLevel,
    'progress': progress,
    'xpCap': accountLevelCap,
    'progressPercentage': (progress * 100).toStringAsFixed(1),
  };
}



}

Widget _circleWithText(int number, ColorScheme colorScheme) {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: colorScheme.primary.withOpacity(0.2),
      border: Border.all(color: Colors.green, width: 2),
    ),
    alignment: Alignment.center,
    child: Text(
      '$number',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    ),
  );
}

Widget formatBadgeImage(ChallengeBadges challenge, ColorScheme colorScheme) {
  String imagePath;
  switch (challenge.tier) {
    case 3:
      imagePath = 'images/TIER3.png';
      break;
    case 2:
      imagePath = 'images/TIER2.png';
      break;
    default:
      imagePath = 'images/TIER1.png';
      break;
  }

  return Stack(
    alignment: Alignment.center,
    children: [
      Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_not_supported, size: 50),
      ),
      Icon(
        challenge.icon,
        size: 45,
        color: colorScheme.onSurface,
      ),
    ],
  );
}

class ChallengeBadges {
  final int tier;
  final String challenge;
  final String description;
  final IconData icon;

  ChallengeBadges({
    required this.tier,
    required this.challenge,
    required this.description,
    required this.icon,
  });
}
class BadgeDisplay extends StatelessWidget {
  final List<ChallengeBadges> badgeList;

  const BadgeDisplay({super.key, required this.badgeList});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: MediaQuery.of(context).size.width - 50,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: badgeList
                .map((badge) => formatBadgeImage(badge, colorScheme))
                .toList(),
          ),
        ),
      ),
    );
  }
}
