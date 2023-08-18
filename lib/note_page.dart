class NotePage {
  String name;
  String content;
  String? drawingContent; // Add this field
  bool isFavorite;

  NotePage({
    required this.name,
    required this.content,
    this.drawingContent, // Add this parameter
    this.isFavorite = false,
  });
}
