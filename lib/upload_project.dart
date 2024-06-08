import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class UploadProject extends StatefulWidget {
  @override
  _UploadProjectState createState() => _UploadProjectState();
}

class _UploadProjectState extends State<UploadProject> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  File? _fileProject;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null) {
      setState(() {
        _fileProject = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadProject() async {
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://zonainformatika.com/api/testcrud'),
      );

      request.fields['content'] = _contentController.text;
      request.fields['author'] = _authorController.text;

      if (_fileProject != null) {
        final mimeTypeData = lookupMimeType(_fileProject!.path)!.split('/');
        request.files.add(
          http.MultipartFile(
            'file_content',
            _fileProject!.readAsBytes().asStream(),
            _fileProject!.lengthSync(),
            filename: path.basename(_fileProject!.path),
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          ),
        );
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Content uploaded successfully. Status code: ${response.statusCode}')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload content. Status code: ${response.statusCode}. ${responseData.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test CRUD'),
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
                onPressed: _pickFile,
                child: Text('Pick ZIP File'),
              ),
              SizedBox(height: 20),
              _fileProject == null
                  ? Text('No file selected.')
                  : Text('File: ${path.basename(_fileProject!.path)}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadProject,
                child: Text('Upload Content'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
