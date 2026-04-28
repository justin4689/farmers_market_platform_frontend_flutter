class CategoryModel {
  final int id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final double pricePerKg;
  final int? categoryId;
  final String? categoryName;

  const ProductModel({
    required this.id,
    required this.name,
    required this.pricePerKg,
    this.categoryId,
    this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      categoryId: category?['id'] as int?,
      categoryName: category?['name'] as String?,
    );
  }
}
