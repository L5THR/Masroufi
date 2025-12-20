class Category {
  final int id;
  final String name;
  final String? icon;

  Category({required this.id, required this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon};
  }
}
