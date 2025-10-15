import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/themes/theme_provider.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import 'file_explorer_screen.dart';
import 'favorites_screen.dart';
import 'recent_files_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _permissionGranted = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _checkingPermission = true);
    final granted = await PermissionService.checkStoragePermission();
    setState(() {
      _permissionGranted = granted;
      _checkingPermission = false;
    });

    if (!granted) {
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await PermissionService.requestStoragePermission();
    setState(() => _permissionGranted = granted);
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return const FileExplorerScreen();
      case 1:
        return const FavoritesScreen();
      case 2:
        return const RecentFilesScreen();
      default:
        return const FileExplorerScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text('Verificando permisos...'),
            ],
          ),
        ),
      );
    }

    if (!_permissionGranted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gestor de Archivos'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_off,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Permisos de almacenamiento requeridos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Esta aplicación necesita acceso al almacenamiento para gestionar tus archivos.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _requestPermissions,
                  icon: const Icon(Icons.check),
                  label: const Text('Conceder permisos'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => PermissionService.openAppSettings(),
                  child: const Text('Abrir configuración'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'theme') {
                _showThemeDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.palette),
                    SizedBox(width: 12),
                    Text('Cambiar tema'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _getScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Explorador',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Recientes',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Explorador de Archivos';
      case 1:
        return 'Favoritos';
      case 2:
        return 'Archivos Recientes';
      default:
        return 'Gestor de Archivos';
    }
  }

  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Esquema de color:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<AppThemeType>(
              title: const Text('IPN Guinda'),
              value: AppThemeType.guinda,
              groupValue: themeProvider.themeType,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeType(value);
                }
              },
            ),
            RadioListTile<AppThemeType>(
              title: const Text('ESCOM Azul'),
              value: AppThemeType.azul,
              groupValue: themeProvider.themeType,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeType(value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Modo:', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Oscuro'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sistema'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}