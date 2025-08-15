import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game/screens/auth/home/views/challenges/friends_service.dart';
import 'package:game/screens/auth/home/views/workoutTracker/start_workout_home.dart';




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
Future<void> markChallengeTierComplete(String challengeName, int tierNumber) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('challengeTracker')
      .doc('tracker')
      .set({
        challengeName: {
          'tier$tierNumber': true,
        }
      }, SetOptions(merge: true));
}

int tierValueChange(int tierSelected){
  if (tierSelected ==3 ) {return 50;}
  else if(tierSelected ==2) {return 35;}
  else { return 20;}
}

Future<int> updateTotalEXP(int addedNumber) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 0;

  final ref = FirebaseFirestore.instance.collection('users').doc(uid);
  final doc = await ref.get();
  final currentExp = (doc.data()?['totalExp'] ?? 0) as int;
  final updatedExp = currentExp + addedNumber;

  print("updateTotalEXP: current=$currentExp, added=$addedNumber, new=$updatedExp");

  await ref.update({'totalExp': updatedExp});
  return updatedExp;
}


Future<bool?> getChallengeTierStatus(String challengeName, int tierNumber) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('challengeTracker')
      .doc('tracker')
      .get();

  if (!doc.exists) return null;

  final data = doc.data();
  final challenge = data?[challengeName] as Map<String, dynamic>?;

  if (challenge == null) return null;

  return challenge['tier$tierNumber'] as bool?;
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
//FINISHED AND POLISHED
Future<int> proteinStreak() async {
  final streak = await getLongestProteinStreak();
  if (streak == null) return 0;

  int currentTier = 0;
  if (streak >= 15) {
    currentTier = 3;
  } else if (streak >= 8) {
    currentTier = 2;
  } else if (streak >= 3) {
    currentTier = 1;
  } else {
    return 0;
  }
  // Loop through and check each tier requirement before awarding
  for (int tier = 1; tier <= currentTier; tier++) {
    // Check if this tier requirement is met
    bool meetsRequirement = false;
    if (tier == 1 && streak >= 3) meetsRequirement = true;
    if (tier == 2 && streak >= 8) meetsRequirement = true;
    if (tier == 3 && streak >= 15) meetsRequirement = true;

    if (!meetsRequirement) continue;

    final alreadyCompleted = await getChallengeTierStatus('proteinStreak', tier);
    if (alreadyCompleted != true) {
      await updateTotalEXP(tierValueChange(tier));
      await markChallengeTierComplete("proteinStreak", tier);
    }
  }

  return currentTier;
}




//FINISHED AND POLISHED
Future<int> rankRiser() async {
  final totals = await getAllRankTotals();
  final platinumCount = totals['Platinum'] ?? 0;

  int currentTier = 0;

  if (platinumCount >= 5) {
    currentTier = 3;
  } else if (platinumCount >= 3) {
    currentTier = 2;
  } else if (platinumCount >= 1) {
    currentTier = 1;
  }

  if (currentTier == 0) return 0;

  // Reward all tiers up to the current tier that haven't been completed yet
  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('rankRiser', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("rankRiser", i);
      }
    }

  return currentTier;
}


//FINISHED AND POLISHED
Future<int> eliteClimber() async {
  final totals = await getAllRankTotals();
  final diamondCount = totals['Diamond'] ?? 0;

  int currentTier = 0;

  if (diamondCount >= 5) {
    currentTier = 3;
  } else if (diamondCount >= 3) {
    currentTier = 2;
  } else if (diamondCount >= 1) {
    currentTier = 1;
  }

  if (currentTier == 0) return 0;

  // Loop through tiers 1 to currentTier
  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('eliteClimber', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("eliteClimber", i);
      }
    }

  return currentTier;
}

//FINISHED AND POLISHED
Future<int> masteredIt() async {
  final totals = await getAllRankTotals();
  final masterCount = totals['Master'] ?? 0;

  int currentTier = 0;

  if (masterCount >= 5) {
    currentTier = 3;
  } else if (masterCount >= 3) {
    currentTier = 2;
  } else if (masterCount >= 1) {
    currentTier = 1;
  }

  if (currentTier == 0) return 0;

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('masteredIt', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("masteredIt", i);
      }
    }

  return currentTier;
}

//Finished and Polished
Future<int> topOfTheHill() async {
  int currentTier = 0;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userData = userDoc.data();
  if (userData == null) return 0;

  final List<dynamic> rawFriends = userData['friends'] ?? [];
  if (rawFriends.length < 5) return 0; // Need 5+ friends to qualify

  final friendsData = await getUserFriendsData();
  if (friendsData.isEmpty) return 0;

  final hasBeenTop = userData['hasBeenTopFriendLeaderboard'] ?? false;

  if (friendsData.first['isUser'] == true && !hasBeenTop) {
    currentTier = 2;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'hasBeenTopFriendLeaderboard': true,
    });
  } else if (hasBeenTop) {
    currentTier = 1;
  }

  if (currentTier == 0) return 0;

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('topOfTheHill', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("topOfTheHill", i);
      }
    }

  return currentTier;
}




