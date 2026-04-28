import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/auth_notifier.dart';
import '../data/farmers_repository.dart';
import '../domain/farmer_model.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final farmersRepositoryProvider = Provider<FarmersRepository>(
  (ref) => FarmersRepository(ref.read(apiServiceProvider)),
);

final farmersNotifierProvider =
    StateNotifierProvider<FarmersNotifier, FarmersState>((ref) {
  return FarmersNotifier(ref.read(farmersRepositoryProvider));
});

final farmerDebtsProvider =
    FutureProvider.family<List<DebtModel>, int>((ref, farmerId) async {
  return ref.read(farmersRepositoryProvider).getDebts(farmerId);
});

final farmerDetailProvider =
    FutureProvider.family<FarmerModel, int>((ref, id) async {
  return ref.read(farmersRepositoryProvider).getById(id);
});

// ── State ──────────────────────────────────────────────────────────────────

enum FarmersStatus { initial, loading, success, error }

class FarmersState {
  final FarmersStatus status;
  final List<FarmerModel> farmers;
  final String? errorMessage;

  const FarmersState({
    this.status = FarmersStatus.initial,
    this.farmers = const [],
    this.errorMessage,
  });

  FarmersState copyWith({
    FarmersStatus? status,
    List<FarmerModel>? farmers,
    String? errorMessage,
  }) {
    return FarmersState(
      status: status ?? this.status,
      farmers: farmers ?? this.farmers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────

class FarmersNotifier extends StateNotifier<FarmersState> {
  FarmersNotifier(this._repo) : super(const FarmersState());

  final FarmersRepository _repo;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(status: FarmersStatus.initial, farmers: []);
      return;
    }
    state = state.copyWith(status: FarmersStatus.loading);
    try {
      final farmers = await _repo.search(query);
      state = state.copyWith(status: FarmersStatus.success, farmers: farmers);
    } catch (e) {
      state = state.copyWith(
        status: FarmersStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> create({
    required String name,
    required String phone,
    String? village,
  }) async {
    state = state.copyWith(status: FarmersStatus.loading);
    try {
      await _repo.create(name: name, phone: phone, village: village);
      state = state.copyWith(status: FarmersStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FarmersStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const FarmersState();
}
