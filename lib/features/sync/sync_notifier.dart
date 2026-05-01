import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/connectivity_service.dart';
import '../transactions/data/offline_queue.dart';
import '../transactions/data/transactions_repository.dart';
import '../transactions/domain/pending_transaction.dart';
import '../transactions/domain/transaction_model.dart';

// ── State ──────────────────────────────────────────────────────────────────

class SyncState {
  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;
  final int failedCount;
  final DateTime? lastSyncAt;

  const SyncState({
    this.isOnline = true,
    this.isSyncing = false,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastSyncAt,
  });

  SyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    int? pendingCount,
    int? failedCount,
    DateTime? lastSyncAt,
  }) =>
      SyncState(
        isOnline: isOnline ?? this.isOnline,
        isSyncing: isSyncing ?? this.isSyncing,
        pendingCount: pendingCount ?? this.pendingCount,
        failedCount: failedCount ?? this.failedCount,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      );

  bool get hasPending => pendingCount > 0;
  bool get hasFailed => failedCount > 0;
  int get totalQueued => pendingCount + failedCount;
}

// ── Notifier ───────────────────────────────────────────────────────────────

class SyncNotifier extends Notifier<SyncState> {
  late final OfflineQueue _queue;
  late final TransactionsRepository _repo;
  late final ConnectivityService _connectivity;
  StreamSubscription<bool>? _sub;

  @override
  SyncState build() {
    _queue = ref.read(offlineQueueProvider);
    _repo = ref.read(transactionsRepositoryProvider);
    _connectivity = ref.read(connectivityServiceProvider);
    ref.onDispose(() => _sub?.cancel());
    _init();
    return const SyncState();
  }

  void _init() async {
    final online = await _connectivity.isOnline();
    _refreshCounts(isOnline: online);
    if (online) _sync();

    _sub = _connectivity.onConnectivityChanged.listen((online) {
      _refreshCounts(isOnline: online);
      if (online) _sync();
    });
  }

  void _refreshCounts({bool? isOnline}) {
    state = state.copyWith(
      isOnline: isOnline ?? state.isOnline,
      pendingCount: _queue.pendingCount,
      failedCount: _queue.failedCount,
    );
  }

  Future<void> _sync() async {
    final pending = _queue.getPending();
    if (pending.isEmpty) return;

    state = state.copyWith(isSyncing: true);

    for (final tx in pending) {
      try {
        final items = tx.items
            .map((i) => CheckoutItem(
                  productId: i['product_id'] as int,
                  quantity: (i['quantity'] as num).toDouble(),
                ))
            .toList();

        await _repo.checkoutOnline(
          farmerId: tx.farmerId,
          paymentMethod: tx.paymentMethod,
          interestRate: tx.interestRate,
          items: items,
        );
        await _queue.remove(tx.id);
      } catch (e) {
        await _queue.markFailed(tx.id, e.toString());
      }
    }

    state = state.copyWith(
      isSyncing: false,
      pendingCount: _queue.pendingCount,
      failedCount: _queue.failedCount,
      lastSyncAt: DateTime.now(),
    );
  }

  List<PendingTransaction> getAll() => _queue.getAll();

  // Retry all failed transactions
  Future<void> retryFailed() async {
    await _queue.resetFailed();
    _refreshCounts();
    if (state.isOnline) await _sync();
  }

  // Discard all permanently failed transactions
  Future<void> clearFailed() async {
    await _queue.clearFailed();
    _refreshCounts();
  }

  // Manually trigger sync
  Future<void> syncNow() async {
    if (!state.isOnline) return;
    await _sync();
  }

}

final syncNotifierProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);