Future<int> socialStarter() async {
  int currentTier = 0;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userData = userDoc.data();
  if (userData == null) return 0;

  final List<dynamic> rawFriends = userData['friends'] ?? [];

  if (rawFriends.length >= 30) {
    currentTier = 3;
  } else if (rawFriends.length >= 20) {
    currentTier = 2;
  } else if (rawFriends.length >= 10) {
    currentTier = 1;
  }

  if (currentTier == 0) return 0;

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('socialStarter', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("socialStarter", i);
      }
    }

  return currentTier;
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

  int currentTier = 0;

  if (currentStreak >= 100) {
    currentTier = 3;
  } else if (currentStreak >= 50) {
    currentTier = 2;
  } else if (currentStreak >= 10) {
    currentTier = 1;
  } else {
    currentTier = 0;
  }

  if (currentTier == 0) return 0;

  if (currentTier > highestMilestone) {
    await userRef.update({'highestStreakMilestone': currentTier});
  }

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('unbreakable', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("unbreakable", i);
      }
    }

  return currentTier;
}



//bool
Future<int> ironMarathon(Duration elapsed) async {
  final passed = await checkTimerTime(elapsed);
  if (!passed) return 0;

  int currentTier = 2; // Since the only tier here is 2 (based on original)

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('ironMarathon', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("ironMarathon", i);
      }
    }

  return currentTier;
}




Future<int> routineBuilder() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('workouts')
      .get();

  int workouts = querySnapshot.docs.length;

  int currentTier = 0;
  if (workouts >= 5) {
    currentTier = 3;
  } else if (workouts >= 3) {
    currentTier = 2;
  } else if (workouts >= 1) {
    currentTier = 1;
  }

  if (currentTier == 0) return 0;

  // Loop through all tiers up to currentTier and add EXP if not completed
  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('routineBuilder', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("routineBuilder", i);
      }
    }

  return currentTier;
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

  int currentTier = 0;
  if (maxTimesCompleted >= 50) {
    currentTier = 3;
  } else if (maxTimesCompleted >= 25) {
    currentTier = 2;
  } else if (maxTimesCompleted >= 10) {
    currentTier = 1;
  }

  if (currentTier == 0) return 0;

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('grinder', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("grinder", i);
      }
    }

  return currentTier;
}



Future<int> nutritionTracker() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userData = userDoc.data();
  if (userData == null) return 0;

  final int totalFoodsLogged = userData['totalFoodsLogged'] ?? 0;

  int currentTier = 0;
  if (totalFoodsLogged >= 250) {
    currentTier = 3;
  } else if (totalFoodsLogged >= 150) {
    currentTier = 2;
  } else if (totalFoodsLogged >= 75) {
    currentTier = 1;
  }

  if (currentTier == 0) return 0;

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('nutritionTracker', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("nutritionTracker", i);
      }
    }

  return currentTier;
}



//bool
Future<int> levelingUp() async {
  int currentTier = 0;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final userData = userDoc.data();
  if (userData == null) return 0;

  final bool isPremium = userData['isPremium'] ?? false;

  if (isPremium) {
    currentTier = 3;
  } else {
    currentTier = 0;
  }

  if (currentTier == 0) return 0;

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('levelingUp', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("levelingUp", i);
      }
    }

  return currentTier;
}




Future<int> heavyLifter() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0;

  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('workouts')
      .get();

  int totalVolume = 0;

  for (var workoutDoc in querySnapshot.docs) {
    final workoutData = workoutDoc.data();

    final exercises = workoutData['exercises'] as List<dynamic>?;
    if (exercises == null) continue;

    for (var exercise in exercises) {
      final sets = exercise['sets'] as List<dynamic>?;
      if (sets == null) continue;

      for (var set in sets) {
        final int weight = set['weight'] ?? 0;
        final int reps = set['reps'] ?? 0;
        totalVolume += weight * reps;
      }
    }

    // Optional: update workout doc with totalVolume if you want to store it
    await workoutDoc.reference.update({'totalVolume': totalVolume});
  }

  int currentTier = 0;

  if (totalVolume >= 40000) {
    currentTier = 3;
  } else if (totalVolume >= 25000) {
    currentTier = 2;
  } else if (totalVolume >= 15000) {
    currentTier = 1;
  } else {
    return 0;
  }

  for(int i = 1; i <= currentTier;i++){
      if((await getChallengeTierStatus('heavyLifter', i)) != true)
      {
        await updateTotalEXP(tierValueChange(i));
        await markChallengeTierComplete("heavyLifter", i);
      }
    }

  return currentTier;
}

