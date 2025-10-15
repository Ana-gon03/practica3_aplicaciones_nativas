import 'dart:io';
import 'package:path/path.dart' as path;

class FileItem {
  final String name;
  final String fullPath;
  final bool isDirectory;
  final int size;
  final DateTime lastModified;
  final String extension;

  FileItem({
    required this.name,
    required this.fullPath,
    required this.isDirectory,
    required this.size,
    required this.lastModified,
    required this.extension,
  });

  factory FileItem.fromFileSystemEntity(FileSystemEntity entity) {
    final stat = entity.statSync();
    final isDir = entity is Directory;
    final fileName = path.basename(entity.path);
    final ext = isDir ? '' : path.extension(entity.path);

    return FileItem(
      name: fileName,
      fullPath: entity.path,
      isDirectory: isDir,
      size: stat.size,
      lastModified: stat.modified,
      extension: ext,
    );
  }

  String get formattedSize {
    if (isDirectory) return '';

    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(lastModified);

    if (difference.inDays == 0) {
      return 'Hoy ${lastModified.hour.toString().padLeft(2, '0')}:${lastModified.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${lastModified.day}/${lastModified.month}/${lastModified.year}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fullPath': fullPath,
      'isDirectory': isDirectory,
      'size': size,
      'lastModified': lastModified.toIso8601String(),
      'extension': extension,
    };
  }

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'],
      fullPath: json['fullPath'],
      isDirectory: json['isDirectory'],
      size: json['size'],
      lastModified: DateTime.parse(json['lastModified']),
      extension: json['extension'],
    );
  }
}