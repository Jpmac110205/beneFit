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

  Future<void> _sendFriendRequest(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      // Add current user to target user's incomingRequests
      await usersRef.doc(targetUserId).update({
        'incomingRequests': FieldValue.arrayUnion([currentUserId])
      });

      // Add target user to current user's outgoingRequests
      await usersRef.doc(currentUserId).update({
        'outgoingRequests': FieldValue.arrayUnion([targetUserId])
      });

      // Update button UI
      setState(() {
        _isRequestSent = true;
      });
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRequestSent ? Colors.grey : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: _isRequestSent
            ? null // disable if request sent
            : () => _sendFriendRequest(widget.targetUserId),
        child: Icon(
          _isRequestSent ? Icons.close : Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
