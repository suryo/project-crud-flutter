import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'project.dart';

class ProjectDetail extends StatelessWidget {
  Future<Project> _fetchProjectDetail(int id) async {
    final response = await http.get(Uri.parse('http://zonainformatika.com/api/testcrud/$id'));
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load project detail');
    }
  }

  Future<void> _deleteProject(int id) async {
    final response = await http.delete(Uri.parse('http://zonainformatika.com/api/testcrud/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete project');
    }
  }

  @override
  Widget build(BuildContext context) {
    final int id = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: Text('Project Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/edit', arguments: id);
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _deleteProject(id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Project deleted successfully')),
              );
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: FutureBuilder<Project>(
        future: _fetchProjectDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Content: ${snapshot.data!.content}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Author: ${snapshot.data!.author}', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
