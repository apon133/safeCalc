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

  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

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

  void _hideSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: _showMediaSourceSelectionDialog,
              child: const Icon(Icons.add),
            ),
      appBar: AppBar(
        title: Text(
            _isSelectionMode ? '${_selectedIndices.length} Selected' : 'Video'),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _hideSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: _selectedIndices.isEmpty
                  ? null
                  : () => _unlockSelectedMedia(),
              tooltip: 'Unlock Selected',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _selectedIndices.isEmpty
                  ? null
                  : () => _showMultiDeleteConfirmationDialog(),
              tooltip: 'Delete Selected',
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
              tooltip: 'Selection Mode',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MasonryGridView.count(
              itemCount: mediaFilePaths.length,
              crossAxisCount: 2,
              itemBuilder: (BuildContext context, int index) {
                final isSelected = _selectedIndices.contains(index);
                return GestureDetector(
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      setState(() {
                        _isSelectionMode = true;
                        _selectedIndices.add(index);
                      });
                    }
                  },
                  onTap: () {
                    if (_isSelectionMode) {
                      setState(() {
                        if (isSelected) {
                          _selectedIndices.remove(index);
                          if (_selectedIndices.isEmpty) {
                            _isSelectionMode = false;
                          }
                        } else {
                          _selectedIndices.add(index);
                        }
                      });
                    } else {
                      _showMediaFullScreenPage(index);
                    }
                  },
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
                                decoration: const BoxDecoration(
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
                            if (_isSelectionMode)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color:
                                      isSelected ? Colors.blue : Colors.white70,
                                ),
                              ),
                            if (_isSelectionMode && isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Pick from Gallery'),
                  ),
                ),
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
      // Use pickMultipleMedia to allow selecting multiple videos/images
      final List<XFile> mediaFiles = await imagePicker.pickMultipleMedia();
      if (mediaFiles.isNotEmpty) {
        for (var file in mediaFiles) {
          // Check if it's a video based on extension (optional but safer)
          _addMediaFile(file.path);
        }
      }
    } catch (e) {
      print('Error picking media: $e');
      // Fallback if pickMultipleMedia is not supported
      try {
        final XFile? videoFile = await imagePicker.pickVideo(source: source);
        if (videoFile != null) {
          _addMediaFile(videoFile.path);
        }
      } catch (e2) {
        print('Error picking video fallback: $e2');
      }
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

  Future<void> _showMultiDeleteConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${_selectedIndices.length} Videos?'),
          content: const Text(
              'Are you sure you want to delete the selected videos? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedMedia();
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _unlockSelectedMedia() async {
    int count = 0;
    List<int> sortedIndices = _selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Unlocking videos...'), duration: Duration(seconds: 1)),
    );

    for (int index in sortedIndices) {
      try {
        final videoPath = mediaFilePaths[index];
        await Gal.putVideo(videoPath);
        count++;
      } catch (e) {
        print('Error unlocking video at index $index: $e');
      }
    }

    _deleteSelectedMedia();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ $count videos unlocked and saved to gallery'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteSelectedMedia() async {
    final prefs = await SharedPreferences.getInstance();
    List<int> sortedIndices = _selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));

    setState(() {
      for (int index in sortedIndices) {
        mediaFilePaths.removeAt(index);
      }
      _isSelectionMode = false;
      _selectedIndices.clear();
    });

    await prefs.setStringList('mediaFilePaths', mediaFilePaths);
  }

  Future<void> _showMediaFullScreenPage(int initialIndex) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MediaFullScreenPage(
        initialIndex: initialIndex,
        mediaPaths: mediaFilePaths,
      ),
    ));
  }

  Future<void> _saveMediaFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mediaFilePaths', mediaFilePaths);
  }
}

class MediaFullScreenPage extends StatefulWidget {
  final int initialIndex;
  final List<String> mediaPaths;
  const MediaFullScreenPage(
      {super.key, required this.initialIndex, required this.mediaPaths});

  @override
  State<MediaFullScreenPage> createState() => _MediaFullScreenPageState();
}

class _MediaFullScreenPageState extends State<MediaFullScreenPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.mediaPaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaPaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return VideoPlayerItem(mediaPath: widget.mediaPaths[index]);
        },
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String mediaPath;
  const VideoPlayerItem({super.key, required this.mediaPath});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: _getVideoAspectRatio(widget.mediaPath),
      fit: BoxFit.contain,
      autoPlay: true,
      looping: true,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.mediaPath,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BetterPlayer(controller: _betterPlayerController),
    );
  }

  double _getVideoAspectRatio(String mediaPath) {
    if (mediaPath.contains('portrait')) {
      return 9 / 16;
    }
    return 16 / 9;
  }
}
