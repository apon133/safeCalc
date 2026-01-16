import 'package:calculetor/pages/Home/pages/image_page.dart';
import 'package:calculetor/pages/Home/pages/network_image_page.dart';
import 'package:calculetor/pages/Home/pages/video_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Safe Vault',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Your Protected Media',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  GridBox(
                    boxName: 'Images',
                    boxIcon: Icons.photo_library_outlined,
                    gradient: const [Color(0xFF63FFDA), Color(0xFF00BFA5)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (b) => const ImagePage()),
                      );
                    },
                  ),
                  GridBox(
                    boxName: 'Cloud',
                    boxIcon: Icons.cloud_outlined,
                    gradient: const [Color(0xFF42A5F5), Color(0xFF1976D2)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (b) => const NetworkImagePage()),
                      );
                    },
                  ),
                  GridBox(
                    boxName: 'Videos',
                    boxIcon: Icons.movie_outlined,
                    gradient: const [Color(0xFFFF7043), Color(0xFFE64A19)],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (b) => const MediaPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'apon133',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridBox extends StatelessWidget {
  final Function()? onTap;
  final String boxName;
  final IconData boxIcon;
  final List<Color> gradient;

  const GridBox({
    super.key,
    this.onTap,
    required this.boxName,
    required this.boxIcon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              gradient[0].withOpacity(0.15),
              gradient[1].withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: gradient[0].withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gradient[0].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                boxIcon,
                size: 40,
                color: gradient[0],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              boxName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
