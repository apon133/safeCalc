import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gal/gal.dart';

// List to hold camera descriptions and image file paths
List<CameraDescription> cameras = [];
List<String> imagePagePath = [];


class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  ImagePageState createState() => ImagePageState();
}

class ImagePageState extends State<ImagePage> {
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadImagePageMediaFilePaths();
  }

  Future<void> _loadImagePageMediaFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      imagePagePath = prefs.getStringList('mediaImagePageFilePaths') ?? [];
    });
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
              onPressed: () {
                _showImageSourceSelectionDialog();
              },
              child: const Icon(Icons.add),
            ),
      appBar: AppBar(
        title: Text(
            _isSelectionMode ? '${_selectedIndices.length} Selected' : 'Image'),
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
                  : () => _unlockSelectedImages(),
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
              itemCount: imagePagePath.length,
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
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ImageFullScreenPage(
                          initialIndex: index,
                          imagePaths: imagePagePath,
                        ),
                      ));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagePagePath[index]),
                            fit: BoxFit.cover,
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
                              color: isSelected ? Colors.blue : Colors.white70,
                            ),
                          ),
                        if (_isSelectionMode && isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
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

  Future<void> _showImageSourceSelectionDialog() async {
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
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TakeImageScreen(
                        onImageCapture: () {
                          setState(() {});
                        },
                      ),
                    ));
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Capture from Camera'),
                  ),
                ),
                const SizedBox(height: 10),
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

    // Use pickMultiImage to allow selecting multiple images
    final List<XFile> mediaFiles = await imagePicker.pickMultiImage();
    if (mediaFiles.isEmpty) {
      return;
    }

    setState(() {
      // Add all selected images to the imagePagePath list
      imagePagePath.addAll(mediaFiles.map((file) => file.path));
    });

    await _saveImagePageMediaFilePaths();
  }

  Future<void> _showMultiDeleteConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete ${_selectedIndices.length} Images?'),
          content: const Text(
              'Are you sure you want to delete the selected images? This action cannot be undone.'),
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

  Future<void> _unlockSelectedImages() async {
    int count = 0;
    List<int> sortedIndices = _selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));

    // Show progress dialog or snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Unlocking images...'), duration: Duration(seconds: 1)),
    );

    for (int index in sortedIndices) {
      try {
        final imagePath = imagePagePath[index];
        await Gal.putImage(imagePath);
        count++;
      } catch (e) {
        print('Error unlocking image at index $index: $e');
      }
    }

    _deleteSelectedMedia();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ $count images unlocked and saved to gallery'),
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
        imagePagePath.removeAt(index);
      }
      _isSelectionMode = false;
      _selectedIndices.clear();
    });

    await prefs.setStringList('mediaImagePageFilePaths', imagePagePath);
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
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.file(
                File(widget.imagePaths[index]),
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          );
        },
      ),
    );
  }
}

class TakeImageScreen extends StatefulWidget {
  final Function onImageCapture;
  const TakeImageScreen({
    super.key,
    required this.onImageCapture,
  });

  @override
  TakeImageScreenState createState() => TakeImageScreenState();
}

class TakeImageScreenState extends State<TakeImageScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
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
      appBar: AppBar(title: const Text('Camera Demo')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          await _initializeControllerFuture;
          final XFile file = await _controller.takePicture();
          final String filePath = file.path;
          setState(() {
            imagePagePath.add(filePath);
          });
          await _saveImagePageMediaFilePaths();
          widget.onImageCapture();
          setState(() {});
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        },
      ),
    );
  }
}

Future<void> _saveImagePageMediaFilePaths() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('mediaImagePageFilePaths', imagePagePath);
}
