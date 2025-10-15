import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/file_item.dart';
import '../config/constants/app_constants.dart';

class FileService {
  static Future<List<FileItem>> listDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);

      if (!await directory.exists()) {
        throw Exception('El directorio no existe');
      }

      final entities = await directory.list().toList();
      final items = <FileItem>[];

      for (var entity in entities) {
        try {
          final item = FileItem.fromFileSystemEntity(entity);
          items.add(item);
        } catch (e) {
          // Ignorar archivos inaccesibles
          print('Error accediendo a ${entity.path}: $e');
        }
      }

      // Ordenar: directorios primero, luego por nombre
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return items;
    } catch (e) {
      print('Error listando directorio: $e');
      rethrow;
    }
  }

  static Future<String> readTextFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw Exception('El archivo no existe');
      }

      final stat = await file.stat();
      if (stat.size > AppConstants.maxTextFileSize) {
        throw Exception('El archivo es demasiado grande para visualizar');
      }

      return await file.readAsString();
    } catch (e) {
      print('Error leyendo archivo de texto: $e');
      rethrow;
    }
  }

  static Future<void> createDirectory(String parentPath, String folderName) async {
    try {
      final newPath = path.join(parentPath, folderName);
      final directory = Directory(newPath);

      if (await directory.exists()) {
        throw Exception('Ya existe una carpeta con ese nombre');
      }

      await directory.create(recursive: true);
    } catch (e) {
      print('Error creando directorio: $e');
      rethrow;
    }
  }

  static Future<void> renameFileOrDirectory(String oldPath, String newName) async {
    try {
      final entity = await FileSystemEntity.type(oldPath);

      if (entity == FileSystemEntityType.notFound) {
        throw Exception('El archivo o carpeta no existe');
      }

      final parentPath = path.dirname(oldPath);
      final newPath = path.join(parentPath, newName);

      if (await FileSystemEntity.isFile(oldPath)) {
        await File(oldPath).rename(newPath);
      } else {
        await Directory(oldPath).rename(newPath);
      }
    } catch (e) {
      print('Error renombrando: $e');
      rethrow;
    }
  }

  static Future<void> deleteFileOrDirectory(String filePath) async {
    try {
      final entity = await FileSystemEntity.type(filePath);

      if (entity == FileSystemEntityType.notFound) {
        throw Exception('El archivo o carpeta no existe');
      }

      if (entity == FileSystemEntityType.file) {
        await File(filePath).delete();
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(filePath).delete(recursive: true);
      }
    } catch (e) {
      print('Error eliminando: $e');
      rethrow;
    }
  }

  static Future<void> copyFileOrDirectory(String sourcePath, String destinationPath) async {
    try {
      final sourceType = await FileSystemEntity.type(sourcePath);

      if (sourceType == FileSystemEntityType.notFound) {
        throw Exception('El origen no existe');
      }

      if (sourceType == FileSystemEntityType.file) {
        final sourceFile = File(sourcePath);
        final fileName = path.basename(sourcePath);
        final destFile = File(path.join(destinationPath, fileName));
        await sourceFile.copy(destFile.path);
      } else if (sourceType == FileSystemEntityType.directory) {
        final sourceDir = Directory(sourcePath);
        final dirName = path.basename(sourcePath);
        final destDir = Directory(path.join(destinationPath, dirName));

        await destDir.create(recursive: true);

        await for (var entity in sourceDir.list(recursive: false)) {
          final name = path.basename(entity.path);
          if (entity is File) {
            await entity.copy(path.join(destDir.path, name));
          } else if (entity is Directory) {
            await copyFileOrDirectory(entity.path, destDir.path);
          }
        }
      }
    } catch (e) {
      print('Error copiando: $e');
      rethrow;
    }
  }

  static Future<void> moveFileOrDirectory(String sourcePath, String destinationPath) async {
    try {
      await copyFileOrDirectory(sourcePath, destinationPath);
      await deleteFileOrDirectory(sourcePath);
    } catch (e) {
      print('Error moviendo: $e');
      rethrow;
    }
  }

  static bool isTextFile(String extension) {
    return AppConstants.textExtensions.contains(extension.toLowerCase());
  }

  static bool isImageFile(String extension) {
    return AppConstants.imageExtensions.contains(extension.toLowerCase());
  }

  static Future<List<FileItem>> searchFiles(String directoryPath, String query) async {
    final results = <FileItem>[];

    try {
      final directory = Directory(directoryPath);

      if (!await directory.exists()) {
        print('Directorio no existe: $directoryPath');
        return results;
      }

      print('Buscando en: $directoryPath con query: "$query"');

      // Buscar en el nivel actual primero
      await _searchInDirectory(directory, query, results, 0, 3);

      print('Resultados encontrados: ${results.length}');

      // Ordenar resultados
      results.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return results;
    } catch (e) {
      print('Error en búsqueda principal: $e');
      return results;
    }
  }

  static Future<void> _searchInDirectory(
      Directory directory,
      String query,
      List<FileItem> results,
      int currentDepth,
      int maxDepth,
      ) async {
    if (currentDepth > maxDepth || results.length >= 500) {
      return;
    }

    try {
      final entities = await directory.list(followLinks: false).toList();

      for (var entity in entities) {
        try {
          final name = path.basename(entity.path);

          // Ignorar archivos ocultos del sistema
          if (name.startsWith('.')) continue;

          // Si query está vacío o el nombre contiene la búsqueda
          final matchesQuery = query.isEmpty ||
              name.toLowerCase().contains(query.toLowerCase());

          if (matchesQuery) {
            final item = FileItem.fromFileSystemEntity(entity);
            results.add(item);
            print('Encontrado: ${item.name}');
          }

          // Si es directorio, buscar recursivamente
          if (entity is Directory) {
            await _searchInDirectory(
              entity,
              query,
              results,
              currentDepth + 1,
              maxDepth,
            );
          }
        } catch (e) {
          // Ignorar archivos inaccesibles
          print('Error accediendo a: ${entity.path} - $e');
          continue;
        }
      }
    } catch (e) {
      print('Error listando directorio ${directory.path}: $e');
    }
  }
}