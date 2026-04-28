import '../../../services/api_service.dart';
import '../../../core/constants/api_urls.dart';
import '../domain/farmer_model.dart';

class FarmersRepository {
  final ApiService _api;

  FarmersRepository(this._api);

  Future<List<FarmerModel>> search(String query) async {
    try {
      final response = await _api.get(
        ApiUrls.farmersSearch,
        queryParameters: {'q': query},
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => FarmerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _api.handleError(e);
    }
  }

  Future<FarmerModel> getById(int id) async {
    try {
      final response = await _api.get(ApiUrls.farmerById(id));
      final data = response.data as Map<String, dynamic>;
      return FarmerModel.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _api.handleError(e);
    }
  }

  Future<FarmerModel> create({
    required String name,
    required String phone,
    String? village,
  }) async {
    try {
      final response = await _api.post(
        ApiUrls.createFarmer,
        data: {
          'name': name,
          'phone': phone,
          if (village != null && village.isNotEmpty) 'village': village,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return FarmerModel.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _api.handleError(e);
    }
  }

  Future<List<DebtModel>> getDebts(int farmerId) async {
    try {
      final response = await _api.get(ApiUrls.farmerDebts(farmerId));
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => DebtModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}
