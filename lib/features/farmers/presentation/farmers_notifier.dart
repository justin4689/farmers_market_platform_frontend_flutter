import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../features/auth/presentation/auth_notifier.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/local_cache_service.dart';
import '../data/farmers_repository.dart';
import '../domain/farmer_model.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final farmersRepositoryProvider = Provider<FarmersRepository>(
  (ref) => FarmersRepository(
    ref.read(apiServiceProvider),
    ref.read(localCacheServiceProvider),
    ref.read(connectivityServiceProvider),
  ),
);

final farmersNotifierProvider =
    NotifierProvider<FarmersNotifier, FarmersState>(FarmersNotifier.new);

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

class FarmersNotifier extends Notifier<FarmersState> {
  late final FarmersRepository _repo;

  @override
  FarmersState build() {
    _repo = ref.read(farmersRepositoryProvider);
    return const FarmersState();
  }

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
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
    }
  }

  Future<bool> create({
    required String firstname,
    required String lastname,
    required String phoneNumber,
    String? identifier,
    double? creditLimitFcfa,
  }) async {
    state = state.copyWith(status: FarmersStatus.loading);
    try {
      await _repo.create(
        firstname: firstname,
        lastname: lastname,
        phoneNumber: phoneNumber,
        identifier: identifier,
        creditLimitFcfa: creditLimitFcfa,
      );
      state = state.copyWith(status: FarmersStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FarmersStatus.error,
        errorMessage: e is ApiException ? e.message : e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const FarmersState();
}
