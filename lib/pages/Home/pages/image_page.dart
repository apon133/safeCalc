import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// List to hold camera descriptions and image file paths
List<CameraDescription> cameras = [];
List<String> imagePagePath = [];

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  ImagePageState createState() => ImagePageState();
}

class ImagePageState extends State<ImagePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showImageSourceSelectionDialog();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Image'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MasonryGridView.count(
              itemCount: imagePagePath.length,
              crossAxisCount: 2,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onLongPress: () => _showDeleteConfirmationDialog(index),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ImageFullScreenPage(
                        imagePath: imagePagePath[index],
                      ),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.file(File(imagePagePath[index])),
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
                // if()
              
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
                    child: const Text('Capture from Camera'),
                  ),
                //! if desktop
             

                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _captureMedia(ImageSource.gallery);
                  },
                  child: const Text('Pick from Gallery'),
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

  Future<void> _showDeleteConfirmationDialog(int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image?'),
          content: const Text('Are you sure you want to delete this image?'),
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
      imagePagePath.removeAt(index);
    });
    await prefs.setStringList('mediaImagePageFilePaths', imagePagePath);
  }
}

class ImageFullScreenPage extends StatelessWidget {
  final String imagePath;

  const ImageFullScreenPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(80),
          panEnabled: false,
          scaleEnabled: true,
          minScale: 1.0,
          maxScale: 2.2,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.fill,
          ),
        ),
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
