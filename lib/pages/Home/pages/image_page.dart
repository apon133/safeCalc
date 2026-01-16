import 'dart:io';
import 'package:calculetor/core/providers.dart';
import 'package:calculetor/main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';

class ImagePage extends ConsumerStatefulWidget {
  const ImagePage({super.key});

  @override
  ConsumerState<ImagePage> createState() => ImagePageState();
}

class ImagePageState extends ConsumerState<ImagePage> {
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

  void _hideSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(imageGalleryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF63FFDA),
              onPressed: () => _showImageSourceSelectionDialog(),
              child: const Icon(Icons.add, color: Colors.black),
            ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          _isSelectionMode ? '${_selectedIndices.length} Selected' : 'Images',
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
                  color: Color(0xFF63FFDA)),
              onPressed: _selectedIndices.isEmpty
                  ? null
                  : () => _unlockSelectedImages(images),
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
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
              tooltip: 'Selection Mode',
            ),
        ],
      ),
      body: images.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 80, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'No Protected Images',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 16),
                  ),
                ],
              ),
            )
          : MasonryGridView.count(
              padding: const EdgeInsets.all(12),
              itemCount: images.length,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
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
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ImageFullScreenPage(
                          initialIndex: index,
                          imagePaths: images,
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
                            ? const Color(0xFF63FFDA)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(images[index]),
                            fit: BoxFit.cover,
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
                                  ? const Color(0xFF63FFDA)
                                  : Colors.white70,
                            ),
                          ),
                        if (_isSelectionMode && isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF63FFDA).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showImageSourceSelectionDialog() async {
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
                leading: const Icon(Icons.camera_alt_outlined,
                    color: Color(0xFF63FFDA)),
                title: const Text('Capture from Camera',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TakeImageScreen(),
                  ));
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading:
                    const Icon(Icons.photo_outlined, color: Color(0xFF63FFDA)),
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
    final List<XFile> mediaFiles = await imagePicker.pickMultiImage();
    if (mediaFiles.isEmpty) return;

    await ref.read(imageGalleryProvider.notifier).addImages(
          mediaFiles.map((file) => file.path).toList(),
        );
  }

  Future<void> _showMultiDeleteConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text('Delete ${_selectedIndices.length} Images?',
              style: const TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to delete these images from the vault?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(imageGalleryProvider.notifier)
                    .removeImages(_selectedIndices);
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

  Future<void> _unlockSelectedImages(List<String> currentImages) async {
    int count = 0;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Unlocking images...'),
          duration: Duration(milliseconds: 500)),
    );

    for (int index in _selectedIndices) {
      try {
        await Gal.putImage(currentImages[index]);
        count++;
      } catch (e) {
        debugPrint('Error unlocking image: $e');
      }
    }

    await ref
        .read(imageGalleryProvider.notifier)
        .removeImages(_selectedIndices);
    _hideSelectionMode();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ $count images restored to gallery'),
          backgroundColor: const Color(0xFF00C853),
        ),
      );
    }
  }
}

class ImageFullScreenPage extends StatefulWidget {
  final int initialIndex;
  final List<String> imagePaths;

  const ImageFullScreenPage(
      {super.key, required this.initialIndex, required this.imagePaths});

  @override
  State<ImageFullScreenPage> createState() => _ImageFullScreenPageState();
}

class _ImageFullScreenPageState extends State<ImageFullScreenPage> {
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
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Hero(
                tag: widget.imagePaths[index],
                child: Image.file(
                  File(widget.imagePaths[index]),
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TakeImageScreen extends ConsumerStatefulWidget {
  const TakeImageScreen({super.key});

  @override
  ConsumerState<TakeImageScreen> createState() => TakeImageScreenState();
}

class TakeImageScreenState extends ConsumerState<TakeImageScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(child: CameraPreview(_controller)),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF63FFDA)));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: Colors.white,
        child: const Icon(Icons.camera, color: Colors.black, size: 40),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final XFile file = await _controller.takePicture();
            await ref
                .read(imageGalleryProvider.notifier)
                .addImages([file.path]);
            if (mounted) Navigator.pop(context);
          } catch (e) {
            debugPrint('Camera error: $e');
          }
        },
      ),
    );
  }
}
