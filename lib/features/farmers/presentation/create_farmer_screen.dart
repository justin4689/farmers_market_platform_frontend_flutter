import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'farmers_notifier.dart';

class CreateFarmerScreen extends ConsumerStatefulWidget {
  const CreateFarmerScreen({super.key});

  @override
  ConsumerState<CreateFarmerScreen> createState() => _CreateFarmerScreenState();
}

class _CreateFarmerScreenState extends ConsumerState<CreateFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _identifierCtrl = TextEditingController();
  final _creditLimitCtrl = TextEditingController();

  @override
  void dispose() {
    _firstnameCtrl.dispose();
    _lastnameCtrl.dispose();
    _phoneCtrl.dispose();
    _identifierCtrl.dispose();
    _creditLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(farmersNotifierProvider.notifier).create(
          firstname: _firstnameCtrl.text.trim(),
          lastname: _lastnameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          identifier: _identifierCtrl.text.trim(),
          creditLimitFcfa: double.tryParse(_creditLimitCtrl.text),
        );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.farmerCreated),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmersNotifierProvider);
    final isLoading = state.status == FarmersStatus.loading;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    ref.listen(farmersNotifierProvider, (prev, next) {
      if (next.status == FarmersStatus.error &&
          next.errorMessage != null &&
          prev?.status != FarmersStatus.error) {
        _showError(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.newFarmer),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isTablet ? 520.0 : double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Prénom
                    AppTextField(
                      label: 'Prénom',
                      controller: _firstnameCtrl,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Le prénom est requis.'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Nom de famille
                    AppTextField(
                      label: 'Nom de famille',
                      controller: _lastnameCtrl,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Le nom est requis.'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Téléphone
                    AppTextField(
                      label: AppStrings.farmerPhone,
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined,
                          color: AppColors.primary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Le téléphone est requis.'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Identifiant (optionnel)
                    AppTextField(
                      label: 'Identifiant (optionnel)',
                      controller: _identifierCtrl,
                      prefixIcon: const Icon(Icons.badge_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),

                    // Limite de crédit (optionnel)
                    AppTextField(
                      label: 'Limite de crédit FCFA (optionnel)',
                      controller: _creditLimitCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.account_balance_wallet_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 32),

                    AppButton(
                      label: AppStrings.save,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: AppStrings.cancel,
                      isOutlined: true,
                      onPressed: isLoading ? null : () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
