import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/auth_notifier.dart';
import '../data/transactions_repository.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(ref.read(apiServiceProvider)),
);

enum TransactionStatus { initial, loading, success, error }

class TransactionState {
  final TransactionStatus status;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.errorMessage,
  });
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref.read(transactionsRepositoryProvider));
});

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier(this._repo) : super(const TransactionState());

  final TransactionsRepository _repo;

  Future<bool> createTransaction({
    required int farmerId,
    required int productId,
    required double quantityKg,
    required String paymentMethod,
  }) async {
    state = const TransactionState(status: TransactionStatus.loading);
    try {
      await _repo.create(
        farmerId: farmerId,
        productId: productId,
        quantityKg: quantityKg,
        paymentMethod: paymentMethod,
      );
      state = const TransactionState(status: TransactionStatus.success);
      return true;
    } catch (e) {
      state = TransactionState(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const TransactionState();
}
