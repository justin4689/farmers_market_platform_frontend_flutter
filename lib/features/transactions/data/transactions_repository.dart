import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_urls.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../features/auth/presentation/auth_notifier.dart';
import '../../../services/api_service.dart';
import '../../../services/connectivity_service.dart';
import '../domain/pending_transaction.dart';
import '../domain/transaction_model.dart';
import 'offline_queue.dart';

class TransactionsRepository {
  final ApiService _api;
  final ConnectivityService _connectivity;
  final OfflineQueue _queue;

  TransactionsRepository(this._api, this._connectivity, this._queue);

  // Called by the UI — queues offline automatically
  Future<({bool success, bool queued})> checkout({
    required int farmerId,
    required String farmerName,
    required String paymentMethod,
    double? interestRate,
    required List<CheckoutItem> items,
  }) async {
    if (!await _connectivity.isOnline()) {
      final pending = PendingTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmerId: farmerId,
        farmerName: farmerName,
        paymentMethod: paymentMethod,
        interestRate: interestRate,
        items: items.map((i) => i.toJson()).toList(),
        createdAt: DateTime.now(),
      );
      await _queue.enqueue(pending);
      return (success: true, queued: true);
    }
    await checkoutOnline(
      farmerId: farmerId,
      paymentMethod: paymentMethod,
      interestRate: interestRate,
      items: items,
    );
    return (success: true, queued: false);
  }

  // Called directly by SyncNotifier — always hits the API
  Future<TransactionModel> checkoutOnline({
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

      final response = await _api.post(ApiUrls.createTransaction, data: body);
      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const ApiException(statusCode: 0, message: 'Unexpected server response');
      }
      final json = responseData['data'] is Map<String, dynamic>
          ? responseData['data'] as Map<String, dynamic>
          : responseData;
      return TransactionModel.fromJson(json);
    } catch (e) {
      throw _api.handleError(e);
    }
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(
    ref.read(apiServiceProvider),
    ref.read(connectivityServiceProvider),
    ref.read(offlineQueueProvider),
  );
});
