import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'note_page.dart';
import 'text_to_image_page.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notetaking/ChatGpt.dart';

class PageDetailsPage extends StatefulWidget {
  final NotePage page;

  PageDetailsPage({required this.page});

  @override
  _PageDetailsPageState createState() => _PageDetailsPageState();
}

class _PageDetailsPageState extends State<PageDetailsPage> {
  TextEditingController _textEditingController = TextEditingController();
  bool _isDrawing = false;
  List<List<Offset>> _drawingPaths = [];

  Color _selectedColor = Colors.black;
  double _selectedStrokeWidth = 5.0;
  GlobalKey _drawingKey = GlobalKey();

  List<DrawnLine> _lines = [];
  DrawnLine? _currentLine;

  Color _textContainerColor = Colors.white;
  String? _selectedImagePath;

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
              child: _buildContent(),
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
                  setState(() {
                    _isDrawing = !_isDrawing;
                    if (!_isDrawing) {
                      _lines.add(DrawnLine(
                        points: [],
                        color: _selectedColor,
                        width: _selectedStrokeWidth,


                      )); // Finish the current line when turning off drawing
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () {
                  pickImageFromGallery();
                },
              ),
              IconButton(
                icon: Icon(Icons.text_fields),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.color_lens),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Select Background Color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: _textContainerColor,
                            onColorChanged: (color) {
                              setState(() {
                                _textContainerColor = color;
                              });
                            },
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TextToImagePage()),
            );
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.co_present, color: Colors.white),
          backgroundColor: Colors.blue,
          // label: 'Contact',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatGPTScreen()));
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

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: _textContainerColor,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: _isDrawing
                          ? CustomPaint(
                        painter: DrawingPainter(
                          _lines,
                        ),
                      )
                          : TextField(
                        controller: _textEditingController,
                        maxLines: null,
                        onChanged: (value) {
                          setState(() {
                            widget.page.content = value;
                          });
                        },
                        decoration: InputDecoration.collapsed(
                          hintText: 'Type your notes here...',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isDrawing) // Show buttons when drawing is active
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Padding between buttons
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ..._buildColorButtons(),
                    ..._buildStrokeButtons(),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _lines.clear();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () {
                        _saveDrawing();
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (_colorLensSelected) // Show color options popup when color_lens is selected
            Positioned(
              bottom: 50, // Adjust the position as needed
              left: 16,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: _buildColorOptions(),
                ),
              ),
            ),
          if (_selectedImagePath != null) // Display selected image
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.file(
                File(_selectedImagePath!),
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildColorButtons() {
    return [
      _buildColorButton(Colors.black),
      _buildColorButton(Colors.red),
      _buildColorButton(Colors.green),
      _buildColorButton(Colors.blue),
      _buildColorButton(Colors.yellow),
      //_buildColorButton(Colors.purple),
     // _buildColorButton(Colors.orange),
    ];
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _selectedColor == color
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }

  List<Widget> _buildStrokeButtons() {
    return [
      _buildStrokeButton(2.0),
      _buildStrokeButton(5.0),
      _buildStrokeButton(10.0),
    ];
  }

  Widget _buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        print("Stroke width tapped: $strokeWidth");
        setState(() {
          _selectedStrokeWidth = strokeWidth;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedStrokeWidth == strokeWidth
                ? Colors.black
                : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: strokeWidth,
            height: 5,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  bool _colorLensSelected = false; // To track whether the color lens button is selected

  List<Widget> _buildColorOptions() {
    return [
      _buildColorOption(Colors.red),
      _buildColorOption(Colors.green),
      _buildColorOption(Colors.blue),
      // Add more color options here
    ];
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textContainerColor = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final point = details.localPosition;
    setState(() {
      _currentLine = DrawnLine(
        points: [point],
        color: _selectedColor,
        width: _selectedStrokeWidth,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final point = details.localPosition;
    final List<Offset> path = List.from(_currentLine!.points)..add(point);
    setState(() {
      _currentLine = DrawnLine(
        points: path,
        color: _selectedColor,
        width: _selectedStrokeWidth,
      );
    });
  }


  void _onPanEnd(DragEndDetails details) {
    if (_currentLine != null) {
      setState(() {
        _lines.add(_currentLine!);
        _currentLine = null;
      });
    }
  }

  Future<void> _saveDrawing() async {
    print("Save button pressed");
    try {
      final boundary = _drawingKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      print("Capturing image...");
      final image = await boundary.toImage();
      print("Image captured");
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final saved = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 100,
          name: DateTime.now().toIso8601String() + ".png",
          isReturnImagePathOfIOS: true,
        );
        print(saved);

        setState(() {
          _drawingPaths.clear(); // Clear the drawing paths after saving
        });
      } else {
        print("ByteData is null.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _selectedImagePath = pickedImage.path; // Store the selected image path
        });
      } else {
        // User cancelled the image selection
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _savePage() {
    // Implement the auto-save functionality here
    // For example, you can save the content to the database or storage
    widget.page.content = _textEditingController.text;
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

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;

  DrawingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = line.width;

      final path = Path()..addPolygon(line.points, false);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
  });
}
