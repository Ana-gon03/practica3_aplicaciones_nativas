import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<List<Directory>> getStorageDirectories() async {
    List<Directory> directories = [];

    try {
      // 1. Almacenamiento interno principal (más común)
      final commonPaths = [
        '/storage/emulated/0',
        '/sdcard',
      ];

      for (var path in commonPaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          if (!directories.any((d) => d.path == path)) {
            directories.add(dir);
            print('Almacenamiento encontrado: $path');
          }
          break; // Solo agregar uno de estos
        }
      }

      // 2. Directorio externo de almacenamiento (SDCard externa si existe)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Verificar si hay SD card externa
        final externalPath = externalDir.path;

        // Buscar almacenamiento externo real
        if (externalPath.contains('Android')) {
          // Extraer ruta base
          final parts = externalPath.split('/Android')[0];

          // Buscar otras ubicaciones de almacenamiento
          final storageDir = Directory('/storage');
          if (await storageDir.exists()) {
            await for (var entity in storageDir.list()) {
              if (entity is Directory) {
                final name = entity.path.split('/').last;
                // Ignorar emulated y self
                if (name != 'emulated' && name != 'self' && !name.startsWith('.')) {
                  // Verificar si es accesible
                  try {
                    await entity.list().first;
                    if (!directories.any((d) => d.path == entity.path)) {
                      directories.add(entity);
                      print('SD Externa encontrada: ${entity.path}');
                    }
                  } catch (e) {
                    // No accesible, ignorar
                  }
                }
              }
            }
          }
        }
      }

      // 3. Directorio de documentos de la app
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        if (!directories.any((d) => d.path == appDocDir.path)) {
          directories.add(appDocDir);
          print('Documentos de app: ${appDocDir.path}');
        }
      } catch (e) {
        print('Error obteniendo documentos de app: $e');
      }

      // 4. Directorio de la aplicación en almacenamiento externo
      try {
        final appExternal = await getExternalStorageDirectory();
        if (appExternal != null && !directories.any((d) => d.path == appExternal.path)) {
          directories.add(appExternal);
          print('Almacenamiento de app: ${appExternal.path}');
        }
      } catch (e) {
        print('Error obteniendo almacenamiento externo: $e');
      }

      print('Total de ubicaciones encontradas: ${directories.length}');
    } catch (e) {
      print('Error obteniendo directorios de almacenamiento: $e');
    }

    return directories;
  }

  static Future<Directory> getDefaultDirectory() async {
    try {
      // Intentar obtener el almacenamiento interno principal
      final commonPaths = [
        '/storage/emulated/0',
        '/sdcard',
      ];

      for (var path in commonPaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          print('Directorio por defecto: $path');
          return dir;
        }
      }

      // Si no se encuentra, usar directorio de documentos de la app
      final appDocDir = await getApplicationDocumentsDirectory();
      print('Usando directorio de app: ${appDocDir.path}');
      return appDocDir;
    } catch (e) {
      print('Error obteniendo directorio por defecto: $e');
      return await getApplicationDocumentsDirectory();
    }
  }

  static String getStorageName(String path) {
    if (path.contains('/storage/emulated/0') || path.contains('/sdcard')) {
      return 'Almacenamiento Interno';
    } else if (path.startsWith('/storage/') &&
        !path.contains('emulated') &&
        !path.contains('self') &&
        path.split('/').length <= 3) {
      // SD card externa (ej: /storage/XXXX-XXXX)
      return 'Tarjeta SD Externa';
    } else if (path.contains('Android/data')) {
      return 'Datos de la Aplicación';
    } else if (path.contains('app_flutter')) {
      return 'Documentos de la App';
    } else {
      return 'Almacenamiento';
    }
  }

  static String getStorageSubtitle(String path) {
    if (path.contains('/storage/emulated/0')) {
      return 'Memoria interna del dispositivo';
    } else if (path.contains('/sdcard')) {
      return 'Acceso directo a almacenamiento';
    } else if (path.startsWith('/storage/') &&
        !path.contains('emulated') &&
        path.split('/').length <= 3) {
      return 'Tarjeta de memoria externa';
    } else if (path.contains('Android/data')) {
      return 'Espacio privado de la aplicación';
    } else {
      return path;
    }
  }

  static Future<String> getReadableStoragePath(String path) async {
    try {
      if (path.startsWith('/storage/emulated/0')) {
        return path.replaceFirst('/storage/emulated/0', 'Almacenamiento interno');
      } else if (path.startsWith('/sdcard')) {
        return path.replaceFirst('/sdcard', 'Almacenamiento interno');
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      if (path.startsWith(appDocDir.path)) {
        return path.replaceFirst(appDocDir.path, 'Documentos de la app');
      }

      return path;
    } catch (e) {
      return path;
    }
  }
}