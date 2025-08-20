import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


/// Call this when the user is active (app in foreground)
Future<void> markUserActive() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  await userDocRef.update({
    'isActive': true,
    'lastActive': Timestamp.fromDate(DateTime.now()),
  });
}

/// Call this when checking if the user has gone inactive
/// Automatically marks them inactive if more than [inactiveThresholdMinutes] have passed
Future<void> updateUserActiveStatus({int inactiveThresholdMinutes = 5}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final userDoc = await userDocRef.get();
  final data = userDoc.data();
  if (data == null) return;

  final Timestamp? lastActiveTimestamp = data['lastActive'] as Timestamp?;
  if (lastActiveTimestamp == null) {
    await userDocRef.update({'isActive': false});
    return;
  }

  final now = DateTime.now();
  final lastActive = lastActiveTimestamp.toDate();

  if (now.difference(lastActive).inMinutes >= inactiveThresholdMinutes) {
    await userDocRef.update({'isActive': false});
  } else {
    await userDocRef.update({'isActive': true});
  }
}

/// Update streak based on last streak date
Future<void> updateStreak() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final userDoc = await userDocRef.get();
  final data = userDoc.data();
  if (data == null) return;

  final Timestamp? lastStreakTimestamp = data['lastStreakUpdate'] as Timestamp?;
  final int currentStreak = (data['streak'] ?? 0) as int;
  final now = DateTime.now();

  if (lastStreakTimestamp == null) {
    // First time using the app
    await userDocRef.update({
      'streak': 1,
      'lastStreakUpdate': Timestamp.fromDate(now),
    });
    return;
  }

  final lastStreakDate = lastStreakTimestamp.toDate();
  final difference = now.difference(lastStreakDate).inDays;

  if (difference == 1) {
    // Consecutive day → increment streak
    await userDocRef.update({
      'streak': currentStreak + 1,
      'lastStreakUpdate': Timestamp.fromDate(now),
    });
  } else if (difference > 1) {
    // Missed one or more days → reset streak
    await userDocRef.update({
      'streak': 0,
      'lastStreakUpdate': Timestamp.fromDate(now),
    });
  }
  // else difference == 0 → already updated today, do nothing
}