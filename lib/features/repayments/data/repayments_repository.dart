import '../../../services/api_service.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/constants/api_urls.dart';
import '../domain/repayment_model.dart';

class RepaymentsRepository {
  final ApiService _api;

  RepaymentsRepository(this._api);

  Future<List<DebtSummaryModel>> getFarmerDebts(int farmerId) async {
    try {
      final response = await _api.get(ApiUrls.farmerDebts(farmerId));
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => DebtSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _api.handleError(e);
    }
  }

  Future<RepaymentModel> createRepayment({
    required int farmerId,
    required double kgReceived,
    required double commodityRateFcfa,
  }) async {
    try {
      final response = await _api.post(
        ApiUrls.createRepayment,
        data: {
          'farmer_id': farmerId,
          'kg_received': kgReceived,
          'commodity_rate_fcfa': commodityRateFcfa,
        },
      );
      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const ApiException(
          statusCode: 0,
          message: 'Unexpected server response',
        );
      }
      final json = responseData['data'] is Map<String, dynamic>
          ? responseData['data'] as Map<String, dynamic>
          : responseData;
      return RepaymentModel.fromJson(json);
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}
