import 'package:flutter/foundation.dart';
import '../models/file_item.dart';
import '../services/file_service.dart';

enum ViewMode { list, grid }

class FileProvider extends ChangeNotifier {
  List<FileItem> _files = [];
  String _currentPath = '';
  bool _isLoading = false;
  String? _error;
  ViewMode _viewMode = ViewMode.list;
  List<String> _pathHistory = [];

  List<FileItem> get files => _files;
  String get currentPath => _currentPath;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ViewMode get viewMode => _viewMode;
  bool get canGoBack => _pathHistory.length > 1;

  Future<void> loadDirectory(String path) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _files = await FileService.listDirectory(path);
      _currentPath = path;

      // Agregar al historial si es diferente del último
      if (_pathHistory.isEmpty || _pathHistory.last != path) {
        _pathHistory.add(path);
      }

      _error = null;
    } catch (e) {
      _error = 'Error al cargar el directorio: ${e.toString()}';
      _files = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goBack() {
    if (_pathHistory.length > 1) {
      _pathHistory.removeLast();
      final previousPath = _pathHistory.last;
      _pathHistory.removeLast(); // Remover para que loadDirectory lo agregue de nuevo
      loadDirectory(previousPath);
    }
  }

  void toggleViewMode() {
    _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
    notifyListeners();
  }

  Future<void> createFolder(String folderName) async {
    try {
      await FileService.createDirectory(_currentPath, folderName);
      await loadDirectory(_currentPath);
    } catch (e) {
      _error = 'Error al crear carpeta: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> renameItem(String oldPath, String newName) async {
    try {
      await FileService.renameFileOrDirectory(oldPath, newName);
      await loadDirectory(_currentPath);
    } catch (e) {
      _error = 'Error al renombrar: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteItem(String filePath) async {
    try {
      await FileService.deleteFileOrDirectory(filePath);
      await loadDirectory(_currentPath);
    } catch (e) {
      _error = 'Error al eliminar: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> copyItem(String sourcePath, String destinationPath) async {
    try {
      await FileService.copyFileOrDirectory(sourcePath, destinationPath);
      await loadDirectory(_currentPath);
    } catch (e) {
      _error = 'Error al copiar: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> moveItem(String sourcePath, String destinationPath) async {
    try {
      await FileService.moveFileOrDirectory(sourcePath, destinationPath);
      await loadDirectory(_currentPath);
    } catch (e) {
      _error = 'Error al mover: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<FileItem>> searchFiles(String query) async {
    try {
      print('FileProvider: Buscando "$query" en $_currentPath');

      if (query.trim().isEmpty) {
        // Si no hay query, buscar todos los archivos
        final results = await FileService.searchFiles(_currentPath, '');
        print('FileProvider: Resultados sin query: ${results.length}');
        return results;
      }

      final results = await FileService.searchFiles(_currentPath, query.trim());
      print('FileProvider: Resultados con query: ${results.length}');
      return results;
    } catch (e) {
      _error = 'Error en la búsqueda: ${e.toString()}';
      print('FileProvider: Error - $_error');
      notifyListeners();
      return [];
    }
  }

  // Búsqueda simple solo en el directorio actual (sin recursión)
  Future<List<FileItem>> searchInCurrentDirectory(String query) async {
    try {
      if (query.trim().isEmpty) {
        return _files;
      }

      return _files.where((file) {
        return file.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<FileItem>> searchFilesByExtension(List<String> extensions) async {
    try {
      print('Buscando archivos por extensiones: $extensions');
      final allFiles = await FileService.searchFiles(_currentPath, '');
      print('Total de archivos encontrados: ${allFiles.length}');

      final filtered = allFiles.where((file) {
        final match = !file.isDirectory &&
            extensions.any((ext) => file.extension.toLowerCase() == ext.toLowerCase());
        if (match) print('Coincide: ${file.name}');
        return match;
      }).toList();

      print('Archivos filtrados: ${filtered.length}');
      return filtered;
    } catch (e) {
      print('Error filtrando por extensión: $e');
      return [];
    }
  }

  Future<List<FileItem>> searchFilesByDate(DateTime date) async {
    try {
      print('Buscando archivos de fecha: $date');
      final allFiles = await FileService.searchFiles(_currentPath, '');

      final filtered = allFiles.where((file) {
        final fileDate = file.lastModified;
        final matches = fileDate.year == date.year &&
            fileDate.month == date.month &&
            fileDate.day == date.day;
        if (matches) print('Fecha coincide: ${file.name}');
        return matches;
      }).toList();

      print('Archivos por fecha: ${filtered.length}');
      return filtered;
    } catch (e) {
      print('Error filtrando por fecha: $e');
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}