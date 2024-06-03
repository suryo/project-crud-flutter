import 'dart:convert'; // Add this import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class UploadProject extends StatefulWidget {
  @override
  _UploadProjectState createState() => _UploadProjectState();
}

class _UploadProjectState extends State<UploadProject> {
  final _formKey = GlobalKey<FormState>();
  final _projectController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _slugController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _statusController = TextEditingController(text: 'active'); // Set default value to 'active'
  File? _fileProject;

  quill.QuillController _descController = quill.QuillController.basic();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null) {
      setState(() {
        _fileProject = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> _uploadProject() async {
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('your endpoint'),
      );

      request.fields['project'] = _projectController.text;
      request.fields['author'] = _authorController.text;
      request.fields['price'] = _priceController.text;
      request.fields['slug'] = _slugController.text;
      request.fields['short_desc'] = _shortDescController.text;

 final jsondesc = jsonEncode(_descController.document.toDelta());

  // final converter = QuillDeltaToHtmlConverter(
  //      jsondesc.encodeHtml(),
  // );

      request.fields['desc'] = jsondesc;
      request.fields['status'] = _statusController.text;

      if (_fileProject != null) {
        final mimeTypeData = lookupMimeType(_fileProject!.path)!.split('/');
        request.files.add(
          http.MultipartFile(
            'file_project',
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
          SnackBar(content: Text('Project uploaded successfully. Status code: ${response.statusCode}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload project. Status code: ${response.statusCode}. ${responseData.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Project'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _projectController,
                decoration: InputDecoration(labelText: 'Project'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
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
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value != null && double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _slugController,
                decoration: InputDecoration(labelText: 'Slug'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a slug';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _shortDescController,
                decoration: InputDecoration(labelText: 'Short Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a short description';
                  }
                  return null;
                },
              ),
              quill.QuillToolbar.simple(
                configurations: quill.QuillSimpleToolbarConfigurations(
                  controller: _descController,
                  sharedConfigurations: const quill.QuillSharedConfigurations(
                    locale: Locale('en'), // Sesuaikan dengan kebutuhan Anda
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Tambahkan border
                  borderRadius: BorderRadius.circular(8.0), // Tambahkan radius border
                ),
                child: quill.QuillEditor.basic(
                  configurations: quill.QuillEditorConfigurations(
                    controller: _descController,
                    sharedConfigurations: const quill.QuillSharedConfigurations(
                      locale: Locale('en'), // Sesuaikan dengan kebutuhan Anda
                    ),
                  ),
                ),
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
                child: Text('Upload Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
