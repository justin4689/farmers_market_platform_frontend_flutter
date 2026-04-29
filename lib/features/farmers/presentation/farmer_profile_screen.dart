import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_button.dart';
import '../../repayments/presentation/repayments_notifier.dart';
import 'farmers_notifier.dart';

class FarmerProfileScreen extends ConsumerWidget {
  final int farmerId;

  const FarmerProfileScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmerAsync = ref.watch(farmerDetailProvider(farmerId));
    final debtsAsync = ref.watch(farmerDebtsProvider(farmerId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.farmerProfile),
      ),
      body: farmerAsync.when(
        loading: () => const AppLoader(message: AppStrings.loading),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(farmerDetailProvider(farmerId)),
        ),
        data: (farmer) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Text(
                          farmer.firstname[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.tag,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  farmer.identifier,
                                  style:
                                      const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  farmer.phoneNumber,
                                  style:
                                      const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Credit limit + debt summary
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: 'Limite de crédit',
                        value:
                            '${farmer.creditLimitFcfa.toStringAsFixed(0)} F',
                        icon: Icons.account_balance_wallet,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        label: AppStrings.totalDebt,
                        value:
                            '${farmer.totalOutstandingDebt.toStringAsFixed(0)} F',
                        icon: farmer.totalOutstandingDebt > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle,
                        color: farmer.totalOutstandingDebt > 0
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Nouvelle transaction',
                        onPressed: () => context.push(
                            '/checkout?farmerId=$farmerId&farmerName=${Uri.encodeComponent(farmer.fullName)}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Remboursement',
                        color: AppColors.accent,
                        onPressed: () =>
                            context.push('/repayments?farmerId=$farmerId'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Debts list
                const Text(
                  AppStrings.debtSummary,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                debtsAsync.when(
                  loading: () => const AppLoader(),
                  error: (e, _) => AppErrorWidget(
                    message: e.toString(),
                    onRetry: () =>
                        ref.invalidate(farmerDebtsProvider(farmerId)),
                  ),
                  data: (debts) => debts.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Aucune dette enregistrée.',
                              style:
                                  TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      : Column(
                          children: debts.map((d) {
                            final isPaid = d.status == 'paid';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  isPaid
                                      ? Icons.check_circle
                                      : Icons.pending_actions,
                                  color: isPaid
                                      ? AppColors.primary
                                      : AppColors.accent,
                                ),
                                title: Text(
                                  'Transaction #${d.transactionId}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(d.createdAt),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${d.amountFcfa.toStringAsFixed(0)} F',
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Reste: ${d.remainingFcfa.toStringAsFixed(0)} F',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
