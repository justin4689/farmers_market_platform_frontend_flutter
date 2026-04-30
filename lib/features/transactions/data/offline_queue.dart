import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/local_cache_service.dart';
import '../domain/pending_transaction.dart';

class OfflineQueue {
  static const _key = 'offline_tx_queue';
  final SharedPreferences _prefs;

  OfflineQueue(this._prefs);

  // ── Read ─────────────────────────────────────────────────────────────────

  List<PendingTransaction> getAll() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => PendingTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<PendingTransaction> getPending() =>
      getAll().where((t) => !t.isFailed).toList();

  int get pendingCount => getPending().length;
  int get failedCount => getAll().where((t) => t.isFailed).length;
  int get totalCount => getAll().length;

  // ── Write ────────────────────────────────────────────────────────────────

  Future<void> enqueue(PendingTransaction tx) async {
    final list = getAll()..add(tx);
    await _save(list);
  }

  Future<void> remove(String id) async {
    await _save(getAll().where((t) => t.id != id).toList());
  }

  Future<void> markFailed(String id, String error) async {
    await _save(getAll().map((t) {
      return t.id == id ? t.copyWith(isFailed: true, errorMessage: error) : t;
    }).toList());
  }

  Future<void> resetFailed() async {
    await _save(getAll()
        .map((t) => t.isFailed ? t.copyWith(isFailed: false, errorMessage: null) : t)
        .toList());
  }

  Future<void> _save(List<PendingTransaction> list) async {
    await _prefs.setString(
      _key,
      jsonEncode(list.map((t) => t.toJson()).toList()),
    );
  }
}

final offlineQueueProvider = Provider<OfflineQueue>(
  (ref) => OfflineQueue(ref.read(sharedPreferencesProvider)),
);
