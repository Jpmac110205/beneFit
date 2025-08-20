import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsList {
  final String uid;
  final String username;
  final String name;
  int streak;
  final DateTime lastActive;

  FriendsList({
    required this.uid,
    required this.username,
    required this.name,
    required this.streak,
    required this.lastActive,
  });

  /// Considered active if active within the last 24 hours
bool get isActive => DateTime.now().difference(lastActive) <= Duration(minutes: 5);


  /// Factory constructor to build FriendsList object from Firestore data
  factory FriendsList.fromMap(String uid, Map<String, dynamic> data) {
    return FriendsList(
      uid: uid,
      name: data['name'] ?? 'Unknown',
      username: data['username'] ?? '',
      streak: data['streak'] ?? 0,
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
