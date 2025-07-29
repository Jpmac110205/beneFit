import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/friends/incoming_requests_view.dart';

class IncomingRequest extends StatelessWidget {
  final VoidCallback? onPressed;

  const IncomingRequest({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncomingRequestView(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface, // adapt to theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
          elevation: 2,
        ),
        child: Icon(
          Icons.mail,
          color: colorScheme.primary, // use theme primary color
          size: 20,
        ),
      ),
    );
  }
}
