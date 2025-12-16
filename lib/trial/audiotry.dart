import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AudioRecordingPage(),
    );
  }
}

class AudioRecordingPage extends StatefulWidget {
  @override
  _AudioRecordingPageState createState() => _AudioRecordingPageState();
}

class _AudioRecordingPageState extends State<AudioRecordingPage> {
  bool _isRecording = false;
  String? _originalAudioPath;
  String? _translatedAudioPath;
  final String _backendUrl = 'http://your-backend-url/audio'; // Replace with your Flask server URL
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Record _recorder;

  @override
  void initState() {
    super.initState();
    _recorder = Record();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder and Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 64,
                color: _isRecording ? Colors.red : Colors.green,
              ),
              onPressed: _toggleRecording,
            ),
            if (_translatedAudioPath != null) ...[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _playTranslatedAudio,
                child: Text('Start playing translated recording'),
              ),
              ElevatedButton(
                onPressed: _playOriginalAudio,
                child: Text('Play original recording'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      String? path = await _recorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _originalAudioPath = path;
        });
        await _sendAudioToBackend(File(_originalAudioPath!));
      }
    } else {
      if (await Permission.microphone.request().isGranted) {
        Directory directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/recording.m4a';
        if (await _recorder.hasPermission()) {
          await _recorder.start(
            path: filePath,
            encoder: AudioEncoder.aacLc, // Correct encoder
            bitRate: 128000, // You can choose the bit rate
            samplingRate: 44100, // You can choose the sampling rate
          );
          setState(() {
            _isRecording = true;
          });
        }
      }
    }
  }

  Future<void> _sendAudioToBackend(File audioFile) async {
    final request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
    request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      Directory tempDir = await getTemporaryDirectory();
      String translatedFilePath = '${tempDir.path}/translated_audio.mp3';
      File file = File(translatedFilePath);
      await response.stream.pipe(file.openWrite());
      setState(() {
        _translatedAudioPath = translatedFilePath;
      });
    } else {
      print('Failed to send audio to backend');
    }
  }

  Future<void> _playTranslatedAudio() async {
    if (_translatedAudioPath != null) {
      await _audioPlayer.setSourceDeviceFile(_translatedAudioPath!);
      await _audioPlayer.resume();
    }
  }

  Future<void> _playOriginalAudio() async {
    if (_originalAudioPath != null) {
      await _audioPlayer.setSourceDeviceFile(_originalAudioPath!);
      await _audioPlayer.resume();
    }
  }
}
