import 'package:cached_network_image/cached_network_image.dart';
import 'package:calculetor/core/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NetworkImagePage extends ConsumerWidget {
  const NetworkImagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkImages = ref.watch(networkGalleryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF42A5F5),
        onPressed: () => _showAddImageDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Cloud Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: networkImages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_outlined,
                      size: 80, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'No Cloud Images',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: MasonryGridView.count(
                itemCount: networkImages.length,
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () =>
                        _showDeleteConfirmationDialog(context, ref, index),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (b) => ImageFullScreenPage(
                            imagePath: networkImages[index]),
                      ));
                    },
                    child: Hero(
                      tag: networkImages[index],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: networkImages[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey[900],
                            child: const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF42A5F5))),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[900],
                            child: const Icon(Icons.broken_image_outlined,
                                color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _showAddImageDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Add Cloud Image',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoTextField(
                controller: controller,
                placeholder: 'Paste Image URL here...',
                placeholderStyle: const TextStyle(color: Colors.white24),
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref
                      .read(networkGalleryProvider.notifier)
                      .addUrl(controller.text);
                  Navigator.pop(context);
                }
              },
              child:
                  const Text('Add', style: TextStyle(color: Color(0xFF42A5F5))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Remove Image?',
              style: TextStyle(color: Colors.white)),
          content: const Text(
              'This will remove the image from your cloud vault.',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () {
                ref.read(networkGalleryProvider.notifier).removeAt(index);
                Navigator.pop(context);
              },
              child: const Text('Remove',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}

class ImageFullScreenPage extends StatelessWidget {
  final String imagePath;

  const ImageFullScreenPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Hero(
            tag: imagePath,
            child: CachedNetworkImage(
              fit: BoxFit.contain,
              imageUrl: imagePath,
              placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF42A5F5))),
              errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  color: Colors.white24,
                  size: 100),
            ),
          ),
        ),
      ),
    );
  }
}
