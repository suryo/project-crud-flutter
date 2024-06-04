import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'project.dart';

class EditProject extends StatefulWidget {
  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();

  Future<Project> _fetchProjectDetail(int id) async {
    final response = await http.get(Uri.parse('http://zonainformatika.com/api/testcrud/$id'));
    if (response.statusCode == 200) {
      return Project.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load project detail');
    }
  }

  Future<void> _updateProject(int id) async {
    if (_formKey.currentState!.validate()) {
      final response = await http.put(
        Uri.parse('http://zonainformatika.com/api/testcrud/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'content': _contentController.text,
          'author': _authorController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project updated successfully.')),
        );
        Navigator.pop(context);
      } else {
        print('else');
        print(response);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update project.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int id = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project'),
      ),
      body: FutureBuilder<Project>(
        future: _fetchProjectDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _contentController.text = snapshot.data!.content;
            _authorController.text = snapshot.data!.author;

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(labelText: 'Content'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a content name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _authorController,
                      decoration: InputDecoration(labelText: 'Author'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an author name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _updateProject(id),
                      child: Text('Update Project'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
