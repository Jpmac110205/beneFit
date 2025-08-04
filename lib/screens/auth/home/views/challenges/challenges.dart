import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game/screens/auth/home/views/challenges/friends_service.dart';


Future<Map<String, int>> getAllRankTotals() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return {};
  
  

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('ranked')
      .doc('rankedTotals')
      .get();

  if (doc.exists) {
    final data = doc.data()?['totals'] as Map<String, dynamic>?;

    return data?.map((k, v) => MapEntry(k, v as int)) ?? {};
  }

  return {};
}


Future<int?> getLongestProteinStreak() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('challenges')
      .doc('longestProteinStreak')
      .get();

  if (doc.exists) {
    return doc.data()?['longestProteinStreak'] as int?;
  }

  return null;
}

Future<int> proteinStreak() async {
  final streak = await getLongestProteinStreak();

  if (streak == null) return 0;

  if (streak >= 15) {
    return 3;
  } else if (streak >= 8) return 2;
  else if (streak >= 3) return 1;
  else return 0;
}


Future<int> rankRiser() async {
  final totals = await getAllRankTotals();
  final platinumCount = totals['Platinum'] ?? 0;

  if (platinumCount >= 5) {
    return 3;
  } else if (platinumCount >= 3) {
    return 2;
  } else if (platinumCount >= 1) {
    return 1;
  }
  return 0;
}

Future <int> eliteClimber() async {
  final totals = await getAllRankTotals();
  final dimaondCount = totals['Diamond'] ?? 0;

  if (dimaondCount >= 5) {
    return 3;
  } else if (dimaondCount >= 3) {
    return 2;
  } else if (dimaondCount >= 1) {
    return 1;
  }
  return 0;
}

Future <int> masteredIt() async {
  final totals = await getAllRankTotals();
  final masterCount = totals['Master'] ?? 0;

  if (masterCount >= 5) {
    return 3;
  } else if (masterCount >= 3) {
    return 2;
  } else if (masterCount >= 1) {
    return 1;
  }
  return 0;
}
Future<int> topOfTheHill() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userData = userDoc.data();
  if (userData == null) return 0;

  final List<dynamic> rawFriends = userData['friends'] ?? [];
  if (rawFriends.length < 5) return 0; // Need 5 or more friends

  final friendsData = await getUserFriendsData();
  if (friendsData.isEmpty) return 0;

  final hasBeenTop = userData['hasBeenTopFriendLeaderboard'] ?? false;

  if (friendsData.first['isUser'] == true && !hasBeenTop) {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'hasBeenTopFriendLeaderboard': true,
    });
    return 1;
  }

  return hasBeenTop ? 1 : 0;
}

int consistencyKing() {
  return 1;
}

Future <int> socialStarter() async{
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userData = userDoc.data();
  if (userData == null) return 0;

  final List<dynamic> rawFriends = userData['friends'] ?? [];
  if (rawFriends.length >= 30) {
    return 3;
  } else if(rawFriends.length >= 20) return 2;
  else if(rawFriends.length >= 10) return 1;
  return 0;
}

Future<int> unbreakable() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final userDoc = await userRef.get();
  final userData = userDoc.data();
  if (userData == null) return 0;

  final int currentStreak = userData['streak'] ?? 0;
  final int highestMilestone = userData['highestStreakMilestone'] ?? 0;

  int newMilestone = highestMilestone;

  if (currentStreak >= 100) {
    newMilestone = 3;
  } else if (currentStreak >= 50 && highestMilestone < 2) {
    newMilestone = 2;
  } else if (currentStreak >= 10 && highestMilestone < 1) {
    newMilestone = 1;
  }

  if (newMilestone > highestMilestone) {
    await userRef.update({'highestStreakMilestone': newMilestone});
  }

  return newMilestone;
}


int squadGoals() {
  return 0;
}

int doubleTrouble() {
  return 0;
}

//bool
int ironMarathon() {
  return 0;
}

//bool
int fastLeveler() {
  return 0;
}

//boolv
Future<int> routineBuilder() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('workouts')
      .get();

  int workouts = 0;

  for (var doc in querySnapshot.docs) {
    workouts++;
  }

  if (workouts == 5) {return 3;}
  else if(workouts >= 3) {return 2;}
  else if (workouts >= 1) {return 1;}
  else {return 0;} 
  
}


Future<int> grinder() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('workouts')
      .get();

  int maxTimesCompleted = 0;

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final timesCompleted = data['timesCompleted'] ?? 0;
    if (timesCompleted > maxTimesCompleted) {
      maxTimesCompleted = timesCompleted;
    }
  }

  if (maxTimesCompleted >= 50) {return 3;}
  else if(maxTimesCompleted >= 25) {return 2;}
  else if (maxTimesCompleted >= 10) {return 1;}
  else {return 0;} 
}

int nutritionTracker() {
  return 0;
}

//bool
Future <int> levelingUp() async {
final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userData = userDoc.data();
  if (userData == null) return 0;

  final bool isPremium = userData['isPremium'] ?? false;
    return isPremium ? 3: 0;
}

int pushupDuelist() {
  return 0;
}

int heavyLifter() {
  return 0;
}


int socialButterfly() {
  return 0;
}
