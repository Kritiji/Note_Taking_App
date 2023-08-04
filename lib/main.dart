import 'package:flutter/material.dart';
import 'folder_details_page.dart';
import 'page_details_page.dart';
import 'splash_page.dart';
import 'note_home_page.dart';
import 'note_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(NoteTakingApp());
}

class NoteTakingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/splash': (context) => SplashPage(),
        '/': (context) => NoteHomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/folderDetails') {
          return MaterialPageRoute(
            builder: (context) => FolderDetailsPage(folder: Folder(name: 'Your Folder Name')),
          );
        } else if (settings.name == '/pageDetails') {
          final page = settings.arguments as NotePage;
          return MaterialPageRoute(
            builder: (context) => PageDetailsPage(page: page),
          );
        }
        return null;
      },
    );
  }
}
