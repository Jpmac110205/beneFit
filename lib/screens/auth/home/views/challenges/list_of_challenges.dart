import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/challenges/challenges.dart';
import 'package:game/screens/auth/home/views/challenges/challenges_home.dart';




Future<List<ChallengeBadges>> buildChallengeBadges(Duration elapsed) async {
  return[
  ChallengeBadges(tier: await proteinStreak(), challenge: 'Protein Streak', description: "Hit protein goal (3,8,15) days in a row", icon: Icons.restaurant_menu),
  ChallengeBadges(tier: await rankRiser(), challenge: 'Rank Riser', description: "Hit Platinum Rank (1,3,5) times", icon: Icons.military_tech),
  ChallengeBadges(tier: await eliteClimber(), challenge: 'Elite Climber', description: "Hit Diamond Rank (1,3,5) times",icon: Icons.emoji_events),
  ChallengeBadges(tier: await masteredIt(), challenge: 'Mastered It', description: "Hit Master Rank (1,3,5) times", icon: Icons.workspace_premium),
  ChallengeBadges(tier: await topOfTheHill(), challenge: 'Top of the Hill', description: "Hit the top of your friends' leaderboard (must have min 5 friends)",icon: Icons.leaderboard),
  ChallengeBadges(tier: await socialStarter(), challenge: 'Social Starter', description: "Add (10,20,30) friends", icon:Icons.group_add ),
  ChallengeBadges(tier: await unbreakable(), challenge: 'Unbreakable', description: "Obtain a streak of (10,50,100)", icon: Icons.local_fire_department),
  ChallengeBadges(tier: await ironMarathon(elapsed), challenge: 'Iron Marathon', description: "Workout for more than 2 hours",icon: Icons.timer),
  ChallengeBadges(tier: await routineBuilder(), challenge: 'Routine Builder', description: "Add (1,3,5) workouts", icon: Icons.playlist_add),
  ChallengeBadges(tier: await grinder(), challenge: 'Grinder', description: "Complete a single workout (10,25,50) times", icon: Icons.repeat),
  ChallengeBadges(tier: await nutritionTracker(), challenge: 'Nutrition Tracker', description: "Track (75,150,250) foods",icon: Icons.food_bank),
  ChallengeBadges(tier: await levelingUp(), challenge: 'Leveling Up', description: "Become a premium user",icon: Icons.star_border),
  ChallengeBadges(tier: await heavyLifter(), challenge: 'Heavy Lifter', description: "Lift a total volume of (15k,25k,40k)", icon: Icons.fitness_center),
];
}