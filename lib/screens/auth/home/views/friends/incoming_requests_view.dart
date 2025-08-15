import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/friends/friends_list_model.dart';

class IncomingRequestView extends StatefulWidget {
  const IncomingRequestView({super.key});

  @override
  State<IncomingRequestView> createState() => _IncomingRequestViewState();
}

class _IncomingRequestViewState extends State<IncomingRequestView> {
  List<FriendsList> incomingFriendList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final data = userDoc.data();

      if (data == null || !data.containsKey('incomingRequests')) {
        setState(() => _isLoading = false);
        return;
      }

      List<String> incomingRequests = List<String>.from(data['incomingRequests']);
      List<FriendsList> fetchedFriends = [];

      for (final requestId in incomingRequests) {
        final friendDoc = await FirebaseFirestore.instance.collection('users').doc(requestId).get();
        if (friendDoc.exists && friendDoc.data() != null) {
          fetchedFriends.add(FriendsList.fromMap(requestId, friendDoc.data()!));
        }
      }

      if (!mounted) return;
      setState(() {
        incomingFriendList = fetchedFriends;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching requests: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> confirmFriendRequest(String requesterId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || requesterId.isEmpty) return;

    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final requesterRef = FirebaseFirestore.instance.collection('users').doc(requesterId);

    try {
      await currentUserRef.update({
        'incomingRequests': FieldValue.arrayRemove([requesterId]),
        'friends': FieldValue.arrayUnion([requesterId]),
      });

      await requesterRef.update({
        'outgoingRequests': FieldValue.arrayRemove([currentUserId]),
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      setState(() {
        incomingFriendList.removeWhere((f) => f.uid == requesterId);
      });
    } catch (e) {
      print('Error confirming friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to confirm friend request")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Incoming Requests',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
        ),
        backgroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.primary),
        elevation: 1,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : incomingFriendList.isEmpty
                ? Center(
                    child: Text(
                      'No incoming requests',
                      style: textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: incomingFriendList.length,
                    itemBuilder: (context, index) {
                      final friend = incomingFriendList[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary,
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
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '@${friend.username}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  friend.isActive
                                      ? 'Active Now'
                                      : 'Last Active: ${DateTime.now().difference(friend.lastActive).inHours}h ago',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => confirmFriendRequest(friend.uid),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.surface,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    side: BorderSide(color: colorScheme.primary, width: 2),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(color: colorScheme.primary),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                              : friend.streak == 1
                                                  ? Colors.yellow
                                                  : colorScheme.outline,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${friend.streak}',
                                  style: textTheme.titleMedium?.copyWith(
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
    );
  }
}
