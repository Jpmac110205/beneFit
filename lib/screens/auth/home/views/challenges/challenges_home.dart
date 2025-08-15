// your imports
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game/screens/auth/home/views/challenges/friends_service.dart';
import 'package:game/screens/auth/home/views/challenges/list_of_challenges.dart';
import 'package:game/screens/auth/home/views/workoutTracker/workoutProvider.dart';


class ChallengesHome extends StatefulWidget {
  const ChallengesHome({super.key});

  @override
  State<ChallengesHome> createState() => _ChallengesHomeState();
}

class _ChallengesHomeState extends State<ChallengesHome> {
  final user = FirebaseAuth.instance.currentUser;

  int userAccountLevel = 0;
  int userTotalExp = 0;
  double levelProgress = 0.0;

  late Duration elapsed;
  List<Map<String, dynamic>>? cachedFriends;
  List<ChallengeBadges>? cachedChallenges;
  List<ChallengeBadges> badgeList = [];

  @override
  void initState() {
    super.initState();
    elapsed = Duration(seconds: WorkoutProvider().secondsWorkedOut);
    loadInitialData();
  }

  Future<void> loadInitialData() async {
  await loadUserLevelAndProgress(); // Only load once (includes badges)
  await loadFriendsData();          // Load other stuff
  final challenges = await buildChallengeBadges(elapsed); // for _buildChallengesTab
  if (mounted) {
    setState(() {
      cachedChallenges = challenges;
    });
  }
}


  
  Future<void> saveBadgeListToFirestore() async {
  final badgeMaps = badgeList.map((badge) => badge.toMap()).toList();

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .set({
        'savedBadges': badgeMaps,
      }, SetOptions(merge: true)); // ensures existing fields are not overwritten
}


  Future<void> loadUserLevelAndProgress() async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get();
  final data = doc.data();

  final List<dynamic>? savedBadges = data?['savedBadges'];
  final currentLevel = data?['accountLevel'] ?? 1;
  final totalExp = data?['totalExp'] ?? 0;
  final levelData = accountLevelCalculator(1, totalExp);

