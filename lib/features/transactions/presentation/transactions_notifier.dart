import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transactions_repository.dart';
import '../domain/transaction_model.dart';

export '../data/transactions_repository.dart' show transactionsRepositoryProvider;

// ── State ──────────────────────────────────────────────────────────────────

enum TransactionStatus { initial, loading, success, queued, error }

class TransactionState {
  final TransactionStatus status;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.errorMessage,
  });

  bool get isOfflineQueued => status == TransactionStatus.queued;
}

// ── Notifier ───────────────────────────────────────────────────────────────

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref.read(transactionsRepositoryProvider));
});

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier(this._repo) : super(const TransactionState());

  final TransactionsRepository _repo;

  Future<bool> checkout({
    required int farmerId,
    required String farmerName,
    required String paymentMethod,
    double? interestRate,
    required List<CheckoutItem> items,
  }) async {
    state = const TransactionState(status: TransactionStatus.loading);
    try {
      final result = await _repo.checkout(
        farmerId: farmerId,
        farmerName: farmerName,
        paymentMethod: paymentMethod,
        interestRate: interestRate,
        items: items,
      );
      state = TransactionState(
        status: result.queued
            ? TransactionStatus.queued
            : TransactionStatus.success,
      );
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
