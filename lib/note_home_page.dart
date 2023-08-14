import 'package:flutter/material.dart';
import 'folder_details_page.dart';
//import 'favorite_folders_page.dart';

class NoteHomePage extends StatefulWidget {
  @override
  _NoteHomePageState createState() => _NoteHomePageState();
}
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

class _NoteHomePageState extends State<NoteHomePage> {
  String searchTerm = '';
  List<Folder> favoriteFolders = [];
  List<Folder> folders = [];
  List<bool> folderSelection = [];

  @override
  Widget build(BuildContext context) {
    // Add the 3-dot menu button to the AppBar
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Note Taking App'),
        backgroundColor: Colors.transparent,
        elevation: 5,
        actions: [
          _buildPopupMenuButton(),
        ],
      ),
      body: Stack(
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.5,
              // This will make the circle cover the top half of the screen
              child: _buildBackgroundCircles(), // Add background circle
            ),
          ),
          folders.isEmpty
              ? Center(
              child: _buildEmptyFolderMessage()) // Center the message when there are no folders
              : Column(
            children: [
              SizedBox(height: 16),
              Expanded(child: _buildFolderList()),
              // Use Expanded to make the ListView take remaining space
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Center the plus button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFolderDialog();
        },
        child: Icon(Icons.add),
        elevation: 4,
        backgroundColor: Colors.teal.withOpacity(0.7),
        foregroundColor: Colors.black,
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBackgroundCircles() {
    double circleRadius = 300; // Adjust the circle radius as desired

    return Stack(
      children: [
        Positioned(
          top: -circleRadius,
          left: MediaQuery
              .of(context)
              .size
              .width / 2 - circleRadius,
          child: Container(
            width: circleRadius * 2,
            height: circleRadius * 2,
            child: ClipPath(
              clipper: BackgroundCircleClipper(),
              child: CustomPaint(
                painter: BackgroundCirclePainter(circleRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

// Method to build the 3-dot menu button
  Widget _buildPopupMenuButton() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
        PopupMenuItem<String>(
          value: 'archive',
          child: Text('Archive'),
        ),
        PopupMenuItem<String>(
          value: 'rename',
          child: Text('Rename'),
        ),
        PopupMenuItem<String>(
          value: 'favorite',
          child: Text('Favorite'),
        ),
      ],
    );
  }


  // Method to build the bottom app bar with space for FAB
  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.star_purple500),
              onPressed: () {
                List<Folder> favoriteFolders = folders.where((folder) => folder.isFavorite).toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage(favoriteFolders: favoriteFolders)),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _showSearchDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  // void _showFavoriteFoldersPage() {
  //   // Filter out the favorite folders
  //   List<Folder> favoriteFolders = folders.where((folder) => folder.isFavorite).toList();
  //   print('Favorite Folders: $favoriteFolders'); // Add this line to print favoriteFolders
  //
  //   // Navigate to FavoritesPage
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => FavoritesPage(favoriteFolders: favoriteFolders)),
  //   );
  // }
  //
  // Widget _buildFavoriteFoldersPage(List<Folder> favoriteFolders) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Favorite Folders'),
  //     ),
  //     body: Center(
  //       child: Text('Your favorite folders will be displayed here.'),
  //     ),
  //   );
  // }

  void _showSearchDialog() async {
    String enteredSearchTerm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentSearchTerm = '';
        return AlertDialog(
          title: Text('Search Folder'),
          content: TextField(
            onChanged: (value) {
              currentSearchTerm = value;
            },
            decoration: InputDecoration(labelText: 'Search'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(currentSearchTerm);
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );

    if (enteredSearchTerm != true) {
      setState(() {
        searchTerm = enteredSearchTerm;
      });
    }
  }

  void _handleMenuSelection(String value) {
    if (value == 'delete') {
      _deleteSelectedFolders();
    } else if (value == 'archive') {
      _archiveSelectedFolders();
    } else if (value == 'rename') {
      _renameSelectedFolders();
    } else if (value == 'favorite') {
      _toggleSelectedFoldersFavorite();
    }
  }


  void _deleteSelectedFolders() {
    setState(() {
      final List<bool> folderSelectionCopy = List.from(folderSelection);
      for (int i = folders.length - 1; i >= 0; i--) {
        if (folderSelectionCopy[i]) {
          folders.removeAt(i);
          folderSelection.removeAt(i);
        }
      }
    });
  }

  void _archiveSelectedFolders() {
    setState(() {
      for (int i = 0; i < folders.length; i++) {
        if (folderSelection[i]) {
          folders[i].isArchived = true;
          folderSelection[i] = false;
        }
      }
    });
  }

  void _renameSelectedFolders() {
    // Find the index of the first selected folder
    int selectedIndex = folderSelection.indexWhere((selected) => selected);
    if (selectedIndex == -1) {
      // No folder selected, return
      return;
    }

    String currentName = folders[selectedIndex].name;

    _showRenameFolderDialog(context, folders[selectedIndex], currentName);
  }

  void _showRenameFolderDialog(BuildContext context, Folder folder, String currentName) {
    String newName = currentName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename Folder'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(labelText: 'New Folder Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  folder.name = newName;
                  folderSelection.fillRange(0, folderSelection.length, false); // Deselect all folders
                });
                Navigator.of(context).pop();
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSelectedFoldersFavorite() {
    setState(() {
      for (int i = 0; i < folders.length; i++) {
        if (folderSelection[i]) {
          folders[i].isFavorite = !folders[i].isFavorite;
          folderSelection[i] = false;
        }
      }
    });
  }


  Widget _buildEmptyFolderMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder_open,
          size: 80,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Text(
          'NO Folder till now',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Click on the add button to add a folder',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFolderList() {
    final filteredFolders = _filterFolders(searchTerm);

    return ListView.builder(
      itemCount: filteredFolders.length,
      itemBuilder: (context, index) {
        final folderColor = _getRandomColor(index);
        return LongPressDraggable<int>(
          data: index,
          child: _buildFolderTile(index, folderColor),
          onDragStarted: () {
            setState(() {
              folderSelection[index] = true;
            });
          },
          onDraggableCanceled: (_, __) {
            setState(() {
              folderSelection[index] = false;
            });
          },
          feedback: Material(
            child: _buildFolderTile(index, folderColor),
          ),
          childWhenDragging: _buildFolderTile(index, folderColor),
        );
      },
    );
  }
  List<Folder> _filterFolders(String searchTerm) {
    return folders.where((folder) {
      final folderName = folder.name.toLowerCase();
      final searchTermLower = searchTerm.toLowerCase();
      return folderName.contains(searchTermLower);
    }).toList();
  }

  Widget _buildFolderTile(int index, Color folderColor) {
    final folder = folders[index];
    Color tileColor = folderColor.withOpacity(0.7);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          if (folderSelection[index]) {
            // Perform folder selection actions here
            setState(() {
              folderSelection[index] = false;
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FolderDetailsPage(folder: folders[index]),
              ),
            );
          }
        },
        child: Card(
          color: tileColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        folder.isFavorite ? Icons.star_border_purple500 : Icons.star_border,
                        color: folder.isFavorite ? Colors.amber : null,
                      ),
                      onPressed: () {
                        setState(() {
                          folder.isFavorite = !folder.isFavorite;
                        });
                      },
                    ),
                    SizedBox(width: 8), // Add some spacing between the heart icon and the text
                    Text(
                      folders[index].name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddFolderDialog() {
    String folderName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Folder'),
          content: TextField(
            onChanged: (value) {
              folderName = value;
            },
            decoration: InputDecoration(labelText: 'Folder Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  folders.add(Folder(name: folderName));
                  folderSelection.add(false);
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Color _getRandomColor(int index) {
    // Define a list of custom color values with unique RGB combinations
    List<Color> customColors = [
      Color(0xFFFFDDA1),
      Color(0xFFCCCCFF),
      Color(0xFF000000),
      Color.fromARGB(255, 12, 107, 187),
      Color.fromARGB(255, 255, 153, 0),
      Color.fromARGB(255, 6, 182, 212),
      Color.fromARGB(255, 232, 74, 95),
      Color.fromARGB(255, 30, 130, 76),
      Color(0xFFFFC7A7),
      Color.fromARGB(255, 155, 89, 182),
      Color.fromARGB(255, 211, 84, 0),
      Color.fromARGB(255, 52, 152, 219),
    ];

    // Return the color based on the index, but ensure it's within the range of customColors
    return customColors[index % customColors.length];
  }
}

class BackgroundCirclePainter extends CustomPainter {
  final double circleRadius;

  BackgroundCirclePainter(this.circleRadius);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.5, circleRadius), circleRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BackgroundCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

