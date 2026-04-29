import '../../../services/api_service.dart';
import '../../../core/constants/api_urls.dart';
import '../domain/product_model.dart';

class ProductsRepository {
  final ApiService _api;

  ProductsRepository(this._api);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _api.get(ApiUrls.categories);
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _api.handleError(e);
    }
  }

  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    try {
      final response = await _api.get(
        ApiUrls.products,
        queryParameters:
            categoryId != null ? {'category_id': categoryId} : null,
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}
