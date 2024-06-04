import 'package:flutter/material.dart';
import 'upload_project.dart';
import 'project_list.dart';
import 'project_detail.dart';
import 'edit_project.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Uploader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ProjectList(),
        '/upload': (context) => UploadProject(),
        '/detail': (context) => ProjectDetail(),
        '/edit': (context) => EditProject(),
      },
    );
  }
}
