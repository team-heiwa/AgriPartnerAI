import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;
  Timer? _timer;
  DateTime? _startTime;
  Function(Duration)? onDurationChanged;
  Function(double)? onAmplitudeChanged;
  Function(Duration)? onPlaybackPositionChanged;
  String? _currentRecordingPath;
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  
  Future<void> init() async {
    if (!_isRecorderInitialized) {
      await _recorder.openRecorder();
      _isRecorderInitialized = true;
    }
    if (!_isPlayerInitialized) {
      await _player.openPlayer();
      _isPlayerInitialized = true;
    }
  }
  
  Future<String> getRecordingsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(path.join(appDir.path, 'AgriPartner', 'Recordings'));
    
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    
    return recordingsDir.path;
  }
  
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return true;
  }
  
  bool isRecording() {
    return _recorder.isRecording;
  }
  
  Future<void> startRecording() async {
    try {
      // Initialize if needed
      await init();
      
      // Check permission
      if (!await checkPermission()) {
        throw Exception('Microphone permission denied');
      }
      
      // Check if already recording
      if (_recorder.isRecording) {
        return;
      }
      
      // Get path for recording
      final recordingsDir = await getRecordingsDirectory();
      final timestamp = DateTime.now();
      final filename = 'recording_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}.aac';
      _currentRecordingPath = path.join(recordingsDir, filename);
      
      // Start recording
      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
      );
      
      _startTime = DateTime.now();
      
      // Subscribe to recorder events for amplitude
      _recorderSubscription = _recorder.onProgress!.listen((event) {
        if (onAmplitudeChanged != null && event.decibels != null) {
          // Convert decibels to 0-1 range for visualization
          final normalizedAmplitude = (event.decibels! + 60) / 60;
          onAmplitudeChanged!(normalizedAmplitude);
        }
      });
      
      // Start duration timer
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_startTime != null && onDurationChanged != null) {
          final duration = DateTime.now().difference(_startTime!);
          onDurationChanged!(duration);
        }
      });
    } catch (e) {
      print('Error starting recording: $e');
      rethrow;
    }
  }
  
  Future<String?> stopRecording() async {
    try {
      if (!_recorder.isRecording) {
        return null;
      }
      
      await _recorder.stopRecorder();
      
      _recorderSubscription?.cancel();
      _recorderSubscription = null;
      _timer?.cancel();
      _timer = null;
      _startTime = null;
      
      return _currentRecordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }
  
  Future<void> pauseRecording() async {
    if (_recorder.isRecording) {
      await _recorder.pauseRecorder();
    }
  }
  
  Future<void> resumeRecording() async {
    if (_recorder.isPaused) {
      await _recorder.resumeRecorder();
    }
  }
  
  // Playback methods
  Future<void> startPlayback(String filePath) async {
    try {
      await init();
      
      if (_player.isPlaying) {
        await _player.stopPlayer();
      }
      
      // Subscribe to player events
      _playerSubscription = _player.onProgress!.listen((event) {
        if (onPlaybackPositionChanged != null) {
          onPlaybackPositionChanged!(event.position);
        }
      });
      
      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          _playerSubscription?.cancel();
          _playerSubscription = null;
          if (onPlaybackPositionChanged != null) {
            onPlaybackPositionChanged!(Duration.zero);
          }
        },
      );
    } catch (e) {
      print('Error starting playback: $e');
      rethrow;
    }
  }
  
  Future<void> stopPlayback() async {
    try {
      if (_player.isPlaying) {
        await _player.stopPlayer();
      }
      _playerSubscription?.cancel();
      _playerSubscription = null;
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }
  
  Future<void> pausePlayback() async {
    if (_player.isPlaying) {
      await _player.pausePlayer();
    }
  }
  
  Future<void> resumePlayback() async {
    if (_player.isPaused) {
      await _player.resumePlayer();
    }
  }
  
  bool isPlaying() {
    return _player.isPlaying;
  }
  
  Future<Duration?> getRecordingDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // For now, return null as getting duration requires additional parsing
        // In production, you might want to use a package like just_audio to get duration
        return null;
      }
    } catch (e) {
      print('Error getting duration: $e');
    }
    return null;
  }
  
  Future<void> dispose() async {
    _recorderSubscription?.cancel();
    _playerSubscription?.cancel();
    _timer?.cancel();
    
    if (_isRecorderInitialized) {
      await _recorder.closeRecorder();
      _isRecorderInitialized = false;
    }
    
    if (_isPlayerInitialized) {
      await _player.closePlayer();
      _isPlayerInitialized = false;
    }
  }
}