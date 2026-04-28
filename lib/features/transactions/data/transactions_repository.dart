import '../../../services/api_service.dart';
import '../../../core/constants/api_urls.dart';
import '../domain/transaction_model.dart';

class TransactionsRepository {
  final ApiService _api;

  TransactionsRepository(this._api);

  Future<TransactionModel> create({
    required int farmerId,
    required int productId,
    required double quantityKg,
    required String paymentMethod,
  }) async {
    try {
      final response = await _api.post(
        ApiUrls.createTransaction,
        data: {
          'farmer_id': farmerId,
          'product_id': productId,
          'quantity_kg': quantityKg,
          'payment_method': paymentMethod,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return TransactionModel.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}
