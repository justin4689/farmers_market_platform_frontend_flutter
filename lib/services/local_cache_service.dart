import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/farmers/domain/farmer_model.dart';
import '../features/products/domain/product_model.dart';

// ── SharedPreferences provider (overridden in main.dart) ──────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('SharedPreferences not initialized'),
);

// ── Cache service ──────────────────────────────────────────────────────────

class LocalCacheService {
  final SharedPreferences _prefs;

  static const _ttlCatalog = Duration(hours: 24);
  static const _ttlFarmer = Duration(minutes: 30);
  static const _ttlSearch = Duration(minutes: 10);

  LocalCacheService(this._prefs);

  // ── Generic helpers ──────────────────────────────────────────────────────

  Future<void> _write(String key, dynamic data) async {
    await _prefs.setString(
      key,
      jsonEncode({
        'data': data,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  Map<String, dynamic>? _read(String key, Duration ttl) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    final age = DateTime.now().millisecondsSinceEpoch -
        (envelope['cachedAt'] as int);
    if (age > ttl.inMilliseconds) return null;
    return envelope;
  }

  // ── Categories ───────────────────────────────────────────────────────────

  Future<void> cacheCategories(List<CategoryModel> categories) =>
      _write('cache_categories', categories.map((c) => c.toJson()).toList());

  List<CategoryModel>? getCachedCategories() {
    final env = _read('cache_categories', _ttlCatalog);
    if (env == null) return null;
    return (env['data'] as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Products ─────────────────────────────────────────────────────────────

  Future<void> cacheProducts(List<ProductModel> products,
      {int? categoryId}) =>
      _write(
        categoryId != null ? 'cache_products_$categoryId' : 'cache_products',
        products.map((p) => p.toJson()).toList(),
      );

  List<ProductModel>? getCachedProducts({int? categoryId}) {
    final key =
        categoryId != null ? 'cache_products_$categoryId' : 'cache_products';
    final env = _read(key, _ttlCatalog);
    if (env == null) return null;
    return (env['data'] as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Farmers ──────────────────────────────────────────────────────────────

  Future<void> cacheFarmer(FarmerModel farmer) =>
      _write('cache_farmer_${farmer.id}', farmer.toJson());

  FarmerModel? getCachedFarmer(int id) {
    final env = _read('cache_farmer_$id', _ttlFarmer);
    if (env == null) return null;
    return FarmerModel.fromJson(env['data'] as Map<String, dynamic>);
  }

  Future<void> cacheSearch(String query, List<FarmerModel> farmers) =>
      _write(
        'cache_search_${query.trim().toLowerCase()}',
        farmers.map((f) => f.toJson()).toList(),
      );

  List<FarmerModel>? getCachedSearch(String query) {
    final env = _read(
      'cache_search_${query.trim().toLowerCase()}',
      _ttlSearch,
    );
    if (env == null) return null;
    return (env['data'] as List)
        .map((e) => FarmerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final localCacheServiceProvider = Provider<LocalCacheService>(
  (ref) => LocalCacheService(ref.read(sharedPreferencesProvider)),
);
