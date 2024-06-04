import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'project.dart';

class ProjectList extends StatelessWidget {
  Future<List<Project>> _fetchProjects() async {
    final response = await http.get(Uri.parse('http://zonainformatika.com/api/testcrud'));
    if (response.statusCode == 200) {
      Iterable data = jsonDecode(response.body);
      return data.map((json) => Project.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load content');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content Test CRUD'),
      ),
      body: FutureBuilder<List<Project>>(
        future: _fetchProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].content),
                  subtitle: Text(snapshot.data![index].author),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: snapshot.data![index].id,
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/upload');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
