import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_button.dart';
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
                          farmer.name[0].toUpperCase(),
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
                              farmer.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  farmer.phone,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            if (farmer.village != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    farmer.village!,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Debt summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: farmer.totalDebt > 0
                        ? AppColors.error.withValues(alpha: 0.08)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: farmer.totalDebt > 0
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.totalDebt,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${farmer.totalDebt.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: farmer.totalDebt > 0
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        farmer.totalDebt > 0
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle,
                        color: farmer.totalDebt > 0
                            ? AppColors.error
                            : AppColors.primary,
                        size: 36,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Nouvelle transaction',
                        onPressed: () =>
                            context.push('/checkout?farmerId=$farmerId'),
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
                  error: (e, _) =>
                      AppErrorWidget(message: e.toString()),
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
                          children: debts
                              .map(
                                (d) => Card(
                                  margin:
                                      const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(d.description),
                                    subtitle: Text(d.date),
                                    trailing: Text(
                                      '${d.amount.toStringAsFixed(0)} F',
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
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
