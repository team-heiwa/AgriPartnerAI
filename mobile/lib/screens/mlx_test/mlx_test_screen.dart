import 'package:flutter/material.dart';
import 'package:agripartner_mobile/services/gemma_mlx_native_service.dart';

class MLXTestScreen extends StatefulWidget {
  const MLXTestScreen({super.key});

  @override
  State<MLXTestScreen> createState() => _MLXTestScreenState();
}

class _MLXTestScreenState extends State<MLXTestScreen> {
  final GemmaMLXNativeService _mlxService = GemmaMLXNativeService();
  final TextEditingController _promptController = TextEditingController();
  
  bool _isLoading = false;
  bool _isModelLoaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _output = '';
  Map<String, dynamic>? _modelInfo;
  
  @override
  void initState() {
    super.initState();
    _checkModelStatus();
    _setupDownloadListener();
  }
  
  void _setupDownloadListener() {
    _mlxService.downloadProgressStream.listen((progress) {
      setState(() {
        _downloadProgress = progress;
      });
    });
  }
  
  Future<void> _checkModelStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get model info
      final info = await _mlxService.getModelInfo();
      setState(() {
        _modelInfo = info;
      });
      
      // Check if model exists
      final exists = await _mlxService.checkModelExists();
      
      if (exists) {
        // Try to load model
        final loaded = await _mlxService.loadModel();
        setState(() {
          _isModelLoaded = loaded;
          _output = loaded 
            ? '✅ Model loaded successfully! Ready for offline inference.'
            : '❌ Model exists but failed to load.';
        });
      } else {
        setState(() {
          _output = '📦 Model not found locally. Tap "Download Model" to get it.';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Error checking model: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _output = 'Downloading model from Hugging Face...';
    });
    
    try {
      final success = await _mlxService.downloadModel();
      
      if (success) {
        setState(() {
          _output = '✅ Model downloaded successfully!';
        });
        
        // Load the model after download
        await _loadModel();
      } else {
        setState(() {
          _output = '❌ Failed to download model';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Download error: $e';
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }
  
  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _output = 'Loading model...';
    });
    
    try {
      final success = await _mlxService.loadModel();
      
      setState(() {
        _isModelLoaded = success;
        _output = success 
          ? '✅ Model loaded! Ready for offline inference.'
          : '❌ Failed to load model';
      });
    } catch (e) {
      setState(() {
        _output = 'Load error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _generateText() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      setState(() {
        _output = 'Please enter a prompt';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _output = 'Generating...';
    });
    
    try {
      final result = await _mlxService.generateText(
        prompt: prompt,
        maxTokens: 200,
        temperature: 0.7,
      );
      
      setState(() {
        _output = result ?? 'No response generated';
      });
    } catch (e) {
      setState(() {
        _output = 'Generation error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _testAgriculture() async {
    setState(() {
      _isLoading = true;
      _output = 'Analyzing agricultural scenario...';
    });
    
    try {
      final result = await _mlxService.analyzeAgriculture(
        description: 'Rice plants showing yellow leaves in the lower portions. '
            'The field has been recently irrigated and fertilized with nitrogen.',
        task: 'diagnose',
      );
      
      setState(() {
        _output = result ?? 'No analysis generated';
      });
    } catch (e) {
      setState(() {
        _output = 'Analysis error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MLX On-Device Test'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isModelLoaded ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isModelLoaded ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isModelLoaded ? Icons.check_circle : Icons.info,
                        color: _isModelLoaded ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isModelLoaded ? 'Model Ready' : 'Model Not Loaded',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_modelInfo != null) ...[
                    const SizedBox(height: 8),
                    Text('Path: ${_modelInfo!['modelPath'] ?? 'Unknown'}'),
                    Text('Exists: ${_modelInfo!['exists'] ?? false}'),
                    Text('Config: ${_modelInfo!['configuration'] ?? 'Not loaded'}'),
                  ],
                ],
              ),
            ),
            
            // Download Progress
            if (_isDownloading) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: _downloadProgress),
                    const SizedBox(height: 8),
                    Text('Downloading: ${(_downloadProgress * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading || _isDownloading ? null : _checkModelStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Status'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading || _isDownloading || _isModelLoaded ? null : _downloadModel,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Model'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading || !_isModelLoaded ? null : _testAgriculture,
                    icon: const Icon(Icons.agriculture),
                    label: const Text('Test Agriculture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            
            // Input Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _promptController,
                decoration: InputDecoration(
                  labelText: 'Enter prompt',
                  hintText: 'Ask about farming...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: _isLoading || !_isModelLoaded ? null : _generateText,
                    icon: const Icon(Icons.send),
                  ),
                ),
                maxLines: 3,
                enabled: !_isLoading && _isModelLoaded,
              ),
            ),
            
            // Output Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Output:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Text(
                          _output,
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}