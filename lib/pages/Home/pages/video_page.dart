import 'dart:io';
import 'package:better_player_enhanced/better_player.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

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
  final Map<String, String?> _thumbnailCache = {};

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
    // Generate thumbnails for all videos
    for (String path in mediaFilePaths) {
      _generateThumbnail(path);
    }
  }

  Future<void> _generateThumbnail(String videoPath) async {
    if (_thumbnailCache.containsKey(videoPath)) return;

    try {
      final thumbnailPath = await vt.VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: vt.ImageFormat.PNG,
        maxHeight: 200,
        quality: 75,
      );

      if (mounted) {
        setState(() {
          _thumbnailCache[videoPath] = thumbnailPath;
        });
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
      setState(() {
        _thumbnailCache[videoPath] = null;
      });
    }
  }

  Widget _buildThumbnail(String videoPath) {
    final thumbnailPath = _thumbnailCache[videoPath];

    if (thumbnailPath == null) {
      // Loading or error state
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Image.file(
      File(thumbnailPath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: const Icon(
            Icons.videocam,
            size: 60,
            color: Colors.white54,
          ),
        );
      },
    );
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
                  onLongPress: () => _showMediaOptionsDialog(index),
                  onTap: () => _showMediaFullScreenPage(mediaFilePaths[index]),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildThumbnail(mediaFilePaths[index]),
                            // Play icon overlay
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
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
    // Generate thumbnail for the newly added video
    _generateThumbnail(path);
  }

  Future<void> _showMediaOptionsDialog(int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Media Options'),
          content: const Text('What would you like to do with this video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _unlockMedia(index);
              },
              child: const Text('Unlock to Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(index);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Video?'),
          content: const Text(
              'Are you sure you want to delete this video? This action cannot be undone.'),
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

  Future<void> _unlockMedia(int index) async {
    try {
      final videoPath = mediaFilePaths[index];
      final videoFile = File(videoPath);

      if (!await videoFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Video file not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Save to gallery using Gal
      await Gal.putVideo(videoPath);

      // Remove from app storage
      _deleteMedia(index);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Video unlocked and saved to gallery'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error unlocking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
