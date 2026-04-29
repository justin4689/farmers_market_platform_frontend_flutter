class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'] as List<dynamic>? ?? [];
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parent_id'] as int?,
      children: rawChildren
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductCategoryRef {
  final int id;
  final String name;

  const ProductCategoryRef({required this.id, required this.name});

  factory ProductCategoryRef.fromJson(Map<String, dynamic> json) {
    return ProductCategoryRef(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final double priceFcfa;
  final String? description;
  final ProductCategoryRef? category;
  final String createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.priceFcfa,
    this.description,
    this.category,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as Map<String, dynamic>?;
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      priceFcfa: (json['price_fcfa'] as num).toDouble(),
      description: json['description'] as String?,
      category: cat != null ? ProductCategoryRef.fromJson(cat) : null,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
