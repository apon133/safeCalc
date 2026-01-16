import 'dart:io';
import 'package:better_player_enhanced/better_player.dart';
import 'package:calculetor/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class MediaPage extends ConsumerStatefulWidget {
  const MediaPage({super.key});

  @override
  ConsumerState<MediaPage> createState() => MediaPageState();
}

class MediaPageState extends ConsumerState<MediaPage> {
  final Map<String, String?> _thumbnailCache = {};
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _pregenerateThumbnails();
  }

  void _pregenerateThumbnails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final videos = ref.read(videoGalleryProvider);
      for (String path in videos) {
        _generateThumbnail(path);
      }
    });
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
      debugPrint('Error generating thumbnail: $e');
      if (mounted) {
        setState(() {
          _thumbnailCache[videoPath] = null;
        });
      }
    }
  }

  void _hideSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videos = ref.watch(videoGalleryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFFFF7043),
              onPressed: _showMediaSourceSelectionDialog,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          _isSelectionMode ? '${_selectedIndices.length} Selected' : 'Videos',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _hideSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.file_download_outlined,
                  color: Color(0xFFFF7043)),
              onPressed: _selectedIndices.isEmpty
                  ? null
                  : () => _unlockSelectedMedia(videos),
              tooltip: 'Unlock Selected',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _selectedIndices.isEmpty
                  ? null
                  : () => _showMultiDeleteConfirmationDialog(),
              tooltip: 'Delete Selected',
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.white70),
              onPressed: () => setState(() => _isSelectionMode = true),
              tooltip: 'Selection Mode',
            ),
        ],
      ),
      body: videos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_outlined,
                      size: 80, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'No Protected Videos',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 16),
                  ),
                ],
              ),
            )
          : MasonryGridView.count(
              padding: const EdgeInsets.all(12),
              itemCount: videos.length,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                final isSelected = _selectedIndices.contains(index);
                final videoPath = videos[index];
                _generateThumbnail(videoPath);

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
                          if (_selectedIndices.isEmpty)
                            _isSelectionMode = false;
                        } else {
                          _selectedIndices.add(index);
                        }
                      });
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MediaFullScreenPage(
                          initialIndex: index,
                          mediaPaths: videos,
                        ),
                      ));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF7043)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: _buildThumbnail(videoPath),
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                          if (_isSelectionMode)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? const Color(0xFFFF7043)
                                    : Colors.white70,
                              ),
                            ),
                          if (_isSelectionMode && isSelected)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFFF7043).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildThumbnail(String videoPath) {
    if (!_thumbnailCache.containsKey(videoPath)) {
      return Container(color: Colors.grey[900]);
    }

    final thumbnailPath = _thumbnailCache[videoPath];
    if (thumbnailPath == null) {
      return Container(
        color: Colors.grey[900],
        child: const Icon(Icons.videocam_off_outlined, color: Colors.white24),
      );
    }

    return Image.file(File(thumbnailPath), fit: BoxFit.cover);
  }

  Future<void> _showMediaSourceSelectionDialog() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.video_library_outlined,
                    color: Color(0xFFFF7043)),
                title: const Text('Pick from Gallery',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _captureMedia();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureMedia() async {
    final imagePicker = ImagePicker();
    try {
      final List<XFile> mediaFiles = await imagePicker.pickMultipleMedia();
      if (mediaFiles.isNotEmpty) {
        final paths = mediaFiles.map((f) => f.path).toList();
        await ref.read(videoGalleryProvider.notifier).addVideos(paths);
        for (var path in paths) {
          _generateThumbnail(path);
        }
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
    }
  }

  Future<void> _showMultiDeleteConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text('Delete ${_selectedIndices.length} Videos?',
              style: const TextStyle(color: Colors.white)),
          content: const Text(
              'Move selected videos out of the vault? This cannot be undone.',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(videoGalleryProvider.notifier)
                    .removeVideos(_selectedIndices);
                _hideSelectionMode();
                Navigator.of(context).pop();
              },
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _unlockSelectedMedia(List<String> currentVideos) async {
    int count = 0;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Unlocking videos...'),
          duration: Duration(milliseconds: 500)),
    );

    for (int index in _selectedIndices) {
      try {
        await Gal.putVideo(currentVideos[index]);
        count++;
      } catch (e) {
        debugPrint('Error unlocking video: $e');
      }
    }

    await ref
        .read(videoGalleryProvider.notifier)
        .removeVideos(_selectedIndices);
    _hideSelectionMode();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ $count videos restored to gallery'),
          backgroundColor: const Color(0xFF00C853),
        ),
      );
    }
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
        backgroundColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.mediaPaths.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaPaths.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
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
        const BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
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
}
