import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/connectivity_service.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../sync/sync_notifier.dart';
import '../../transactions/presentation/cart_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 3 : 2;

    final menuItems = [
      _MenuItem(
        icon: Icons.search,
        label: AppStrings.searchFarmer,
        color: AppColors.primary,
        route: '/farmers/search',
      ),
      _MenuItem(
        icon: Icons.person_add,
        label: AppStrings.createFarmer,
        color: AppColors.accent,
        route: '/farmers/create',
      ),
      _MenuItem(
        icon: Icons.inventory_2_outlined,
        label: AppStrings.products,
        color: const Color(0xFF1565C0),
        route: '/products',
      ),
      _MenuItem(
        icon: Icons.payment_outlined,
        label: AppStrings.repayments,
        color: const Color(0xFF6A1B9A),
        route: '/repayments',
      ),
    
    ];

    final cartCount = ref.watch(cartProvider.select((c) => c.length));
    final syncState = ref.watch(syncNotifierProvider);
    final isOnline = ref.watch(isOnlineProvider).asData?.value ?? true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset('assets/images/logo1.png', height: 28),
            const SizedBox(width: 8),
            const Text(
              AppStrings.appName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/cart'),
        child: Badge(
          isLabelVisible: cartCount > 0,
          label: Text('$cartCount'),
          child: const Icon(Icons.shopping_cart),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Offline banner ──────────────────────────────────────────────
            if (!isOnline)
              Material(
                color: const Color(0xFFE65100),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'You are offline — transactions will be queued',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      if (syncState.totalQueued > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${syncState.totalQueued} queued',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // ── Sync banner (online + pending) ──────────────────────────────
            if (isOnline && syncState.totalQueued > 0)
              Material(
                color: syncState.isSyncing
                    ? AppColors.primary
                    : syncState.hasFailed
                        ? AppColors.error
                        : const Color(0xFF2E7D32),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (syncState.isSyncing)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      else
                        Icon(
                          syncState.hasFailed
                              ? Icons.sync_problem
                              : Icons.sync,
                          color: Colors.white,
                          size: 18,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          syncState.isSyncing
                              ? 'Syncing ${syncState.pendingCount} transaction(s)…'
                              : syncState.hasFailed
                                  ? '${syncState.failedCount} transaction(s) failed to sync'
                                  : '${syncState.pendingCount} transaction(s) pending sync',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                      if (syncState.hasFailed)
                        TextButton(
                          onPressed: () => ref
                              .read(syncNotifierProvider.notifier)
                              .retryFailed(),
                          child: const Text('Retry',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )
                      else if (!syncState.isSyncing)
                        TextButton(
                          onPressed: () =>
                              ref.read(syncNotifierProvider.notifier).syncNow(),
                          child: const Text('Sync now',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),

            // ── Main content ────────────────────────────────────────────────
            Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name ?? 'Operator'} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.appTagline,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Main menu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Menu grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _MenuCard(item: item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 32),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
