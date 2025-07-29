import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/friends/friends_list_model.dart';
import 'package:game/screens/auth/home/views/friends/incoming_request_button.dart';
import 'package:game/screens/auth/home/views/friends/search_button.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<FriendsList> confirmedFriends = [];

  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningToFriends();
  }

  void _startListeningToFriends() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    _userSubscription = userDoc.snapshots().listen(
      (snapshot) async {
        if (!snapshot.exists) {
          setState(() {
            confirmedFriends = [];
            _isLoading = false;
          });
          return;
        }

        final data = snapshot.data()!;
        final List<dynamic> rawFriends = data['friends'] ?? [];
        final List<String> friendsList = List<String>.from(rawFriends.whereType<String>());

        final uniqueFriends = friendsList.toSet().toList();

        if (uniqueFriends.isEmpty) {
          if (!mounted) return;
          setState(() {
            confirmedFriends = [];
            _isLoading = false;
          });
          return;
        }

        List<FriendsList> fetchedFriends = [];
        for (final fid in uniqueFriends) {
          try {
            final doc = await FirebaseFirestore.instance.collection('users').doc(fid).get();
            if (doc.exists) {
              final friendData = doc.data()!;
              fetchedFriends.add(FriendsList(
                uid: fid,
                username: friendData['username'] ?? '',
                name: friendData['name'] ?? 'No Name',
                streak: friendData['streak'] ?? 0,
                lastActive: (friendData['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
              ));
            }
          } catch (e) {
            debugPrint('Error fetching friend $fid: $e');
          }
        }

        if (!mounted) return;
        setState(() {
          confirmedFriends = fetchedFriends;
          _isLoading = false;
        });
      },
      onError: (error) {
        debugPrint('Error listening to user document: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sort friends: active first
    confirmedFriends.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return 0;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Friends List',
          style: TextStyle(color: colorScheme.primary),
          
        ),
        backgroundColor: colorScheme.onPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : Column(
                children: [
                  const SizedBox(height: 50),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SearchButton(),
                      SizedBox(width: 16),
                      IncomingRequest(),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    child: confirmedFriends.isEmpty
                        ? Center(
                            child: Text(
                              'No friends found',
                              style: theme.textTheme.bodyMedium,
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
                                  border: Border.all(color: colorScheme.primary, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                  color: colorScheme.onPrimary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.shadow.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Friend info column
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          friend.name,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '@${friend.username}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          friend.isActive
                                              ? 'Active Now'
                                              : 'Last Active: ${DateTime.now().difference(friend.lastActive).inHours} hours ago',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          friend.isActive ? Icons.check_circle : Icons.cancel,
                                          color: friend.isActive ? colorScheme.primary : colorScheme.outline,
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
                                                              : colorScheme.outline,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${friend.streak}',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
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
