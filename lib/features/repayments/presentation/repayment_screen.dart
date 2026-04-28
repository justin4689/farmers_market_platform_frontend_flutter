import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'repayments_notifier.dart';

class RepaymentScreen extends ConsumerStatefulWidget {
  final int? farmerId;

  const RepaymentScreen({super.key, this.farmerId});

  @override
  ConsumerState<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends ConsumerState<RepaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmerIdCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  // Conversion rate FCFA per kg (can be made configurable)
  static const double _fcfaPerKg = 500.0;

  @override
  void initState() {
    super.initState();
    if (widget.farmerId != null) {
      _farmerIdCtrl.text = widget.farmerId.toString();
    }
    _weightCtrl.addListener(_updateAmount);
  }

  void _updateAmount() {
    final kg = double.tryParse(_weightCtrl.text) ?? 0;
    final amount = kg * _fcfaPerKg;
    if (amount > 0) {
      _amountCtrl.text = amount.toStringAsFixed(0);
    } else {
      _amountCtrl.clear();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _farmerIdCtrl.dispose();
    _weightCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final farmerId = int.tryParse(_farmerIdCtrl.text.trim());
    if (farmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID agriculteur invalide.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(repaymentNotifierProvider.notifier)
        .createRepayment(
          farmerId: farmerId,
          weightKg: double.parse(_weightCtrl.text),
          amountFcfa: double.parse(_amountCtrl.text),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.repaymentSuccess),
          backgroundColor: AppColors.primary,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(repaymentNotifierProvider);
    final isLoading = state.status == RepaymentStatus.loading;
    final weightKg = double.tryParse(_weightCtrl.text) ?? 0;
    final total = weightKg * _fcfaPerKg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.repayment),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Taux de conversion : ${_fcfaPerKg.toStringAsFixed(0)} FCFA/kg',
                          style: const TextStyle(
                              color: AppColors.accent, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (state.status == RepaymentStatus.error &&
                    state.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(state.errorMessage!,
                        style: const TextStyle(color: AppColors.error)),
                  ),

                // Farmer ID
                AppTextField(
                  label: 'ID Agriculteur',
                  controller: _farmerIdCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppColors.primary),
                  enabled: widget.farmerId == null,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'L\'ID agriculteur est requis.'
                      : null,
                ),
                const SizedBox(height: 16),

                // Weight input
                AppTextField(
                  label: AppStrings.weightKg,
                  controller: _weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon:
                      const Icon(Icons.scale, color: AppColors.primary),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le poids est requis.';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Poids invalide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount (auto-computed)
                AppTextField(
                  label: AppStrings.amountFcfa,
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.payments_outlined,
                      color: AppColors.accent),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le montant est requis.';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Montant invalide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Total summary
                if (total > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total remboursement',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                        Text(
                          '${total.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                AppButton(
                  label: AppStrings.confirmRepayment,
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
