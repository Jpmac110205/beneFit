import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game/screens/auth/home/views/friends/friends_list_model.dart';


class SearchManager with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<FriendsList> searchResults = [];
  bool isSearching = false;

  void disposeController() {
    searchController.dispose();
  }

  Future<void> searchUsers(String query) async {
    query = query.trim().toLowerCase();
    if (query.isEmpty) {
      isSearching = false;
      searchResults.clear();
      notifyListeners();
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    searchResults = snapshot.docs.map((doc) {
      final data = doc.data();
      return FriendsList(
        uid: doc.id,
        name: data['name'] ?? '',
        username: data['username'] ?? '',
        streak: data['streak'] ?? 0,
        lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();

    isSearching = true;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    searchUsers('');
  }
}
