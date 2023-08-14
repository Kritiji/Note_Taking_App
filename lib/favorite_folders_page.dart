// favorite_folders_page.dart
import 'package:flutter/material.dart';
import 'folder_details_page.dart'; // Import your folder model

class FavoritesPage extends StatelessWidget {
  final List<Folder> favoriteFolders;

  FavoritesPage({required this.favoriteFolders});

  @override
  Widget build(BuildContext context) {
    print('Received Favorite Folders: $favoriteFolders'); // Add this line to print received data

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Folders'),
      ),
      body: favoriteFolders.isEmpty
          ? Center(
        child: Text(
          'There are no favorites yet.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: favoriteFolders.length,
        itemBuilder: (context, index) {
          final folder = favoriteFolders[index];
          return ListTile(
            title: Text(folder.name),
            // Customize the ListTile as needed
          );
        },
      ),
    );
  }
}
