import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_notifier.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/farmers/presentation/farmer_search_screen.dart';
import '../features/farmers/presentation/create_farmer_screen.dart';
import '../features/farmers/presentation/farmer_profile_screen.dart';
import '../features/products/presentation/products_screen.dart';
import '../features/transactions/presentation/checkout_screen.dart';
import '../features/transactions/presentation/cart_screen.dart';
import '../features/repayments/presentation/repayment_screen.dart';
import '../features/splash/splash_screen.dart';

// ── Router notifier (bridges Riverpod → GoRouter listenable) ───────────────

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authNotifierProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final isInitializing =
        authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading;
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final isLoginRoute = state.matchedLocation == '/login';

    if (isInitializing) return null;
    if (!isAuthenticated && !isLoginRoute) return '/login';
    if (isAuthenticated && isLoginRoute) return '/home';
    return null;
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, _) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, _) => const LoginScreen(),
      ),

      // Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, _) => const HomeScreen(),
      ),

      // Farmers
      GoRoute(
        path: '/farmers/search',
        name: 'farmer-search',
        builder: (_, _) => const FarmerSearchScreen(),
      ),
      GoRoute(
        path: '/farmers/create',
        name: 'farmer-create',
        builder: (_, _) => const CreateFarmerScreen(),
      ),
      GoRoute(
        path: '/farmers/:id',
        name: 'farmer-profile',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return FarmerProfileScreen(farmerId: id);
        },
      ),

      // Products
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (_, _) => const ProductsScreen(),
      ),

      // Checkout / Cart
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (_, state) {
          final farmerId = int.tryParse(
            state.uri.queryParameters['farmerId'] ?? '',
          );
          final farmerName = state.uri.queryParameters['farmerName'];
          return CheckoutScreen(farmerId: farmerId, farmerName: farmerName);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (_, state) {
          return const CartScreen();
        },
      ),

      // Repayments
      GoRoute(
        path: '/repayments',
        name: 'repayments',
        builder: (_, state) {
          final farmerId = int.tryParse(
            state.uri.queryParameters['farmerId'] ?? '',
          );
          return RepaymentScreen(farmerId: farmerId);
        },
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text(
          'Page introuvable : ${state.uri}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ),
  );
});
