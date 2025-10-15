import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/recent_files_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../services/file_service.dart';
import 'text_viewer_screen.dart';
import 'image_viewer_screen.dart';
import 'package:open_filex/open_filex.dart';
import '../config/constants/app_constants.dart';

class RecentFilesScreen extends StatelessWidget {
  const RecentFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecentFilesProvider>(
      builder: (context, recentProvider, child) {
        if (recentProvider.recentFiles.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history,
            message: 'Sin archivos recientes',
            subtitle: 'Los archivos que abras aparecerán aquí',
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
                    '${recentProvider.recentFiles.length} archivos recientes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => _showClearDialog(context, recentProvider),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Limpiar todo'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentProvider.recentFiles.length,
                itemBuilder: (context, index) {
                  final file = recentProvider.recentFiles[index];
                  return FutureBuilder<bool>(
                    future: _checkIfExists(file.fullPath),
                    builder: (context, snapshot) {
                      final exists = snapshot.data ?? true;

                      return Dismissible(
                        key: Key(file.fullPath),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          recentProvider.removeRecentFile(file.fullPath);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Eliminado de recientes')),
                          );
                        },
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppConstants.getFileIcon(file.extension),
                                style: TextStyle(
                                  fontSize: 32,
                                  color: exists ? null : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            file.name,
                            style: TextStyle(
                              color: exists ? null : Colors.grey,
                              decoration: exists ? null : TextDecoration.lineThrough,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.fullPath,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    file.formattedSize,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Text(' • '),
                                  Text(
                                    file.formattedDate,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: !exists
                              ? const Icon(Icons.warning, color: Colors.orange, size: 20)
                              : null,
                          onTap: exists ? () => _handleFileTap(context, file) : null,
                        ),
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
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleFileTap(BuildContext context, file) async {
    final recentProvider = Provider.of<RecentFilesProvider>(context, listen: false);
    await recentProvider.addRecentFile(file);

    if (FileService.isTextFile(file.extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextViewerScreen(filePath: file.fullPath),
        ),
      );
    } else if (FileService.isImageFile(file.extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(filePath: file.fullPath),
        ),
      );
    } else {
      _openWithExternalApp(context, file.fullPath);
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

  void _showClearDialog(BuildContext context, RecentFilesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar recientes'),
        content: const Text('¿Estás seguro de eliminar todos los archivos recientes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.clearRecentFiles();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial limpiado')),
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