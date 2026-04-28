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
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _villageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(farmersNotifierProvider.notifier).create(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          village: _villageCtrl.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(farmersNotifierProvider);
    final isLoading = state.status == FarmersStatus.loading;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

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
            constraints: BoxConstraints(maxWidth: isTablet ? 520.0 : double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.status == FarmersStatus.error &&
                        state.errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.error),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),

                    AppTextField(
                      label: AppStrings.farmerName,
                      controller: _nameCtrl,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Le nom est requis.'
                          : null,
                    ),
                    const SizedBox(height: 16),

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

                    AppTextField(
                      label: AppStrings.farmerVillage,
                      controller: _villageCtrl,
                      prefixIcon: const Icon(Icons.location_on_outlined,
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
