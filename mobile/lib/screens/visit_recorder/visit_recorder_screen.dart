import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import '../../services/audio_recorder_service.dart';
import '../../widgets/common/loading_button.dart';
import '../ai_advisor/ai_advisor_screen.dart';
import '../observation_card/observation_card_selection_screen.dart';

class VisitRecorderScreen extends StatefulWidget {
  final String? mode;
  final String? title;
  
  const VisitRecorderScreen({super.key, this.mode, this.title});

  @override
  State<VisitRecorderScreen> createState() => _VisitRecorderScreenState();
}

class _VisitRecorderScreenState extends State<VisitRecorderScreen> {
  final AudioRecorderService _recorder = AudioRecorderService();
  final TextEditingController _notesController = TextEditingController();
  
  // Audio recording state
  bool _isRecording = false;
  bool _isUploading = false;
  bool _isAnalyzing = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  double _currentVolume = 0.0;
  List<String> _conversationSegments = [];
  
  // Camera state
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  List<String> _capturedPhotos = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _requestPermissions();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _notesController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.camera.request();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final imagePath = '${directory.path}/photo_$timestamp.jpg';
      
      final XFile photo = await _cameraController!.takePicture();
      await photo.saveTo(imagePath);
      
      setState(() {
        _capturedPhotos.add(imagePath);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo captured!')),
        );
      }
    } catch (e) {
      debugPrint('Photo capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
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
      
      await _recorder.startRecording();
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      
      // Update duration and volume every second
      _recorder.onDurationChanged = (duration) {
        setState(() => _recordingDuration = duration);
      };
      
      // Simulate volume changes (replace with actual volume monitoring from audio recorder)
      _startVolumeMonitoring();
    }
  }

  Future<void> _uploadRecording() async {
    if (_recordingPath == null) return;
    
    setState(() => _isUploading = true);
    
    try {
      // Simulate AI analysis first
      setState(() => _isAnalyzing = true);
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate conversation analysis
      _conversationSegments = [
        'Pale leaf color is not a disease but wind sunburn',
        'These spots are natural patterns called "variegation"',
        'The trick is to check soil moisture by hand'
      ];
      
      setState(() => _isAnalyzing = false);
      
      // Upload logic would go here
      await Future.delayed(const Duration(seconds: 1)); 
      
      if (mounted) {
        final isVeteranMode = widget.mode == 'veteran';
        
        if (isVeteranMode) {
          // ベテランモードの場合、観察カード選択画面に遷移
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording and photography completed! Generating observation cards'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
          
          // 1秒後に観察カード選択画面に遷移
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ObservationCardSelectionScreen(
                    capturedPhotos: _capturedPhotos,
                    conversationSegments: _conversationSegments,
                  ),
                ),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Observation saved!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
        _isAnalyzing = false;
      });
    }
  }

  void _startVolumeMonitoring() {
    // Simulate volume changes - in real implementation, get this from AudioRecorderService
    Future.doWhile(() async {
      if (!_isRecording) return false;
      
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _isRecording) {
        setState(() {
          _currentVolume = (0.1 + (0.9 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000));
        });
      }
      return _isRecording;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isVeteranMode = widget.mode == 'veteran';
    final title = widget.title ?? (isVeteranMode ? 'Learn from Veteran Farmer' : 'Record Field Visit');
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white,
        actions: [
          if (isVeteranMode)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text('Learning Mode', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview (takes most of the screen)
            Positioned.fill(
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Initializing Camera...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            
            // Top overlay with recording status
            if (_isRecording || _isAnalyzing)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isAnalyzing 
                        ? Colors.blue.withOpacity(0.9)
                        : Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isAnalyzing) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AI Analyzing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Recording Conversation ${_formatDuration(_recordingDuration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            
            // Photo count indicator
            if (_capturedPhotos.isNotEmpty)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_capturedPhotos.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Bottom controls area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Volume indicator bars (behind buttons)
                    if (_isRecording)
                      Positioned(
                        bottom: 60,
                        left: 20,
                        right: 20,
                        child: _buildVolumeIndicator(),
                      ),
                    
                    // Control buttons
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Photo capture button
                          GestureDetector(
                            onTap: _capturePhoto,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          
                          // Audio recording button (larger, center)
                          GestureDetector(
                            onTap: _toggleRecording,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _isRecording ? Colors.red : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isRecording ? Colors.white : Colors.red,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: _isRecording ? Colors.white : Colors.red,
                                size: 36,
                              ),
                            ),
                          ),
                          
                          // Notes/Upload button
                          GestureDetector(
                            onTap: _showNotesDialog,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                _recordingPath != null || _capturedPhotos.isNotEmpty
                                    ? Icons.upload
                                    : Icons.note_add,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeIndicator() {
    const int barCount = 20;
    const double maxHeight = 30;
    final int activeBars = (_currentVolume * barCount).round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(barCount, (index) {
        final bool isActive = index < activeBars;
        final double barHeight = isActive 
            ? (maxHeight * (0.3 + 0.7 * (index + 1) / barCount))
            : maxHeight * 0.2;
        
        return Container(
          width: 3,
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive 
                ? (index < barCount * 0.7 ? Colors.green : Colors.orange)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }

  void _showNotesDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Field Visit Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Recording status
            if (_recordingPath != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('Conversation recorded (${_formatDuration(_recordingDuration)})'),
                  ],
                ),
              ),
              
            // Conversation segments (if analyzed)
            if (_conversationSegments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Important knowledge extracted by AI:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._conversationSegments.map((segment) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.blue)),
                          Expanded(child: Text(segment)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
            
            if (_capturedPhotos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_camera, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('${_capturedPhotos.length} photos captured'),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Field Notes',
                hintText: 'Add any observations or comments...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const Spacer(),
            LoadingButton(
              onPressed: (_recordingPath != null || _capturedPhotos.isNotEmpty) 
                  ? _uploadRecording 
                  : null,
              isLoading: _isUploading || _isAnalyzing,
              child: Text(_isAnalyzing 
                ? 'AI Analyzing...' 
                : 'Save Observation'),
            ),
          ],
        ),
      ),
    );
  }
}