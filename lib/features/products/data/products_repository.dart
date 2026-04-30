import '../../../core/constants/api_urls.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../services/api_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/local_cache_service.dart';
import '../domain/product_model.dart';

class ProductsRepository {
  final ApiService _api;
  final LocalCacheService _cache;
  final ConnectivityService _connectivity;

  ProductsRepository(this._api, this._cache, this._connectivity);

  Future<List<CategoryModel>> getCategories() async {
    if (await _connectivity.isOnline()) {
      try {
        final response = await _api.get(ApiUrls.categories);
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        final categories = list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _cache.cacheCategories(categories);
        return categories;
      } catch (e) {
        final cached = _cache.getCachedCategories();
        if (cached != null) return cached;
        throw _api.handleError(e);
      }
    } else {
      final cached = _cache.getCachedCategories();
      if (cached != null) return cached;
      throw const ApiException(statusCode: 0, message: 'Offline – no cached categories');
    }
  }

  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    if (await _connectivity.isOnline()) {
      try {
        final response = await _api.get(
          ApiUrls.products,
          queryParameters:
              categoryId != null ? {'category_id': categoryId} : null,
        );
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        final products = list
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _cache.cacheProducts(products, categoryId: categoryId);
        return products;
      } catch (e) {
        final cached = _cache.getCachedProducts(categoryId: categoryId);
        if (cached != null) return cached;
        throw _api.handleError(e);
      }
    } else {
      final cached = _cache.getCachedProducts(categoryId: categoryId);
      if (cached != null) return cached;
      throw const ApiException(statusCode: 0, message: 'Offline – no cached products');
    }
  }
}
