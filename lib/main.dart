import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'config/themes/theme_provider.dart';
import 'providers/file_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/recent_files_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(prefs)),
        ChangeNotifierProvider(create: (_) => RecentFilesProvider(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}