  if (levelData['level'] > currentLevel) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'accountLevel': levelData['level']});
  }

  List<ChallengeBadges> finalBadgeList;

  if (savedBadges != null && savedBadges.isNotEmpty) {
    finalBadgeList = savedBadges
        .map((badgeData) => ChallengeBadges.fromMap(badgeData))
        .toList();
  } else {
    // fallback if nothing is stored yet
    final challenges = await buildChallengeBadges(elapsed);
    finalBadgeList = List.generate(3, (index) {
      if (index < challenges.length) {
        return challenges[index];
      } else {
        return const ChallengeBadges(
          tier: 1,
          challenge: 'DEFAULT',
          description: 'DEFAULT',
          icon: Icons.add,
        );
      }
    });
  }

  if (!mounted) return;

  setState(() {
    badgeList = finalBadgeList;
    userAccountLevel = levelData['level'];
    userTotalExp = totalExp;
    levelProgress = levelData['progress'];
  });
}


  Future<void> loadFriendsData() async {
    final friends = await getUserFriendsData();
    if (!mounted) return;
    setState(() {
      cachedFriends = friends;
    });
  }

  Future<void> loadChallengeBadges() async {
    final challenges = await buildChallengeBadges(elapsed);
    await loadUserLevelAndProgress();
    if (!mounted) return;

    // Fill badgeList with either challenge or default icon if null
    setState(() {
      cachedChallenges = challenges;
      badgeList = List.generate(3, (index) {
        if (index < challenges.length) {
          return challenges[index];
        } else {
          return const ChallengeBadges(
            tier: 1,
            challenge: 'DEFAULT',
            description: 'DEFAULT',
            icon: Icons.add,
          );
        }
      });
    });
  }

  Future<void> replaceChallengeDisplay(ChallengeBadges currentBadge) async {
  final List<ChallengeBadges> options = List.from(badgeList);

  final selectedIndex = await showDialog<int>(
    context: context,
    builder: (context) {
      return Dialog(
  backgroundColor: Colors.transparent,
  child: SizedBox(
    width: MediaQuery.of(context).size.width - 50, // Set your desired width here
    child: BadgeDisplay(
      badgeList: options,
      pressable: true,
      onBadgeSelected: (index, _) {
        Navigator.pop(context, index);
      },
    ),
  ),
);
    },
  );

  if (selectedIndex != null) {
    setState(() {
      badgeList[selectedIndex] = currentBadge;
    });
    await saveBadgeListToFirestore();
  }
}


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Tracker', style: TextStyle(color: Colors.green)),
        backgroundColor: colorScheme.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          children: [
            userAccountLevel == 0
                ? const Center(child: CircularProgressIndicator())
                : levelBar(context, colorScheme, userAccountLevel, levelProgress),
            const SizedBox(height: 30),
            badgeList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : BadgeDisplay(
                    badgeList: badgeList,
                    pressable: false,
                  ),
            const SizedBox(height: 30),
            buildFriendsLeaderboard(colorScheme),
            const SizedBox(height: 30),
            buildChallengesTab(colorScheme),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget buildFriendsLeaderboard(ColorScheme colorScheme) {
    if (cachedFriends == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
      BoxShadow(
        color: colorScheme.primary,
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
      ),
      child: Column(
        children: [
          Text('Friends Leaderboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 16),
          for (int i = 0; i < cachedFriends!.length && i < 5; i++)
            Text(
              '${i + 1}. ${cachedFriends![i]['name']}: Level ${cachedFriends![i]['accountLevel']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: cachedFriends![i]['isUser'] ? FontWeight.bold : FontWeight.normal,
                color: cachedFriends![i]['isUser'] ? Colors.green : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildChallengesTab(ColorScheme colorScheme) {
    if (cachedChallenges == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: colorScheme.onPrimary,
    border: Border.all(color: Colors.green, width: 2),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: colorScheme.primary,
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Challenges',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      const SizedBox(height: 16),

      for (final challenge in cachedChallenges!)
        InkWell(
          onTap: () {
            if (challenge.tier >= 1) {
              replaceChallengeDisplay(challenge);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: formatBadgeImage(challenge, colorScheme),
                ),
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
                          color: challenge.tier >= 1
                              ? Colors.green
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  ),
);

  }

  Widget formatBadgeImage(ChallengeBadges challenge, ColorScheme colorScheme) {
  final imagePath = imagePathForTier(challenge.tier);

  return Stack(
    alignment: Alignment.center,
    children: [
      Image.asset(
        imagePath,
        width: 80,      // <-- This controls the background size
        height: 80,     // <-- This controls the background size
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_not_supported, size: 50),
      ),
      Icon(
        challenge.icon,
        size: 40,       // <-- This controls the icon size
        color: colorScheme.onSurface,
      ),
    ],
  );
}


  String imagePathForTier(int tier) {
    switch (tier) {
      case 3:
        return 'images/TIER3.png';
      case 2:
        return 'images/TIER2.png';
      default:
        return 'images/TIER1.png';
    }
  }

  Map<String, dynamic> accountLevelCalculator(int level, int exp) {
  int cap = 50 + ((level - 1) * 5);
  int newLevel = level;
  int remainingExp = exp;

  while (remainingExp >= cap) {
    remainingExp -= cap;
    newLevel++;
    cap = 50 + ((newLevel - 1) * 5);
  }

  return {
    'level': newLevel,
    'progress': remainingExp / cap,
  };
}


  Widget levelBar(BuildContext context, ColorScheme colorScheme, int level, double progress) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
      BoxShadow(
        color: colorScheme.primary,
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          circleWithText(level),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 15,
                color: Colors.green,
                backgroundColor: colorScheme.surface,
              ),
            ),
          ),
          circleWithText(level + 1),
        ],
      ),
    );
  }

  Widget circleWithText(int number) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withOpacity(0.1),
        border: Border.all(color: Colors.green, width: 2),
      ),
      
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }
}

class BadgeDisplay extends StatelessWidget {
  final List<ChallengeBadges> badgeList;
  final bool pressable;
  final void Function(int index, ChallengeBadges badge)? onBadgeSelected;

  const BadgeDisplay({
    super.key,
    required this.badgeList,
    required this.pressable,
    this.onBadgeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamically calculate badge size based on screen width
        double badgeSize = (constraints.maxWidth / 4).clamp(60, 100);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.onPrimary,
            border: Border.all(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(badgeList.length, (index) {
              final badge = badgeList[index];
              return InkWell(
                onTap: pressable ? () => onBadgeSelected?.call(index, badge) : null,
                child: SizedBox(
                  width: badgeSize,
                  height: badgeSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        imagePathForTier(badge.tier),
                        width: badgeSize,
                        height: badgeSize,
                        fit: BoxFit.contain,
                      ),
                      Icon(
                        badge.icon,
                        size: badgeSize * 0.5,
                        color: colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  String imagePathForTier(int tier) {
    switch (tier) {
      case 3:
        return 'images/TIER3.png';
      case 2:
        return 'images/TIER2.png';
      default:
        return 'images/TIER1.png';
    }
  }
}

class ChallengeBadges {
  final int tier;
  final String challenge;
  final String description;
  final IconData icon;

  const ChallengeBadges({
    required this.tier,
    required this.challenge,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'tier': tier,
      'challenge': challenge,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'iconDirection': icon.matchTextDirection,
    };
  }

  factory ChallengeBadges.fromMap(Map<String, dynamic> map) {
    return ChallengeBadges(
      tier: map['tier'],
      challenge: map['challenge'],
      description: map['description'],
      icon: IconData(
        map['iconCodePoint'],
        fontFamily: map['iconFontFamily'],
        fontPackage: map['iconFontPackage'],
        matchTextDirection: map['iconDirection'],
      ),
    );
  }
}
