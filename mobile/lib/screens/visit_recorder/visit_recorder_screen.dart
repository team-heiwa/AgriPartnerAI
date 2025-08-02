import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../services/audio_recorder_service.dart';
import '../../widgets/common/loading_button.dart';

class VisitRecorderScreen extends StatefulWidget {
  const VisitRecorderScreen({super.key});

  @override
  State<VisitRecorderScreen> createState() => _VisitRecorderScreenState();
}

class _VisitRecorderScreenState extends State<VisitRecorderScreen> {
  final AudioRecorderService _recorder = AudioRecorderService();
  final TextEditingController _notesController = TextEditingController();
  bool _isRecording = false;
  bool _isUploading = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stopRecording();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });
    } else {
      String filePath;
      if (kIsWeb) {
        // For web, we'll use a different approach or show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording is not supported on web. Please use mobile app.')),
        );
        return;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        filePath = '${directory.path}/recording_$timestamp.m4a';
      }
      
      await _recorder.startRecording(filePath);
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      
      // Update duration every second
      _recorder.onDurationChanged = (duration) {
        setState(() => _recordingDuration = duration);
      };
    }
  }

  Future<void> _uploadRecording() async {
    if (_recordingPath == null) return;
    
    setState(() => _isUploading = true);
    
    try {
      // Upload logic would go here
      await Future.delayed(const Duration(seconds: 2)); // Simulated upload
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Field Visit'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: _isRecording 
                      ? Colors.red.withOpacity(0.1) 
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isRecording ? Colors.red : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRecording ? Icons.mic : Icons.mic_none,
                      size: 64,
                      color: _isRecording ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRecording 
                          ? 'Recording... ${_formatDuration(_recordingDuration)}' 
                          : (_recordingPath != null 
                              ? 'Recording saved' 
                              : 'Tap to start recording'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _toggleRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _notesController,
                maxLines: 3, // Reduced from 5 to 3
                minLines: 1, // Added minLines for better control
                decoration: const InputDecoration(
                  labelText: 'Field Notes',
                  hintText: 'Add any observations or comments...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24), // Added spacing instead of Spacer
              LoadingButton(
                onPressed: _recordingPath != null ? _uploadRecording : null,
                isLoading: _isUploading,
                child: const Text('Save & Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}