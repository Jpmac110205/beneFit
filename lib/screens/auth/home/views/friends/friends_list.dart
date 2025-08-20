import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/challenges/challenges_home.dart';
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

  // Friend badges cache
  final Map<String, List<ChallengeBadges>> _friendsBadges = {};
  final Set<String> _loadingBadgesFor = {};

  // Track expanded card
  int? _expandedIndex;

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
        final List<String> friendsList =
            List<String>.from(rawFriends.whereType<String>());

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
  Future<bool> isActiveGetter(String friendId) async{
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    return data['isActive'] ?? false;
  }

  Future<void> _fetchFriendBadges(String friendId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(friendId).get();

      if (doc.exists) {
        final data = doc.data()!;
        final List<dynamic>? savedBadges = data['savedBadges'];
        List<ChallengeBadges> finalBadgeList;

        if (savedBadges != null && savedBadges.isNotEmpty) {
          finalBadgeList = savedBadges
              .map((badgeData) => ChallengeBadges.fromMap(badgeData))
              .toList();
        } else {
          finalBadgeList = [];
        }

        setState(() {
          _friendsBadges[friendId] = finalBadgeList;
        });
      }
    } catch (e) {
      debugPrint('Error fetching friend badges: $e');
    }
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
                              final isExpanded = _expandedIndex == index;

                              return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _expandedIndex = isExpanded ? null : index;
                                  });

                                  if (!isExpanded &&
                                      !_friendsBadges.containsKey(friend.uid) &&
                                      !_loadingBadgesFor.contains(friend.uid)) {
                                    setState(() {
                                      _loadingBadgesFor.add(friend.uid);
                                    });
                                    await _fetchFriendBadges(friend.uid);
                                    setState(() {
                                      _loadingBadgesFor.remove(friend.uid);
                                    });
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colorScheme.primary, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                    color: colorScheme.onPrimary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Friend info row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
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
                                              FutureBuilder<bool>(
                                                future: isActiveGetter(friend.uid),
                                                builder: (context, snapshot) {
                                                  final isActive = snapshot.data ?? false;
                                                  return Text(
                                                    isActive
                                                        ? 'Active Now'
                                                        : 'Inactive',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: colorScheme.outline,
                                                    ),
                                                  );
                                                },
                                              ),

                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                friend.isActive ? Icons.check_circle : Icons.cancel,
                                                color: friend.isActive
                                                    ? colorScheme.primary
                                                    : colorScheme.outline,
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

                                      // Expanded content
                                      AnimatedCrossFade(
                                        firstChild: const SizedBox.shrink(),
                                        secondChild: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            Divider(color: colorScheme.primary),
                                            const SizedBox(height: 8),
                                            if (_loadingBadgesFor.contains(friend.uid))
                                              Center(child: CircularProgressIndicator(color: colorScheme.primary))
                                            else
                                              BadgeDisplay(
                                                badgeList: _friendsBadges[friend.uid] ?? [],
                                                pressable: false,
                                              ),
                                          ],
                                        ),
                                        crossFadeState: isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration: const Duration(milliseconds: 300),
                                      ),
                                    ],
                                  ),
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
