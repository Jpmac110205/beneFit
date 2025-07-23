import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsList {
  String uid;
  String username;
  String name;
  int streak;
  DateTime lastActive;

  FriendsList({
    required this.uid,
    required this.username,
    required this.name,
    required this.streak,
    DateTime? lastActive,
  }) : lastActive = lastActive ?? DateTime.now();

  bool get isActive => DateTime.now().difference(lastActive).inHours <= 24;

  void updateStreak() {
    final hoursAgo = DateTime.now().difference(lastActive).inHours;
    if (hoursAgo <= 24) {
      streak += 1;
    } else {
      streak = 0;
    }
  }

  factory FriendsList.fromMap(String uid, Map<String, dynamic> data) {
    return FriendsList(
      uid: uid,
      name: data['displayName'] ?? '',
      username: data['username'] ?? '',
      streak: data['streak'] ?? 0,
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

}
