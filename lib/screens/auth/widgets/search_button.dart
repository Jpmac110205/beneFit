import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/search_view.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // makes it full height
            backgroundColor: Colors.transparent, // for rounded corners effect
            builder: (context) => const _SearchModalSheet(),
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text('Search', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// Wrap SearchView in a custom container for better styling
class _SearchModalSheet extends StatelessWidget {
  const _SearchModalSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const SearchView(), // Your full-screen search view
        );
      },
    );
  }
}
