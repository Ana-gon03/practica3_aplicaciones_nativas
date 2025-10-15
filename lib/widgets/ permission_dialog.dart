import 'package:flutter/material.dart';
import '../services/permission_service.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.folder_outlined,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('Permiso de almacenamiento'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Esta aplicación necesita acceso a tu almacenamiento para:',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          _PermissionItem(
            icon: Icons.folder,
            text: 'Explorar carpetas y archivos',
          ),
          _PermissionItem(
            icon: Icons.visibility,
            text: 'Ver contenido de archivos',
          ),
          _PermissionItem(
            icon: Icons.edit,
            text: 'Crear, modificar y eliminar archivos',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            final granted = await PermissionService.requestStoragePermission();
            if (context.mounted) {
              Navigator.of(context).pop(granted);
            }
          },
          child: const Text('Conceder permiso'),
        ),
      ],
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PermissionItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}