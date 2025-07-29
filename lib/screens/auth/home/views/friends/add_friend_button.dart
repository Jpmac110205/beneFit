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

      final List<dynamic> currentFriends = currentUserData['friends'] ?? [];
      final List<dynamic> outgoingRequests = currentUserData['outgoingRequests'] ?? [];
      final List<dynamic> incomingRequests = currentUserData['incomingRequests'] ?? [];

      // Check if already friends
      bool alreadyFriends = currentFriends.contains(widget.targetUserId);

      // Check if request already sent or received
      bool requestSent = outgoingRequests.contains(widget.targetUserId);
      bool requestReceived = incomingRequests.contains(widget.targetUserId);

      if (!mounted) return;
      setState(() {
        _isAlreadyFriend = alreadyFriends;
        _isRequestSent = requestSent || requestReceived;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking friend status: $e');
      if (!mounted) return;
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

      if (!mounted) return;
      setState(() {
        _isRequestSent = true;
      });
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    Color backgroundColor;
    if (_isAlreadyFriend) {
      backgroundColor = colorScheme.secondaryContainer;
    } else if (_isRequestSent) {
      backgroundColor = colorScheme.outlineVariant;
    } else {
      backgroundColor = colorScheme.primary;
    }

    IconData iconData;
    if (_isAlreadyFriend) {
      iconData = Icons.check;
    } else if (_isRequestSent) {
      iconData = Icons.close;
    } else {
      iconData = Icons.add;
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: (_isAlreadyFriend || _isRequestSent)
            ? null
            : () => _sendFriendRequest(widget.targetUserId),
        child: Icon(
          iconData,
          color: colorScheme.onPrimary,
          size: 20,
        ),
      ),
    );
  }
}
