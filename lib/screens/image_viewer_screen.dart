import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import '../providers/favorites_provider.dart';

class ImageViewerScreen extends StatefulWidget {
  final String filePath;

  const ImageViewerScreen({super.key, required this.filePath});

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  double _rotation = 0.0;

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(widget.filePath);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(widget.filePath);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(fileName),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_outline),
            onPressed: () {
              favoritesProvider.toggleFavorite(
                widget.filePath,
                fileName,
                false,
              );
            },
            tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
          ),
          IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed: () {
              setState(() {
                _rotation += 90;
                if (_rotation >= 360) _rotation = 0;
              });
            },
            tooltip: 'Rotar',
          ),
        ],
      ),
      body: Center(
        child: Transform.rotate(
          angle: _rotation * 3.14159 / 180,
          child: PhotoView(
            imageProvider: FileImage(File(widget.filePath)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                color: Colors.white,
              ),
            ),
            errorBuilder: (context, error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar la imagen',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}