import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/favorites_provider.dart';
import '../providers/file_provider.dart';
import '../providers/recent_files_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../models/file_item.dart';
import '../services/file_service.dart';
import 'text_viewer_screen.dart';
import 'image_viewer_screen.dart';
import 'package:open_filex/open_filex.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        if (favoritesProvider.favorites.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.star_outline,
            message: 'No hay favoritos',
            subtitle: 'Marca archivos y carpetas como favoritos para acceder rápidamente',
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${favoritesProvider.favorites.length} favoritos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => _showClearDialog(context, favoritesProvider),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Limpiar todo'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: favoritesProvider.favorites.length,
                itemBuilder: (context, index) {
                  final favorite = favoritesProvider.favorites[index];
                  return FutureBuilder<bool>(
                    future: _checkIfExists(favorite.path),
                    builder: (context, snapshot) {
                      final exists = snapshot.data ?? true;

                      return ListTile(
                        leading: Icon(
                          favorite.isDirectory ? Icons.folder : Icons.insert_drive_file,
                          color: exists ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                        title: Text(
                          favorite.name,
                          style: TextStyle(
                            color: exists ? null : Colors.grey,
                            decoration: exists ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          favorite.path,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!exists)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.warning, color: Colors.orange, size: 20),
                              ),
                            IconButton(
                              icon: const Icon(Icons.star, color: Colors.amber),
                              onPressed: () {
                                favoritesProvider.removeFavorite(favorite.path);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Eliminado de favoritos')),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: exists ? () => _handleFavoriteTap(context, favorite) : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkIfExists(String path) async {
    try {
      final type = await FileSystemEntity.type(path);
      return type != FileSystemEntityType.notFound;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleFavoriteTap(BuildContext context, favorite) async {
    if (favorite.isDirectory) {
      final fileProvider = Provider.of<FileProvider>(context, listen: false);
      await fileProvider.loadDirectory(favorite.path);

      // Cambiar a la pestaña del explorador
      if (context.mounted) {
        DefaultTabController.of(context)?.animateTo(0);
      }
    } else {
      try {
        final file = File(favorite.path);
        final stat = await file.stat();
        final fileItem = FileItem(
          name: favorite.name,
          fullPath: favorite.path,
          isDirectory: false,
          size: stat.size,
          lastModified: stat.modified,
          extension: favorite.path.split('.').last,
        );

        final recentProvider = Provider.of<RecentFilesProvider>(context, listen: false);
        await recentProvider.addRecentFile(fileItem);

        final extension = '.${favorite.path.split('.').last}';

        if (context.mounted) {
          if (FileService.isTextFile(extension)) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TextViewerScreen(filePath: favorite.path),
              ),
            );
          } else if (FileService.isImageFile(extension)) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewerScreen(filePath: favorite.path),
              ),
            );
          } else {
            _openWithExternalApp(context, favorite.path);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al abrir el archivo: $e')),
          );
        }
      }
    }
  }

  Future<void> _openWithExternalApp(BuildContext context, String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se puede abrir el archivo: ${result.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showClearDialog(BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar favoritos'),
        content: const Text('¿Estás seguro de eliminar todos los favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.clearFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favoritos eliminados')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}