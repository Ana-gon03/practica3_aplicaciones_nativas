import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/themes/theme_provider.dart';
import 'screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Gestor de Archivos',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          darkTheme: themeProvider.currentDarkTheme,
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}