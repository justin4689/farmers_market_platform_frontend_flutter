import '../../../services/api_service.dart';
import '../../../core/constants/api_urls.dart';
import '../../../core/exceptions/api_exception.dart';
import '../domain/transaction_model.dart';

class TransactionsRepository {
  final ApiService _api;

  TransactionsRepository(this._api);

  Future<TransactionModel> checkout({
    required int farmerId,
    required String paymentMethod,
    double? interestRate,
    required List<CheckoutItem> items,
  }) async {
    try {
      final body = <String, dynamic>{
        'farmer_id': farmerId,
        'payment_method': paymentMethod,
        'items': items.map((i) => i.toJson()).toList(),
      };
      if (interestRate != null) body['interest_rate'] = interestRate;
      final response = await _api.post(
        ApiUrls.createTransaction,
        data: body,
      );
      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const ApiException(
          statusCode: 0,
          message: 'Réponse inattendue du serveur',
        );
      }
      // Accepte {"data": {...}} ou directement {...}
      final json = responseData['data'] is Map<String, dynamic>
          ? responseData['data'] as Map<String, dynamic>
          : responseData;
      return TransactionModel.fromJson(json);
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}
