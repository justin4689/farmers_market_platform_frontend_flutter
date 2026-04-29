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
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? identifier,
    double? creditLimitFcfa,
  }) async {
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
      return FarmerModel.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}
