import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game/screens/auth/widgets/friends_list_model.dart';

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
    // Step 1: Update current user — remove incomingRequest and add friend
    await currentUserRef.update({
      'incomingRequests': FieldValue.arrayRemove([requesterId]),
      'friends': FieldValue.arrayUnion([requesterId]),
    });

    // Step 2: Update requester user — remove outgoingRequest and add friend
    await requesterRef.update({
      'outgoingRequests': FieldValue.arrayRemove([currentUserId]),
      'friends': FieldValue.arrayUnion([currentUserId]),
    });

    // Remove from UI
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Requests', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : incomingFriendList.isEmpty
                ? const Center(child: Text('No incoming requests', style: TextStyle(fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: incomingFriendList.length,
                    itemBuilder: (context, index) {
                      final friend = incomingFriendList[index];
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
                                Text(friend.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('@${friend.username}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  friend.isActive
                                      ? 'Active Now'
                                      : 'Last Active: ${DateTime.now().difference(friend.lastActive).inHours}h ago',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => confirmFriendRequest(friend.uid),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    side: const BorderSide(color: Colors.green, width: 2),
                                  ),
                                  child: const Text('Confirm', style: TextStyle(color: Colors.green)),
                                ),
                                const SizedBox(width: 12),
                                Icon(friend.isActive ? Icons.check_circle : Icons.cancel,
                                    color: friend.isActive ? Colors.green : Colors.grey),
                                const SizedBox(width: 8),
                                Icon(Icons.local_fire_department,
                                    color: friend.streak >= 100
                                        ? Colors.blue
                                        : friend.streak >= 50
                                            ? Colors.purple
                                            : friend.streak >= 20
                                                ? Colors.red
                                                : friend.streak == 1
                                                    ? Colors.yellow
                                                    : Colors.grey,
                                    size: 20),
                                const SizedBox(width: 4),
                                Text('${friend.streak}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
