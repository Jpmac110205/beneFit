import 'package:game/screens/auth/widgets/add_friend_button.dart';
import 'package:game/screens/auth/widgets/friends_list_model.dart';

import '../../widgets/search_manager.dart';
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
  @override
  Widget build(BuildContext context) {
    final searchManager = Provider.of<SearchManager>(context);

    final isSearching = searchManager.isSearching;
    final displayList = isSearching ? searchManager.searchResults : friend_selections;

    // Update streak and sort
    for (var friend in displayList) {
      friend.updateStreak();
    }
    displayList.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return 0;
    });

    return Scaffold(
      appBar: AppBar(
            title: const Text('Search Friends', style: TextStyle(color: Colors.green)),
            backgroundColor: Colors.white,
          ),
      body: SafeArea(
        
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: searchManager.searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: searchManager.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: searchManager.clearSearch,
                        )
                      : null,
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
                        style: const TextStyle(fontSize: 16),
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
                                  Text(
                                    friend.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${friend.username}', // <- Make sure this field exists in your FriendsList model
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    friend.isActive
                                        ? 'Active Now'
                                        : 'Last Active: ${DateTime.now().difference(friend.lastActive).inHours} hours ago',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  AddFriendButton(targetUserId: friend.uid),
                                  const SizedBox(width: 12),
                                  Icon(
                                    friend.isActive ? Icons.check_circle : Icons.cancel,
                                    color: friend.isActive ? Colors.green : Colors.grey,
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
                                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${friend.streak}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}