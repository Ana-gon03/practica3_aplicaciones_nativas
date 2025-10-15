import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import '../services/file_service.dart';
import '../providers/favorites_provider.dart';

class TextViewerScreen extends StatefulWidget {
  final String filePath;

  const TextViewerScreen({super.key, required this.filePath});

  @override
  State<TextViewerScreen> createState() => _TextViewerScreenState();
}

class _TextViewerScreenState extends State<TextViewerScreen> {
  String? _content;
  bool _isLoading = true;
  String? _error;
  double _fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await FileService.readTextFile(widget.filePath);
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(widget.filePath);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(widget.filePath);

    return Scaffold(
      appBar: AppBar(
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'increase') {
                setState(() => _fontSize += 2);
              } else if (value == 'decrease') {
                setState(() => _fontSize = (_fontSize - 2).clamp(8.0, 32.0));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'increase',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 12),
                    Text('Aumentar tamaño'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'decrease',
                child: Row(
                  children: [
                    Icon(Icons.remove),
                    SizedBox(width: 12),
                    Text('Reducir tamaño'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
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
                'Error al cargar el archivo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFile,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _content ?? '',
        style: TextStyle(
          fontSize: _fontSize,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}