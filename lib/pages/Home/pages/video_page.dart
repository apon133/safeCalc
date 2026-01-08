import 'dart:io';
import 'package:better_player_enhanced/better_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> mediaFilePaths = [];

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  MediaPageState createState() => MediaPageState();
}

class MediaPageState extends State<MediaPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool isCameraInitialized = false;
  bool _isMobilePlatform = false;

  @override
  void initState() {
    super.initState();
    _loadMediaFilePaths();
    _isMobilePlatform = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (_isMobilePlatform) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        _initializeControllerFuture = _cameraController!.initialize();
        await _initializeControllerFuture;
        if (mounted) {
          setState(() {
            isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    if (_cameraController != null) {
      _cameraController!.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMediaFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mediaFilePaths = prefs.getStringList('mediaFilePaths') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showMediaSourceSelectionDialog,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Video'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MasonryGridView.count(
              itemCount: mediaFilePaths.length,
              crossAxisCount: 2,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onLongPress: () => _showDeleteConfirmationDialog(index),
                  onTap: () => _showMediaFullScreenPage(mediaFilePaths[index]),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.videocam, size: 100),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMediaSourceSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Media'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _captureMedia(ImageSource.gallery);
                  },
                  child: const Text('Pick from Gallery'),
                ),
                const SizedBox(height: 10),
                // if (_isMobilePlatform)
                //   GestureDetector(
                //     // onTap: () {
                //     //   Navigator.of(context).pop();
                //     //   _captureMedia(ImageSource.camera);
                //     // },
                //     child: const Text('Take Photo/Video'),
                //   ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _captureMedia(ImageSource source) async {
    final imagePicker = ImagePicker();
    try {
      final XFile? videoFile = await imagePicker.pickVideo(source: source);
      if (videoFile != null) {
        _addMediaFile(videoFile.path);
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }

  Future<void> _addMediaFile(String path) async {
    setState(() {
      mediaFilePaths.add(path);
    });
    await _saveMediaFilePaths();
  }

  Future<void> _showDeleteConfirmationDialog(int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Media?'),
          content: const Text('Are you sure you want to delete this media?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteMedia(index);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMedia(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mediaFilePaths.removeAt(index);
    });
    await prefs.setStringList('mediaFilePaths', mediaFilePaths);
  }

  Future<void> _showMediaFullScreenPage(String mediaPath) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MediaFullScreenPage(mediaPath: mediaPath),
    ));
  }

  Future<void> _saveMediaFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mediaFilePaths', mediaFilePaths);
  }
}

class MediaFullScreenPage extends StatefulWidget {
  final String mediaPath;
  const MediaFullScreenPage({super.key, required this.mediaPath});

  @override
  State<MediaFullScreenPage> createState() => _MediaFullScreenPageState();
}

class _MediaFullScreenPageState extends State<MediaFullScreenPage> {

  @override
  void initState() {
    super.initState();
  
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
      ),
      body: Center(
        child: _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return BetterPlayer.file(
        widget.mediaPath,
        betterPlayerConfiguration: BetterPlayerConfiguration(
          aspectRatio: _getVideoAspectRatio(widget.mediaPath),
          fit: BoxFit.contain,
          autoPlay: true,
          looping: true,
        ),
      );
    }
  }

  double _getVideoAspectRatio(String mediaPath) {
    if (mediaPath.contains('portrait')) {
      return 9 / 16;
    }
    return 16 / 9;
  }

