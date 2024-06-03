import 'package:flutter/material.dart';
import 'upload_project.dart';
import 'project_list.dart';

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
        '/': (context) => ProjectList(), // Halaman utama menampilkan daftar proyek
        '/upload': (context) => UploadProject(), // Halaman unggah proyek
      },
    );
  }
}
