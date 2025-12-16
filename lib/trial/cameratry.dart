import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(OcrApp());
}

class OcrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OcrHomePage(),
    );
  }
}

class OcrHomePage extends StatefulWidget {
  @override
  _OcrHomePageState createState() => _OcrHomePageState();
}

class _OcrHomePageState extends State<OcrHomePage> {
  File? _image;
  String _extractedText = "";
  String _retrievedData = "";
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _extractedText = "Processing...";
      });
      _processImage(File(pickedFile.path));
    }
  }

  Future<void> _processImage(File image) async {
    final inputImage = InputImage.fromFile(image);

    try {
      final RecognizedText recognizedText =
      await _textRecognizer.processImage(inputImage);
      setState(() {
        _extractedText = recognizedText.text;
      });
      _sendTextToBackend(_extractedText);
    } catch (e) {
      setState(() {
        _extractedText = "Failed to recognize text: $e";
      });
    }
  }

  Future<void> _sendTextToBackend(String text) async {
    final url = 'http://your-flask-backend-url/endpoint'; // Replace with your Flask backend URL
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _retrievedData = jsonDecode(response.body)['data']; // Adjust according to your backend response
      });
    } else {
      setState(() {
        _retrievedData = "Failed to retrieve data: ${response.statusCode}";
      });
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent.shade100,
        title: Text(
          "Camera",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.0,
            fontSize: 25.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_image != null)
              Image.file(
                _image!,
                height: 250,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 250,
                width: 200,
                color: Colors.grey[300],
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.grey[600],
                ),
              ),
            SizedBox(height: 20),
            Text(
              "Translated Text:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    )
                  ],
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _extractedText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Retrieved Data:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    )
                  ],
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _retrievedData,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    backgroundColor: Colors.lightBlueAccent.shade100,
                    shadowColor: Colors.black38,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt,
                        size: 24,
                        color: Colors.pinkAccent[100],
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Camera",
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    backgroundColor: Colors.lightBlueAccent.shade100,
                    shadowColor: Colors.black38,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.image,
                          size: 24,
                          color: Colors.pinkAccent[100]),
                      SizedBox(width: 8),
                      Text(
                        "Gallery",
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
