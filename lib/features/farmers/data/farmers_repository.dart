import '../../../core/constants/api_urls.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../services/api_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/local_cache_service.dart';
import '../domain/farmer_model.dart';

class FarmersRepository {
  final ApiService _api;
  final LocalCacheService _cache;
  final ConnectivityService _connectivity;

  FarmersRepository(this._api, this._cache, this._connectivity);

  Future<List<FarmerModel>> search(String query) async {
    if (await _connectivity.isOnline()) {
      try {
        final response = await _api.get(
          ApiUrls.farmersSearch,
          queryParameters: {'q': query},
        );
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        final farmers = list
            .map((e) => FarmerModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _cache.cacheSearch(query, farmers);
        return farmers;
      } catch (e) {
        final cached = _cache.getCachedSearch(query);
        if (cached != null) return cached;
        throw _api.handleError(e);
      }
    } else {
      final cached = _cache.getCachedSearch(query);
      if (cached != null) return cached;
      throw const ApiException(statusCode: 0, message: 'Offline – no cached results for this search');
    }
  }

  Future<FarmerModel> getById(int id) async {
    if (await _connectivity.isOnline()) {
      try {
        final response = await _api.get(ApiUrls.farmerById(id));
        final data = response.data as Map<String, dynamic>;
        final farmer =
            FarmerModel.fromJson(data['data'] as Map<String, dynamic>);
        await _cache.cacheFarmer(farmer);
        return farmer;
      } catch (e) {
        final cached = _cache.getCachedFarmer(id);
        if (cached != null) return cached;
        throw _api.handleError(e);
      }
    } else {
      final cached = _cache.getCachedFarmer(id);
      if (cached != null) return cached;
      throw const ApiException(statusCode: 0, message: 'Offline – farmer not cached');
    }
  }

  Future<FarmerModel> create({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? identifier,
    double? creditLimitFcfa,
  }) async {
    if (!await _connectivity.isOnline()) {
      throw const ApiException(
          statusCode: 0, message: 'Cannot create farmer while offline');
    }
    try {
      final response = await _api.post(
        ApiUrls.createFarmer,
        data: {
          'firstname': firstname,
          'lastname': lastname,
          'phone_number': phoneNumber,
          'identifier': identifier?.isNotEmpty == true ? identifier : null,
          'credit_limit_fcfa': creditLimitFcfa,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final farmer = FarmerModel.fromJson(data['data'] as Map<String, dynamic>);
      await _cache.cacheFarmer(farmer);
      return farmer;
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}
