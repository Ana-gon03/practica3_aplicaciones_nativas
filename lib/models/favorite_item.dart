class FavoriteItem {
  final String path;
  final String name;
  final bool isDirectory;
  final DateTime addedAt;

  FavoriteItem({
    required this.path,
    required this.name,
    required this.isDirectory,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'isDirectory': isDirectory,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      path: json['path'],
      name: json['name'],
      isDirectory: json['isDirectory'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}