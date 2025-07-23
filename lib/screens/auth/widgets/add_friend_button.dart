import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFriendButton extends StatefulWidget {
  final String targetUserId;

  const AddFriendButton({super.key, required this.targetUserId});

  @override
  State<AddFriendButton> createState() => _AddFriendButtonState();
}

class _AddFriendButtonState extends State<AddFriendButton> {
  bool _isRequestSent = false;
  bool _isAlreadyFriend = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFriendStatus();
  }

  Future<void> _checkFriendStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
if (currentUser == null) {
  // User not signed in! Show login or error message.
  print("User not authenticated.");
  return;
}
final currentUserId = currentUser.uid;

    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      final currentUserDoc = await usersRef.doc(currentUserId).get();
      final targetUserDoc = await usersRef.doc(widget.targetUserId).get();

      if (!currentUserDoc.exists || !targetUserDoc.exists) return;

      final currentUserData = currentUserDoc.data()!;
      final targetUserData = targetUserDoc.data()!;

      final List<dynamic> currentFriends = currentUserData['friends'] ?? [];
      final List<dynamic> outgoingRequests = currentUserData['outgoingRequests'] ?? [];
      final List<dynamic> incomingRequests = currentUserData['incomingRequests'] ?? [];

      // Check if already friends
      bool alreadyFriends = currentFriends.contains(widget.targetUserId);

      // Check if request already sent or received
      bool requestSent = outgoingRequests.contains(widget.targetUserId);
      bool requestReceived = incomingRequests.contains(widget.targetUserId);

      setState(() {
        _isAlreadyFriend = alreadyFriends;
        _isRequestSent = requestSent || requestReceived;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking friend status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(String targetUserId) async {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) return;

  final usersRef = FirebaseFirestore.instance.collection('users');

  try {
    // Update target user's incomingRequests
    await usersRef.doc(targetUserId).update({
      'incomingRequests': FieldValue.arrayUnion([currentUserId]),
    });


    // Update current user's outgoingRequests
    await usersRef.doc(currentUserId).update({
      'outgoingRequests': FieldValue.arrayUnion([targetUserId]),
    });


    setState(() {
      _isRequestSent = true;
    });
  } catch (e) {
    print('Error sending friend request: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isAlreadyFriend
              ? Colors.blueGrey // Different color if already friends
              : _isRequestSent
                  ? Colors.grey
                  : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: (_isAlreadyFriend || _isRequestSent)
            ? null
            : () => _sendFriendRequest(widget.targetUserId),
        child: Icon(
          _isAlreadyFriend
              ? Icons.check // Show check icon if already friends
              : _isRequestSent
                  ? Icons.close
                  : Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
