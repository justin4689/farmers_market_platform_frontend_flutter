import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../farmers/domain/farmer_model.dart';
import '../../farmers/presentation/farmers_notifier.dart';
import 'repayments_notifier.dart';

class RepaymentScreen extends ConsumerStatefulWidget {
  final int? farmerId;

  const RepaymentScreen({super.key, this.farmerId});

  @override
  ConsumerState<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends ConsumerState<RepaymentScreen> {
  // Search
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  // Selected farmer
  FarmerModel? _selectedFarmer;

  // Repayment form
  final _formKey = GlobalKey<FormState>();
  final _kgCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  double get _kg => double.tryParse(_kgCtrl.text) ?? 0;
  double get _rate => double.tryParse(_rateCtrl.text) ?? 0;
  double get _total => _kg * _rate;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _kgCtrl.addListener(() => setState(() {}));
    _rateCtrl.addListener(() => setState(() {}));

    Future.microtask(() async {
      if (!mounted) return;
      // Nettoyer les résultats de recherche précédents
      ref.read(farmersNotifierProvider.notifier).reset();
      // Auto-sélection si on vient du profil agriculteur
      if (widget.farmerId != null) {
        try {
          final farmer = await ref.read(
            farmerDetailProvider(widget.farmerId!).future,
          );
          if (mounted) setState(() => _selectedFarmer = farmer);
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _kgCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(farmersNotifierProvider.notifier).search(query);
    });
  }

  void _selectFarmer(FarmerModel farmer) {
    setState(() => _selectedFarmer = farmer);
    // Clear search UI so only the form is prominent
    _searchCtrl.clear();
    ref.read(farmersNotifierProvider.notifier).reset();
    // Reset repayment state from any previous attempt
    ref.read(repaymentNotifierProvider.notifier).reset();
  }

  void _clearFarmer() {
    setState(() {
      _selectedFarmer = null;
      _kgCtrl.clear();
      _rateCtrl.clear();
    });
    ref.read(repaymentNotifierProvider.notifier).reset();
  }

  Future<void> _submit() async {
    if (_selectedFarmer == null) return;
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(repaymentNotifierProvider.notifier)
        .createRepayment(
          farmerId: _selectedFarmer!.id,
          kgReceived: _kg,
          commodityRateFcfa: _rate,
        );

    if (success && mounted) {
      // Invalide le profil pour qu'il soit à jour au retour
      final fid = _selectedFarmer!.id;
      ref.invalidate(farmerDetailProvider(fid));
      ref.invalidate(farmerDebtsProvider(fid));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.repaymentSuccess,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Si on vient du profil, on retourne dessus (données déjà invalidées)
      if (widget.farmerId != null && context.canPop()) {
        context.pop();
      } else {
        _clearFarmer();
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final farmersState = ref.watch(farmersNotifierProvider);
    final repaymentState = ref.watch(repaymentNotifierProvider);
    final isSubmitting = repaymentState.status == RepaymentStatus.loading;

    ref.listen(repaymentNotifierProvider, (prev, next) {
      if (next.status == RepaymentStatus.error &&
          next.errorMessage != null &&
          prev?.status != RepaymentStatus.error) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Repayment error'),
              ],
            ),
            content: Text(next.errorMessage!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(repaymentNotifierProvider.notifier).reset();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.repayment),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top: search section ─────────────────────────────────────────
            _SearchSection(
              searchCtrl: _searchCtrl,
              farmersState: farmersState,
              selectedFarmer: _selectedFarmer,
              onSearchChanged: _onSearchChanged,
              onFarmerSelected: _selectFarmer,
            ),

            // ── Bottom: repayment form (animated) ───────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                ),
                child: _selectedFarmer != null
                    ? _RepaymentForm(
                        key: ValueKey(_selectedFarmer!.id),
                        formKey: _formKey,
                        farmer: _selectedFarmer!,
                        kgCtrl: _kgCtrl,
                        rateCtrl: _rateCtrl,
                        total: _total,
                        totalDebt: _selectedFarmer!.totalOutstandingDebt,
                        isSubmitting: isSubmitting,
                        onClearFarmer: _clearFarmer,
                        onSubmit: _submit,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search section widget ──────────────────────────────────────────────────

class _SearchSection extends StatelessWidget {
  final TextEditingController searchCtrl;
  final FarmersState farmersState;
  final FarmerModel? selectedFarmer;
  final void Function(String) onSearchChanged;
  final void Function(FarmerModel) onFarmerSelected;

  const _SearchSection({
    required this.searchCtrl,
    required this.farmersState,
    required this.selectedFarmer,
    required this.onSearchChanged,
    required this.onFarmerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool showList =
        selectedFarmer == null &&
        (farmersState.status == FarmersStatus.loading ||
            farmersState.status == FarmersStatus.success ||
            farmersState.status == FarmersStatus.error);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Search for a farmer…',
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        searchCtrl.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),

        // Results list / states
        if (showList)
          _FarmerResultsList(
            farmersState: farmersState,
            onFarmerSelected: onFarmerSelected,
          ),
      ],
    );
  }
}

// ── Farmer results list ────────────────────────────────────────────────────

class _FarmerResultsList extends StatelessWidget {
  final FarmersState farmersState;
  final void Function(FarmerModel) onFarmerSelected;

  const _FarmerResultsList({
    required this.farmersState,
    required this.onFarmerSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (farmersState.status == FarmersStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (farmersState.status == FarmersStatus.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  farmersState.errorMessage ?? 'Search error.',
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (farmersState.farmers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            AppStrings.noFarmerFound,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 280),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: farmersState.farmers.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final farmer = farmersState.farmers[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                farmer.firstname.isNotEmpty
                    ? farmer.firstname[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              farmer.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              farmer.phoneNumber,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
            onTap: () => onFarmerSelected(farmer),
          );
        },
      ),
    );
  }
}

// ── Repayment form widget ──────────────────────────────────────────────────

class _RepaymentForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final FarmerModel farmer;
  final TextEditingController kgCtrl;
  final TextEditingController rateCtrl;
  final double total;
  final double totalDebt;
  final bool isSubmitting;
  final VoidCallback onClearFarmer;
  final VoidCallback onSubmit;

  const _RepaymentForm({
    super.key,
    required this.formKey,
    required this.farmer,
    required this.kgCtrl,
    required this.rateCtrl,
    required this.total,
    required this.totalDebt,
    required this.isSubmitting,
    required this.onClearFarmer,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 24),

              // ── Selected farmer chip ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmer.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            farmer.phoneNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Change farmer',
                      onPressed: onClearFarmer,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Dette totale du fermier ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: totalDebt > 0
                      ? AppColors.error.withValues(alpha: 0.07)
                      : AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: totalDebt > 0
                        ? AppColors.error.withValues(alpha: 0.35)
                        : AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      totalDebt > 0
                          ? Icons.account_balance_wallet_outlined
                          : Icons.check_circle_outline,
                      color: totalDebt > 0 ? AppColors.error : AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            totalDebt > 0
                                ? 'Outstanding debt'
                                : 'No debt',
                            style: TextStyle(
                              fontSize: 12,
                              color: totalDebt > 0
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                          Text(
                            '${totalDebt.toStringAsFixed(0)} FCFA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: totalDebt > 0
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Poids (kg) ────────────────────────────────────────────────
              AppTextField(
                label: AppStrings.weightKg,
                controller: kgCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(Icons.scale, color: AppColors.primary),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Weight is required.';
                  }
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid weight.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Taux (FCFA/kg) ────────────────────────────────────────────
              AppTextField(
                label: 'Rate (FCFA/kg)',
                controller: rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.accent,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Rate is required.';
                  }
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid rate.';
                  }
                  if (total > totalDebt) {
                    return 'Total (${total.toStringAsFixed(0)} FCFA) exceeds debt (${totalDebt.toStringAsFixed(0)} FCFA).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Live total ────────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: total > 0
                    ? _TotalCard(
                        key: const ValueKey('total-card'),
                        kg: kgCtrl.text,
                        rate: rateCtrl.text,
                        total: total,
                      )
                    : const SizedBox.shrink(key: ValueKey('total-empty')),
              ),

              const SizedBox(height: 24),

              // ── Submit button ─────────────────────────────────────────────
              AppButton(
                label: AppStrings.confirmRepayment,
                isLoading: isSubmitting,
                onPressed: (totalDebt <= 0 || (total > 0 && total > totalDebt))
                    ? null
                    : onSubmit,
              ),
            ],
          ),
        ),
      );
  }
}

// ── Total summary card ─────────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  final String kg;
  final String rate;
  final double total;

  const _TotalCard({
    super.key,
    required this.kg,
    required this.rate,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final kgVal = double.tryParse(kg) ?? 0;
    final rateVal = double.tryParse(rate) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Weight received',
            value: '${kgVal.toStringAsFixed(2)} kg',
            valueStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Rate',
            value: '${rateVal.toStringAsFixed(0)} FCFA/kg',
            valueStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _SummaryRow(
            label: 'Total credited',
            value: '${total.toStringAsFixed(0)} FCFA',
            valueStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }
}
