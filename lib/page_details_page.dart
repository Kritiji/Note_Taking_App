import 'dart:ui';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import 'note_page.dart';

class PageDetailsPage extends StatefulWidget {
  final NotePage page;

  PageDetailsPage({required this.page});

  @override
  _PageDetailsPageState createState() => _PageDetailsPageState();
}

class _PageDetailsPageState extends State<PageDetailsPage> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.page.content;

    // Set up auto-save functionality
    _textEditingController.addListener(_savePage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final page = ModalRoute
        .of(context)
        ?.settings
        .arguments as NotePage?;
    if (page != null) {
      _textEditingController.text = page.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Page Details'),
        backgroundColor: Colors.transparent,
        elevation: 5,
      ),
      body: Container(
        color: Colors.grey[50], // Set the background color to grey
        child: Stack(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.5,
                child: _buildBackgroundCircles(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 100),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _textEditingController,
                            maxLines: null,
                            onChanged: (value) {
                              setState(() {
                                widget.page.content = value;
                              });
                            },
                            decoration: InputDecoration.collapsed(
                                hintText: 'Type your notes here...'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAiButtonWithMenu(),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.touch_app),
                onPressed: () {
                  // Gesture detector
                },
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () {
                  // Image picker
                },
              ),
              IconButton(
                icon: Icon(Icons.text_fields),
                onPressed: () {
                  // Text editor
                },
              ),
              IconButton(
                icon: Icon(Icons.color_lens),
                onPressed: () {
                  // Backgroud change
                },
              ),
            ],
          ),
        ),
      ),
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

  void _savePage() {
    // Implement the auto-save functionality here
    // For example, you can save the content to the database or storage
    widget.page.content = _textEditingController.text;
  }

  Widget _buildAiButtonWithMenu() {
    return SpeedDial(
      backgroundColor: Colors.teal,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.image_search, color: Colors.white),
          backgroundColor: Colors.orangeAccent,
          // label: 'Text to Image',
          onTap: () {
            // Implement icon text to image functionality here
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.co_present, color: Colors.white),
          backgroundColor: Colors.blue,
          // label: 'Contact',
          onTap: () {
            // Implement contact functionality here
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.text_snippet_outlined, color: Colors.white),
          backgroundColor: Colors.pinkAccent,
          // label: 'Image to Text',
          onTap: () {
            // Implement image to text extraction functionality here
          },
        ),
      ],
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