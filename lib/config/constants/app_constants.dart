class AppConstants {
  // Tipos de archivo soportados para visualización
  static const List<String> textExtensions = [
    '.txt', '.md', '.log', '.json', '.xml', '.csv', '.dart', '.java', '.kt',
    '.html', '.css', '.js', '.py', '.c', '.cpp', '.h', '.sh', '.bat'
  ];

  static const List<String> imageExtensions = [
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'
  ];

  static const List<String> videoExtensions = [
    '.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm'
  ];

  static const List<String> audioExtensions = [
    '.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a', '.wma'
  ];

  static const List<String> documentExtensions = [
    '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx'
  ];

  static const List<String> compressedExtensions = [
    '.zip', '.rar', '.7z', '.tar', '.gz', '.bz2'
  ];

  // Límites
  static const int maxRecentFiles = 20;
  static const int maxTextFileSize = 10 * 1024 * 1024; // 10 MB

  // Keys de SharedPreferences
  static const String keyFavorites = 'favorites';
  static const String keyRecentFiles = 'recent_files';
  static const String keyThemeType = 'theme_type';
  static const String keyThemeMode = 'theme_mode';
  static const String keyViewMode = 'view_mode';

  // Iconos por tipo de archivo
  static String getFileIcon(String extension) {
    if (textExtensions.contains(extension.toLowerCase())) {
      return '📄';
    } else if (imageExtensions.contains(extension.toLowerCase())) {
      return '🖼️';
    } else if (videoExtensions.contains(extension.toLowerCase())) {
      return '🎬';
    } else if (audioExtensions.contains(extension.toLowerCase())) {
      return '🎵';
    } else if (documentExtensions.contains(extension.toLowerCase())) {
      return '📃';
    } else if (compressedExtensions.contains(extension.toLowerCase())) {
      return '📦';
    } else {
      return '📎';
    }
  }
}