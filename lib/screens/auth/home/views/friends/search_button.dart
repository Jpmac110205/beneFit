import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/friends/search_view.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 150,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              'Search',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
            BoxShadow(
              color: colorScheme.primary,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          ),
          child: const SearchView(), // Your full-screen search view
        );
      },
    );
  }
}
