import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_provider.dart';

class BreadcrumbWidget extends StatelessWidget {
  final String currentPath;

  const BreadcrumbWidget({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final parts = _getPathParts(currentPath);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < parts.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              _buildBreadcrumbItem(
                context,
                parts[i]['name'] as String,
                parts[i]['path'] as String,
                i == parts.length - 1,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbItem(
      BuildContext context,
      String name,
      String path,
      bool isLast,
      ) {
    final fileProvider = Provider.of<FileProvider>(context, listen: false);

    return InkWell(
      onTap: isLast
          ? null
          : () => fileProvider.loadDirectory(path),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isLast
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (name == 'Almacenamiento')
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.phone_android,
                  size: 16,
                  color: isLast
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            Text(
              name,
              style: TextStyle(
                color: isLast
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getPathParts(String path) {
    final parts = <Map<String, String>>[];

    // Manejar rutas comunes de Android
    if (path.startsWith('/storage/emulated/0')) {
      parts.add({'name': 'Almacenamiento', 'path': '/storage/emulated/0'});
      final remaining = path.replaceFirst('/storage/emulated/0', '');
      if (remaining.isNotEmpty) {
        _addRemainingParts(parts, remaining, '/storage/emulated/0');
      }
    } else if (path.startsWith('/sdcard')) {
      parts.add({'name': 'Almacenamiento', 'path': '/sdcard'});
      final remaining = path.replaceFirst('/sdcard', '');
      if (remaining.isNotEmpty) {
        _addRemainingParts(parts, remaining, '/sdcard');
      }
    } else {
      // Para otras rutas, dividir normalmente
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      String currentPath = '';
      for (final segment in segments) {
        currentPath += '/$segment';
        parts.add({'name': segment, 'path': currentPath});
      }
    }

    return parts;
  }

  void _addRemainingParts(List<Map<String, String>> parts, String remaining, String basePath) {
    final segments = remaining.split('/').where((s) => s.isNotEmpty).toList();
    String currentPath = basePath;
    for (final segment in segments) {
      currentPath += '/$segment';
      parts.add({'name': segment, 'path': currentPath});
    }
  }
}