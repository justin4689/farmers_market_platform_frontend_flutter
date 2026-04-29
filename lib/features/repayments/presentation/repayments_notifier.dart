import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/auth_notifier.dart';
import '../data/repayments_repository.dart';
import '../domain/repayment_model.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final repaymentsRepositoryProvider = Provider<RepaymentsRepository>(
  (ref) => RepaymentsRepository(ref.read(apiServiceProvider)),
);

/// Liste des dettes d'un agriculteur — utilisé depuis FarmerProfileScreen.
final farmerDebtsProvider =
    FutureProvider.family<List<DebtSummaryModel>, int>((ref, farmerId) async {
  return ref.read(repaymentsRepositoryProvider).getFarmerDebts(farmerId);
});

final repaymentNotifierProvider =
    StateNotifierProvider<RepaymentNotifier, RepaymentState>((ref) {
  return RepaymentNotifier(ref.read(repaymentsRepositoryProvider));
});

// ── State ──────────────────────────────────────────────────────────────────

enum RepaymentStatus { initial, loading, success, error }

class RepaymentState {
  final RepaymentStatus status;
  final String? errorMessage;

  const RepaymentState({
    this.status = RepaymentStatus.initial,
    this.errorMessage,
  });
}

// ── Notifier ───────────────────────────────────────────────────────────────

class RepaymentNotifier extends StateNotifier<RepaymentState> {
  RepaymentNotifier(this._repo) : super(const RepaymentState());

  final RepaymentsRepository _repo;

  Future<bool> createRepayment({
    required int farmerId,
    required double kgReceived,
    required double commodityRateFcfa,
  }) async {
    state = const RepaymentState(status: RepaymentStatus.loading);
    try {
      await _repo.createRepayment(
        farmerId: farmerId,
        kgReceived: kgReceived,
        commodityRateFcfa: commodityRateFcfa,
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
