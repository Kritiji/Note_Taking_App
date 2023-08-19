import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'folder_details_page.dart';
import 'page_details_page.dart';
import 'splash_page.dart';
import 'note_home_page.dart';
import 'note_page.dart';
import 'login_page.dart';
//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(NoteTakingApp());
}

class NoteTakingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashPage(),
        '/': (context) => NoteHomePage(), // Change this to LoginPage
        '/noteHome': (context) => NoteHomePage(),
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
