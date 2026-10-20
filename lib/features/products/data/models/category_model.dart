import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.slug,
    required super.name,
  });

  factory CategoryModel.fromJson(dynamic json) {
    if (json is String) {
      final formattedName = json.isNotEmpty
          ? json[0].toUpperCase() + json.substring(1).replaceAll('-', ' ')
          : json;
      return CategoryModel(
        slug: json,
        name: formattedName,
      );
    }

    final map = json as Map<String, dynamic>;
    final slug = map['slug'] as String? ?? '';
    final rawName = map['name'] as String?;
    final name = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : (slug.isNotEmpty ? slug[0].toUpperCase() + slug.substring(1).replaceAll('-', ' ') : 'General');

    return CategoryModel(
      slug: slug,
      name: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
    };
  }
}
