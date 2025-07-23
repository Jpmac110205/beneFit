import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game/screens/auth/widgets/friends_list_model.dart';
import 'package:game/screens/auth/widgets/incoming_request.dart';
import 'package:game/screens/auth/widgets/search_button.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<FriendsList> confirmedFriends = [
    // Initial mock/test data
    FriendsList(
      streak: 5,
      lastActive: DateTime.now(),
      uid: 'test_uid1',
      username: 'jack1128',
      name: 'Jack',
    ),
    FriendsList(
      streak: 50,
      lastActive: DateTime.now().subtract(const Duration(hours: 4)),
      uid: 'test_uid2',
      username: 'tbones',
      name: 'Tyler',
    ),
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userDoc.get();

      final friendsMap = userSnapshot.data()?['friends'] as Map<String, dynamic>?;

      if (friendsMap == null || friendsMap.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      List<FriendsList> fetchedFriends = [];

      for (final fid in friendsMap.keys) {
        final fSnap = await FirebaseFirestore.instance.collection('users').doc(fid).get();
        if (fSnap.exists && fSnap.data() != null) {
          fetchedFriends.add(FriendsList.fromMap(fid, fSnap.data()!));
        }
      }

      if (!mounted) return;

      setState(() {
        confirmedFriends = fetchedFriends;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching friends: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update streaks and sort
    for (var friend in confirmedFriends) {
      friend.updateStreak();
    }

    confirmedFriends.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return 0;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
              children: [
                const SizedBox(height: 50), // vertical space before Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SearchButton(),
                SizedBox(width: 16), // horizontal space between buttons
                IncomingRequest(),
              ],
            ),
            SizedBox(height: 50),
                  Expanded(
                    child: confirmedFriends.isEmpty
                        ? const Center(
                            child: Text(
                              'No friends found',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: confirmedFriends.length,
                      itemBuilder: (context, index) {
                        final friend = confirmedFriends[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${friend.username}', // <- Make sure this field exists in your FriendsList model
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    friend.isActive
                                        ? 'Active Now'
                                        : 'Last Active: ${DateTime.now().difference(friend.lastActive).inHours} hours ago',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    friend.isActive ? Icons.check_circle : Icons.cancel,
                                    color: friend.isActive ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.local_fire_department,
                                    color: friend.streak >= 100
                                        ? Colors.blue
                                        : friend.streak >= 50
                                            ? Colors.purple
                                            : friend.streak >= 20
                                                ? Colors.red
                                                : friend.streak > 1
                                                    ? Colors.orange
                                                    : friend.streak == 1
                                                        ? Colors.yellow
                                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${friend.streak}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
