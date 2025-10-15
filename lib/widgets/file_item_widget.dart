import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../config/constants/app_constants.dart';

class FileItemWidget extends StatelessWidget {
  final FileItem fileItem;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isGridView;

  const FileItemWidget({
    super.key,
    required this.fileItem,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridItem(context);
    } else {
      return _buildListItem(context);
    }
  }

  Widget _buildListItem(BuildContext context) {
    return ListTile(
      selected: isSelected,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fileItem.isDirectory ? '📁' : AppConstants.getFileIcon(fileItem.extension),
            style: const TextStyle(fontSize: 32),
          ),
        ],
      ),
      title: Text(
        fileItem.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: fileItem.isDirectory
          ? const Text('Carpeta')
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fileItem.formattedSize),
          Text(
            fileItem.formattedDate,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _buildGridItem(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fileItem.isDirectory ? '📁' : AppConstants.getFileIcon(fileItem.extension),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                fileItem.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              if (!fileItem.isDirectory) ...[
                const SizedBox(height: 4),
                Text(
                  fileItem.formattedSize,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}