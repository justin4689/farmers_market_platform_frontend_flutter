import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final _connectivity = Connectivity();

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
}

final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => ConnectivityService());

// Emits current state immediately, then streams changes
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final svc = ref.read(connectivityServiceProvider);
  yield await svc.isOnline();
  yield* svc.onConnectivityChanged;
});
