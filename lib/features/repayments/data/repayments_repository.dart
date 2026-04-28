import '../../../services/api_service.dart';
import '../../../core/constants/api_urls.dart';
import '../domain/repayment_model.dart';

class RepaymentsRepository {
  final ApiService _api;

  RepaymentsRepository(this._api);

  Future<RepaymentModel> create({
    required int farmerId,
    required double weightKg,
    required double amountFcfa,
  }) async {
    try {
      final response = await _api.post(
        ApiUrls.createRepayment,
        data: {
          'farmer_id': farmerId,
          'weight_kg': weightKg,
          'amount_fcfa': amountFcfa,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return RepaymentModel.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}
