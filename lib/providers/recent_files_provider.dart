import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/file_item.dart';
import '../config/constants/app_constants.dart';

class RecentFilesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<FileItem> _recentFiles = [];

  RecentFilesProvider(this._prefs) {
    _loadRecentFiles();
  }

  List<FileItem> get recentFiles => _recentFiles;

  void _loadRecentFiles() {
    try {
      final recentJson = _prefs.getString(AppConstants.keyRecentFiles);
      if (recentJson != null) {
        final List<dynamic> decoded = json.decode(recentJson);
        _recentFiles = decoded.map((item) => FileItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error cargando archivos recientes: $e');
      _recentFiles = [];
    }
  }

  Future<void> _saveRecentFiles() async {
    try {
      final recentJson = json.encode(_recentFiles.map((f) => f.toJson()).toList());
      await _prefs.setString(AppConstants.keyRecentFiles, recentJson);
    } catch (e) {
      print('Error guardando archivos recientes: $e');
    }
  }

  Future<void> addRecentFile(FileItem file) async {
    // Remover si ya existe
    _recentFiles.removeWhere((f) => f.fullPath == file.fullPath);

    // Agregar al inicio
    _recentFiles.insert(0, file);

    // Limitar el número de archivos recientes
    if (_recentFiles.length > AppConstants.maxRecentFiles) {
      _recentFiles = _recentFiles.sublist(0, AppConstants.maxRecentFiles);
    }

    await _saveRecentFiles();
    notifyListeners();
  }

  Future<void> removeRecentFile(String path) async {
    _recentFiles.removeWhere((f) => f.fullPath == path);
    await _saveRecentFiles();
    notifyListeners();
  }

  Future<void> clearRecentFiles() async {
    _recentFiles.clear();
    await _saveRecentFiles();
    notifyListeners();
  }
}