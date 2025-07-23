import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/incoming_requests_view.dart';

class IncomingRequest extends StatelessWidget {
  final VoidCallback? onPressed;

  const IncomingRequest({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed ?? () {
          // Default action if none provided
          Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncomingRequestView(),
                ),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
          ),
          padding: EdgeInsets.zero,
          elevation: 2,
        ),
        child: const Icon(
          Icons.mail, // or Icons.inbox
          color: Colors.green, // contrast against white background
          size: 20,
        ),
      ),
    );
  }
}
