import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_loader.dart';
import 'farmers_notifier.dart';

class FarmerSearchScreen extends ConsumerStatefulWidget {
  const FarmerSearchScreen({super.key});

  @override
  ConsumerState<FarmerSearchScreen> createState() => _FarmerSearchScreenState();
}

class _FarmerSearchScreenState extends ConsumerState<FarmerSearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmersNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.farmerSearch),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('New'),
        onPressed: () => context.push('/farmers/create'),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(farmersNotifierProvider.notifier).reset();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (q) {
                setState(() {});
                ref.read(farmersNotifierProvider.notifier).search(q);
              },
            ),
          ),

          // Results
          Expanded(
            child: switch (state.status) {
              FarmersStatus.loading =>
                const AppLoader(message: AppStrings.loading),
              FarmersStatus.error => AppErrorWidget(
                  message: state.errorMessage ?? AppStrings.unknownError,
                  onRetry: () => ref
                      .read(farmersNotifierProvider.notifier)
                      .search(_searchCtrl.text),
                ),
              FarmersStatus.success when state.farmers.isEmpty =>
                const Center(
                  child: Text(
                    AppStrings.noFarmerFound,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              FarmersStatus.success => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.farmers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final farmer = state.farmers[i];
                    return ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          farmer.firstname[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        farmer.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(farmer.phoneNumber),
                      trailing: farmer.totalOutstandingDebt > 0
                          ? Chip(
                              label: Text(
                                '${farmer.totalOutstandingDebt.toStringAsFixed(0)} F',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: AppColors.error,
                              padding: EdgeInsets.zero,
                            )
                          : null,
                      onTap: () => context.push('/farmers/${farmer.id}'),
                    );
                  },
                ),
              _ => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      const Text(
                        'Enter a name or phone number',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
            },
          ),
        ],
      ),
    );
  }
}
