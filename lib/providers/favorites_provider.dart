import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';
import '../config/constants/app_constants.dart';

class FavoritesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<FavoriteItem> _favorites = [];

  FavoritesProvider(this._prefs) {
    _loadFavorites();
  }

  List<FavoriteItem> get favorites => _favorites;

  void _loadFavorites() {
    try {
      final favoritesJson = _prefs.getString(AppConstants.keyFavorites);
      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((item) => FavoriteItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error cargando favoritos: $e');
      _favorites = [];
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final favoritesJson = json.encode(_favorites.map((f) => f.toJson()).toList());
      await _prefs.setString(AppConstants.keyFavorites, favoritesJson);
    } catch (e) {
      print('Error guardando favoritos: $e');
    }
  }

  bool isFavorite(String path) {
    return _favorites.any((f) => f.path == path);
  }

  Future<void> addFavorite(String path, String name, bool isDirectory) async {
    if (!isFavorite(path)) {
      _favorites.add(FavoriteItem(
        path: path,
        name: name,
        isDirectory: isDirectory,
        addedAt: DateTime.now(),
      ));
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String path) async {
    _favorites.removeWhere((f) => f.path == path);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(String path, String name, bool isDirectory) async {
    if (isFavorite(path)) {
      await removeFavorite(path);
    } else {
      await addFavorite(path, name, isDirectory);
    }
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();
  }
}