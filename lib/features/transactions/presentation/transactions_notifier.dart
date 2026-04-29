import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/auth_notifier.dart';
import '../data/transactions_repository.dart';
import '../domain/transaction_model.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(ref.read(apiServiceProvider)),
);

// ── State ──────────────────────────────────────────────────────────────────

enum TransactionStatus { initial, loading, success, error }

class TransactionState {
  final TransactionStatus status;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.errorMessage,
  });
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
    required String paymentMethod,
    double? interestRate,
    required List<CheckoutItem> items,
  }) async {
    state = const TransactionState(status: TransactionStatus.loading);
    try {
      await _repo.checkout(
        farmerId: farmerId,
        paymentMethod: paymentMethod,
        interestRate: interestRate,
        items: items,
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

  void reset() =>
      state = const TransactionState(status: TransactionStatus.initial);
}
