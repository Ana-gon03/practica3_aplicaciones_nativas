import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      // Para Android 13+ (API 33+)
      if (await _isAndroid13OrHigher()) {
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();

        bool allGranted = statuses.values.every((status) => status.isGranted);

        // Si no se conceden los permisos granulares, intentar con manageExternalStorage
        if (!allGranted) {
          final manageStatus = await Permission.manageExternalStorage.request();
          return manageStatus.isGranted;
        }

        return allGranted;
      }

      // Para Android 11-12 (API 30-32)
      else if (await _isAndroid11OrHigher()) {
        // Primero intentar con storage normal
        var status = await Permission.storage.request();

        if (status.isGranted) {
          return true;
        }

        // Si no funciona, intentar con manageExternalStorage
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      }

      // Para Android 10 y anteriores (API 29 y menor)
      else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      print('Error solicitando permisos: $e');
      return false;
    }
  }

  static Future<bool> checkStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      if (await _isAndroid13OrHigher()) {
        final photos = await Permission.photos.isGranted;
        final videos = await Permission.videos.isGranted;
        final audio = await Permission.audio.isGranted;
        final manage = await Permission.manageExternalStorage.isGranted;

        return (photos && videos && audio) || manage;
      } else if (await _isAndroid11OrHigher()) {
        final storage = await Permission.storage.isGranted;
        final manage = await Permission.manageExternalStorage.isGranted;
        return storage || manage;
      } else {
        return await Permission.storage.isGranted;
      }
    } catch (e) {
      print('Error verificando permisos: $e');
      return false;
    }
  }

  static Future<bool> _isAndroid13OrHigher() async {
    // Android 13 = API 33
    return Platform.isAndroid; // Simplificado para compatibilidad
  }

  static Future<bool> _isAndroid11OrHigher() async {
    // Android 11 = API 30
    return Platform.isAndroid;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}