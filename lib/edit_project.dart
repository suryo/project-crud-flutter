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
  int? _projectId;

  Future<void> _fetchProjectDetail(int id) async {
    final response = await http.get(Uri.parse('http://zonainformatika.com/api/testcrud/$id'));
    if (response.statusCode == 200) {
      var project = Project.fromJson(jsonDecode(response.body));
      _contentController.text = project.content;
      _authorController.text = project.author;
      _projectId = project.id;
    } else {
      throw Exception('Failed to load project detail');
    }
  }

  Future<void> _editProject() async {
    if (_formKey.currentState!.validate()) {
      var response = await http.put(
        Uri.parse('http://zonainformatika.com/api/testcrud/$_projectId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': _contentController.text,
          'author': _authorController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Content edited successfully. Status code: ${response.statusCode}')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit content. Status code: ${response.statusCode}. ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int id = ModalRoute.of(context)!.settings.arguments as int;
    _fetchProjectDetail(id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project'),
      ),
      body: Padding(
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
                onPressed: _editProject,
                child: Text('Edit Content'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
