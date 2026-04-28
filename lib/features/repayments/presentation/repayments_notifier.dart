import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/auth_notifier.dart';
import '../data/repayments_repository.dart';

final repaymentsRepositoryProvider = Provider<RepaymentsRepository>(
  (ref) => RepaymentsRepository(ref.read(apiServiceProvider)),
);

enum RepaymentStatus { initial, loading, success, error }

class RepaymentState {
  final RepaymentStatus status;
  final String? errorMessage;

  const RepaymentState({
    this.status = RepaymentStatus.initial,
    this.errorMessage,
  });
}

final repaymentNotifierProvider =
    StateNotifierProvider<RepaymentNotifier, RepaymentState>((ref) {
  return RepaymentNotifier(ref.read(repaymentsRepositoryProvider));
});

class RepaymentNotifier extends StateNotifier<RepaymentState> {
  RepaymentNotifier(this._repo) : super(const RepaymentState());

  final RepaymentsRepository _repo;

  Future<bool> createRepayment({
    required int farmerId,
    required double weightKg,
    required double amountFcfa,
  }) async {
    state = const RepaymentState(status: RepaymentStatus.loading);
    try {
      await _repo.create(
        farmerId: farmerId,
        weightKg: weightKg,
        amountFcfa: amountFcfa,
      );
      state = const RepaymentState(status: RepaymentStatus.success);
      return true;
    } catch (e) {
      state = RepaymentState(
        status: RepaymentStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const RepaymentState();
}
