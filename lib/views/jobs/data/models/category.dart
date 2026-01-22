class Category {
  final int id;
  final String name;
  final String? icon;
  final List<String> skills;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.skills = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'skills': skills,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    List<String>? skills,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      skills: skills ?? this.skills,
    );
  }
}

/// Request model for creating/updating a category (Admin)
class CategoryRequest {
  final String name;
  final String? icon;
  final List<String> skills;

  CategoryRequest({
    required this.name,
    this.icon,
    this.skills = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (icon != null) 'icon': icon,
      'skills': skills,
    };
  }
}
