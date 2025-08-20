import 'package:game/screens/auth/home/views/friends/add_friend_button.dart';
import 'package:game/screens/auth/home/views/friends/friends_list_model.dart';

import 'search_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<FriendsList> friend_selections = [];

  @override
  Widget build(BuildContext context) {
    final searchManager = Provider.of<SearchManager>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isSearching = searchManager.isSearching;
    final displayList = isSearching ? searchManager.searchResults : friend_selections;

    displayList.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return 0;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Friends',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
        ),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.primary),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: searchManager.searchController,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                  hintText: 'Search by username',
                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  suffixIcon: searchManager.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: colorScheme.onSurface.withOpacity(0.6)),
                          onPressed: searchManager.clearSearch,
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                onChanged: searchManager.searchUsers,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: displayList.isEmpty
                  ? Center(
                      child: Text(
                        isSearching ? 'No users found' : 'No friends to show',
                        style: textTheme.titleMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final friend = displayList[index];
                        return Container(
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Friend info column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend.name,
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${friend.username}',
                                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    friend.isActive
                                        ? 'Active Now'
                                        : 'Last Active: ${DateTime.now().difference(friend.lastActive).inHours} hours ago',
                                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                ],
                              ),

                              // Buttons and icons row
                              Row(
                                children: [
                                  AddFriendButton(targetUserId: friend.uid),
                                  const SizedBox(width: 12),
                                  Icon(
                                    friend.isActive ? Icons.check_circle : Icons.cancel,
                                    color: friend.isActive ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
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
                                                        : colorScheme.onSurface.withOpacity(0.6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${friend.streak}',
                                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
