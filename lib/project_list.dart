import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'project.dart';

class ProjectList extends StatefulWidget {
  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  Future<List<Project>> _fetchProjects() async {
    final response = await http.get(Uri.parse('http://zonainformatika.com/api/testcrud'));
    if (response.statusCode == 200) {
      Iterable data = jsonDecode(response.body);
      return data.map((json) => Project.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load content');
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
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: snapshot.data![index].id,
                    );
                    if (result == true) {
                      setState(() {});
                    }
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _deleteProject(snapshot.data![index].id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Project deleted successfully')),
                      );
                      setState(() {});
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/upload');
          if (result == true) {
            setState(() {});
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
