
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getUserFriendsData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final docSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!docSnap.exists) return [];

  final data = docSnap.data();
  final List<dynamic> rawFriends = data?['friends'] ?? [];
  final List<String> friendIds = List<String>.from(rawFriends.whereType<String>());

  if (!friendIds.contains(user.uid)) {
    friendIds.add(user.uid);
  }

  final friendDocs = await Future.wait(friendIds.map((fid) async {
  final friendDoc = await FirebaseFirestore.instance.collection('users').doc(fid).get();
  if (!friendDoc.exists) return null;

  final friendData = friendDoc.data();
  return {
    'accountLevel': friendData?['accountLevel'] ?? 1, // default 1
    'name': friendData?['name'] ?? 'Unknown',
    'totalExp': friendData?['totalExp'] ?? 0,
    'isUser': fid == user.uid,
  };
}));


  final filtered = friendDocs.whereType<Map<String, dynamic>>().toList();
  filtered.sort((a, b) => (b['totalExp'] as int).compareTo(a['totalExp'] as int));
  return filtered;
}
