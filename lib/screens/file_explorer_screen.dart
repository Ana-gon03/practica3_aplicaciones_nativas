import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/file_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/recent_files_provider.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';
import '../widgets/file_item_widget.dart';
import '../widgets/breadcrumb_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../models/file_item.dart';
import 'text_viewer_screen.dart';
import 'image_viewer_screen.dart';
import 'package:open_filex/open_filex.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  State<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  bool _initialized = false;
  String? _selectedItemPath;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<FileItem> _searchResults = [];
  bool _isSearchingFiles = false;
  List<Directory> _storageLocations = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeDirectory();
      _initialized = true;
    }
  }

  Future<void> _initializeDirectory() async {
    final fileProvider = Provider.of<FileProvider>(context, listen: false);
    _storageLocations = await StorageService.getStorageDirectories();
    final defaultDir = await StorageService.getDefaultDirectory();
    await fileProvider.loadDirectory(defaultDir.path);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(
      builder: (context, fileProvider, child) {
        if (fileProvider.isLoading && fileProvider.files.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            if (!_isSearching) ...[
              BreadcrumbWidget(currentPath: fileProvider.currentPath),
              _buildToolbar(fileProvider),
            ] else
              _buildSearchBar(fileProvider),
            Expanded(
              child: _isSearching && _searchResults.isNotEmpty
                  ? _buildSearchResults()
                  : fileProvider.error != null
                  ? _buildErrorWidget(fileProvider)
                  : fileProvider.files.isEmpty
                  ? const EmptyStateWidget(
                icon: Icons.folder_open,
                message: 'Esta carpeta está vacía',
              )
                  : RefreshIndicator(
                onRefresh: () => fileProvider.loadDirectory(fileProvider.currentPath),
                child: fileProvider.viewMode == ViewMode.list
                    ? _buildListView(fileProvider)
                    : _buildGridView(fileProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(FileProvider fileProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: fileProvider.canGoBack ? () => fileProvider.goBack() : null,
            tooltip: 'Atrás',
          ),
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () => _showStorageSelector(),
            tooltip: 'Cambiar almacenamiento',
          ),
          IconButton(
            icon: Icon(
              fileProvider.viewMode == ViewMode.list ? Icons.grid_view : Icons.list,
            ),
            onPressed: () => fileProvider.toggleViewMode(),
            tooltip: 'Cambiar vista',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _isSearching = true),
            tooltip: 'Buscar',
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: () => _showCreateFolderDialog(fileProvider),
            tooltip: 'Nueva carpeta',
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fileProvider.loadDirectory(fileProvider.currentPath),
            tooltip: 'Actualizar',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(FileProvider fileProvider) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Buscar archivos y carpetas...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSearchingFiles)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        _searchResults.clear();
                      });
                    },
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) => _performSearch(fileProvider, value),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _isSearchingFiles
                    ? null
                    : () => _performSearch(fileProvider, _searchController.text),
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Buscar'),
              ),
              OutlinedButton.icon(
                onPressed: _isSearchingFiles
                    ? null
                    : () => _searchInCurrentFolder(fileProvider),
                icon: const Icon(Icons.folder, size: 18),
                label: const Text('Solo aquí'),
              ),
              OutlinedButton.icon(
                onPressed: _isSearchingFiles
                    ? null
                    : () => _showFilterDialog(fileProvider),
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filtros'),
              ),
            ],
          ),
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_searchResults.length} resultado(s) encontrado(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _searchInCurrentFolder(FileProvider fileProvider) async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un texto para buscar')),
      );
      return;
    }

    setState(() {
      _isSearchingFiles = true;
      _searchResults.clear();
    });

    try {
      final results = await fileProvider.searchInCurrentDirectory(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearchingFiles = false;
        });

        if (results.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron resultados en esta carpeta')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${results.length} resultado(s) en esta carpeta')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingFiles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _performSearch(FileProvider fileProvider, String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un texto para buscar')),
      );
      return;
    }

    setState(() {
      _isSearchingFiles = true;
      _searchResults.clear();
    });

    // Mostrar mensaje de inicio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buscando "$trimmedQuery"...'),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      print('=== INICIANDO BÚSQUEDA ===');
      print('Query: "$trimmedQuery"');
      print('Directorio actual: ${fileProvider.currentPath}');

      final results = await fileProvider.searchFiles(trimmedQuery);

      print('Resultados obtenidos: ${results.length}');
      for (var result in results.take(5)) {
        print('  - ${result.name} (${result.isDirectory ? "DIR" : "FILE"})');
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearchingFiles = false;
        });

        if (results.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontró "$trimmedQuery"'),
              action: SnackBarAction(
                label: 'Buscar solo aquí',
                onPressed: () => _searchInCurrentFolder(fileProvider),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${results.length} resultado(s) encontrado(s)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('ERROR EN BÚSQUEDA: $e');
      if (mounted) {
        setState(() => _isSearchingFiles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterDialog(FileProvider fileProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar búsqueda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecciona un filtro para aplicar:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildFilterOption(
                context,
                Icons.image,
                'Imágenes',
                'Buscar solo imágenes (JPG, PNG, etc.)',
                    () {
                  Navigator.pop(context);
                  _filterByExtensions(fileProvider, ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']);
                },
              ),
              _buildFilterOption(
                context,
                Icons.text_fields,
                'Documentos de texto',
                'Buscar archivos de texto',
                    () {
                  Navigator.pop(context);
                  _filterByExtensions(fileProvider, ['.txt', '.md', '.log', '.json', '.xml']);
                },
              ),
              _buildFilterOption(
                context,
                Icons.video_file,
                'Videos',
                'Buscar archivos de video',
                    () {
                  Navigator.pop(context);
                  _filterByExtensions(fileProvider, ['.mp4', '.avi', '.mkv', '.mov']);
                },
              ),
              _buildFilterOption(
                context,
                Icons.audio_file,
                'Audio',
                'Buscar archivos de audio',
                    () {
                  Navigator.pop(context);
                  _filterByExtensions(fileProvider, ['.mp3', '.wav', '.flac', '.aac']);
                },
              ),
              _buildFilterOption(
                context,
                Icons.date_range,
                'Modificados hoy',
                'Archivos modificados hoy',
                    () {
                  Navigator.pop(context);
                  _filterByDate(fileProvider, DateTime.now());
                },
              ),
              _buildFilterOption(
                context,
                Icons.calendar_month,
                'Modificados esta semana',
                'Archivos de los últimos 7 días',
                    () {
                  Navigator.pop(context);
                  _filterByDateRange(fileProvider, 7);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _filterByExtensions(FileProvider fileProvider, List<String> extensions) async {
    setState(() => _isSearchingFiles = true);

    try {
      final filtered = await fileProvider.searchFilesByExtension(extensions);

      if (mounted) {
        setState(() {
          _searchResults = filtered;
          _isSearchingFiles = false;
        });

        if (filtered.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron archivos con ese filtro')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Se encontraron ${filtered.length} archivos')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingFiles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _filterByDate(FileProvider fileProvider, DateTime date) async {
    setState(() => _isSearchingFiles = true);

    try {
      final filtered = await fileProvider.searchFilesByDate(date);

      if (mounted) {
        setState(() {
          _searchResults = filtered;
          _isSearchingFiles = false;
        });

        if (filtered.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron archivos modificados hoy')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Se encontraron ${filtered.length} archivos de hoy')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingFiles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _filterByDateRange(FileProvider fileProvider, int days) async {
    setState(() => _isSearchingFiles = true);

    try {
      final allFiles = await fileProvider.searchFiles('');
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: days));

      final filtered = allFiles.where((file) {
        return file.lastModified.isAfter(cutoffDate);
      }).toList();

      if (mounted) {
        setState(() {
          _searchResults = filtered;
          _isSearchingFiles = false;
        });

        if (filtered.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se encontraron archivos de los últimos $days días')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Se encontraron ${filtered.length} archivos')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingFiles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && !_isSearchingFiles) {
      return const EmptyStateWidget(
        icon: Icons.search_off,
        message: 'No se encontraron resultados',
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final file = _searchResults[index];
        return FileItemWidget(
          fileItem: file,
          isSelected: false,
          onTap: () => _handleFileTap(file),
          onLongPress: () => _showFileOptions(file),
        );
      },
    );
  }

  void _showStorageSelector() async {
    // Mostrar diálogo de carga mientras se obtienen las ubicaciones
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      _storageLocations = await StorageService.getStorageDirectories();

      if (!mounted) return;

      // Cerrar diálogo de carga
      Navigator.pop(context);

      if (_storageLocations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron ubicaciones de almacenamiento')),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.storage, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Seleccionar almacenamiento',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _storageLocations.length,
                  itemBuilder: (context, index) {
                    final storage = _storageLocations[index];
                    final storageName = StorageService.getStorageName(storage.path);
                    final subtitle = StorageService.getStorageSubtitle(storage.path);

                    return ListTile(
                      leading: Icon(
                        _getStorageIcon(storage.path),
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      title: Text(
                        storageName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subtitle),
                          const SizedBox(height: 2),
                          Text(
                            storage.path,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        Navigator.pop(context);

                        // Verificar si el directorio es accesible
                        try {
                          await storage.list().first.timeout(
                            const Duration(seconds: 2),
                          );

                          if (mounted) {
                            final fileProvider = Provider.of<FileProvider>(context, listen: false);
                            await fileProvider.loadDirectory(storage.path);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Abriendo $storageName')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No se puede acceder a esta ubicación: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de carga si hay error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error obteniendo ubicaciones: $e')),
        );
      }
    }
  }

  IconData _getStorageIcon(String path) {
    if (path.contains('/storage/emulated/0') || path.contains('/sdcard')) {
      return Icons.phone_android;
    } else if (path.startsWith('/storage/') &&
        !path.contains('emulated') &&
        path.split('/').length <= 3) {
      return Icons.sd_card;
    } else if (path.contains('Android/data')) {
      return Icons.folder_special;
    } else if (path.contains('app_flutter')) {
      return Icons.source;
    } else {
      return Icons.storage;
    }
  }

  Widget _buildErrorWidget(FileProvider fileProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              fileProvider.error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                fileProvider.clearError();
                _initializeDirectory();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(FileProvider fileProvider) {
    return ListView.builder(
      itemCount: fileProvider.files.length,
      itemBuilder: (context, index) {
        final file = fileProvider.files[index];
        return FileItemWidget(
          fileItem: file,
          isSelected: _selectedItemPath == file.fullPath,
          onTap: () => _handleFileTap(file),
          onLongPress: () => _showFileOptions(file),
        );
      },
    );
  }

  Widget _buildGridView(FileProvider fileProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: fileProvider.files.length,
      itemBuilder: (context, index) {
        final file = fileProvider.files[index];
        return FileItemWidget(
          fileItem: file,
          isSelected: _selectedItemPath == file.fullPath,
          onTap: () => _handleFileTap(file),
          onLongPress: () => _showFileOptions(file),
          isGridView: true,
        );
      },
    );
  }

  Future<void> _handleFileTap(file) async {
    if (file.isDirectory) {
      final fileProvider = Provider.of<FileProvider>(context, listen: false);
      await fileProvider.loadDirectory(file.fullPath);
      // Cerrar búsqueda si está activa
      if (_isSearching) {
        setState(() {
          _isSearching = false;
          _searchController.clear();
          _searchResults.clear();
        });
      }
    } else {
      final recentProvider = Provider.of<RecentFilesProvider>(context, listen: false);
      await recentProvider.addRecentFile(file);

      if (FileService.isTextFile(file.extension)) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TextViewerScreen(filePath: file.fullPath),
            ),
          );
        }
      } else if (FileService.isImageFile(file.extension)) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewerScreen(filePath: file.fullPath),
            ),
          );
        }
      } else {
        _openWithExternalApp(file.fullPath);
      }
    }
  }

  Future<void> _openWithExternalApp(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se puede abrir el archivo: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el archivo: $e')),
        );
      }
    }
  }

  void _showFileOptions(file) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final isFavorite = favoritesProvider.isFavorite(file.fullPath);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(isFavorite ? Icons.star : Icons.star_outline),
              title: Text(isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos'),
              onTap: () {
                favoritesProvider.toggleFavorite(
                  file.fullPath,
                  file.name,
                  file.isDirectory,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Renombrar'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedItemPath = file.fullPath);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${file.name} seleccionado para copiar'),
                    action: SnackBarAction(
                      label: 'Pegar aquí',
                      onPressed: () => _pasteItem(file.fullPath, false),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move),
              title: const Text('Mover'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedItemPath = file.fullPath);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${file.name} seleccionado para mover'),
                    action: SnackBarAction(
                      label: 'Mover aquí',
                      onPressed: () => _pasteItem(file.fullPath, true),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Información'),
              onTap: () {
                Navigator.pop(context);
                _showFileInfo(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog(FileProvider fileProvider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva carpeta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la carpeta',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await fileProvider.createFolder(controller.text);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Carpeta creada exitosamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(file) {
    final controller = TextEditingController(text: file.name);
    final fileProvider = Provider.of<FileProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuevo nombre',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty && controller.text != file.name) {
                try {
                  await fileProvider.renameItem(file.fullPath, controller.text);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Renombrado exitosamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Renombrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(file) {
    final fileProvider = Provider.of<FileProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await fileProvider.deleteItem(file.fullPath);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Eliminado exitosamente')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _pasteItem(String sourcePath, bool isMove) async {
    final fileProvider = Provider.of<FileProvider>(context, listen: false);
    final destinationPath = fileProvider.currentPath;

    try {
      if (isMove) {
        await fileProvider.moveItem(sourcePath, destinationPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Movido exitosamente')),
          );
        }
      } else {
        await fileProvider.copyItem(sourcePath, destinationPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copiado exitosamente')),
          );
        }
      }
      setState(() => _selectedItemPath = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showFileInfo(file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tipo', file.isDirectory ? 'Carpeta' : 'Archivo'),
            if (!file.isDirectory) _buildInfoRow('Tamaño', file.formattedSize),
            _buildInfoRow('Modificado', file.formattedDate),
            _buildInfoRow('Ruta', file.fullPath),
            if (!file.isDirectory) _buildInfoRow('Extensión', file.extension),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}