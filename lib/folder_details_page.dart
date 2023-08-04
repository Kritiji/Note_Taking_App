import 'package:flutter/material.dart';
import 'note_page.dart';

class Folder {
  String name;
  bool isArchived;
  bool isFavorite;

  Folder({required this.name, this.isArchived = false, this.isFavorite = false});
}

class FolderDetailsPage extends StatefulWidget {
  final Folder folder;

  FolderDetailsPage({required this.folder});

  @override
  _FolderDetailsPageState createState() => _FolderDetailsPageState();
}

class _FolderDetailsPageState extends State<FolderDetailsPage> {
  List<NotePage> pages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.folder.name),
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
              child: _buildBackgroundCircles(),
            ),
          ),
          pages.isEmpty
              ? Center(
            child: _buildEmptyPageMessage(),
          )
              : _buildPageList(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPageDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal.withOpacity(0.7),
        foregroundColor: Colors.black,
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildPopupMenuButton() {
    return PopupMenuButton<String>(
      //onSelected: _handleMenuSelection,
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

  Widget _buildBackgroundCircles() {
    double circleRadius = 300; // Adjust the circle radius as desired

    return Stack(
      children: [
        Positioned(
          top: -circleRadius,
          left: MediaQuery.of(context).size.width / 2 - circleRadius,
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

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.star_purple500,
              color: Colors.black, // Set the color to black
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Implement search functionality here
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPageMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.note,
          size: 80,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Text(
          'No Pages in this Folder',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Click on the add button to add a page',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPageList() {
    return Padding(
      padding: EdgeInsets.only(top: kToolbarHeight + 28),
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 16, // Spacing between columns
          mainAxisSpacing: 16, // Spacing between rows
        ),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/pageDetails', arguments: page);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: CoverPage(
                name: page.name,
                content: page.content,
                isFavorite: page.isFavorite,
                pageNumber: index + 1,
                onStarTapped: () {
                  toggleFavorite(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void toggleFavorite(int pageIndex) {
    setState(() {
      pages[pageIndex].isFavorite = !pages[pageIndex].isFavorite;
    });
  }

  void _showAddPageDialog() {
    String? pageName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Page'),
          content: TextField(
            onChanged: (value) {
              pageName = value;
            },
            decoration: InputDecoration(labelText: 'Page Name'),
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
                if (pageName != null && pageName!.isNotEmpty) {
                  setState(() {
                    pages.add(NotePage(name: pageName!, content: ''));
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
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

class CoverPage extends StatelessWidget {
  final String name;
  final String content;
  final bool isFavorite;
  final int pageNumber;
  final VoidCallback onStarTapped;

  CoverPage({
    required this.name,
    required this.content,
    required this.isFavorite,
    required this.pageNumber,
    required this.onStarTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          if (content.isEmpty) // Display name when content is empty
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (content.isEmpty)
                  Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      pageNumber.toString(),
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          if (content.isNotEmpty) // Display content when it is not empty
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text(
                      pageNumber.toString(),
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: onStarTapped, // Call the onStarTapped function when the star is tapped
              child: Icon(
                isFavorite ? Icons.star_purple500 : Icons.star,
                color: isFavorite ? Colors.amber : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

