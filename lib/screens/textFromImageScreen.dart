import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageToTextApp extends StatefulWidget {
  const ImageToTextApp({super.key});

  @override
  _ImageToTextAppState createState() => _ImageToTextAppState();
}

class _ImageToTextAppState extends State<ImageToTextApp> {
  File? _image;
  String _extractedText = "";
  final ImagePicker _picker = ImagePicker();

  // Pick Image
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Send Image to Flask Backend
  Future<void> _extractText() async {
    if (_image == null) return;

    final request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:5000/extract-text'));
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body); // Parse JSON response
      setState(() {
        _extractedText = responseData['text']; // Extract text field
      });
    } else {
      setState(() {
        _extractedText = "Error: ${response.body}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blue.shade300,
      appBar: AppBar(
        title: const Text("Image to Text Converter"),
        backgroundColor: Colors.blue.shade500,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade500, Colors.black12],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Flexible(child: Image.file(_image!))
                  : const Text("No image selected."),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Pick Image"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _extractText,
                child: const Text("Extract Text"),
              ),
              Flexible(
                child: Text(
                  _extractedText,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
