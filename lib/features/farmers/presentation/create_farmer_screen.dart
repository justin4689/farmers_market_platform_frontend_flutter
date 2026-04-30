import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'farmers_notifier.dart';

// ── Modèle indicatif pays ──────────────────────────────────────────────────

class _Country {
  final String flag;
  final String name;
  final String dialCode;
  const _Country(this.flag, this.name, this.dialCode);
}

const _countries = [
  _Country('🇨🇮', 'Côte d\'Ivoire', '+225'),
  _Country('🇧🇫', 'Burkina Faso',   '+226'),
  _Country('🇲🇱', 'Mali',           '+223'),
  _Country('🇬🇳', 'Guinée',         '+224'),
  _Country('🇸🇳', 'Sénégal',        '+221'),
  _Country('🇧🇯', 'Bénin',          '+229'),
  _Country('🇹🇬', 'Togo',           '+228'),
  _Country('🇳🇪', 'Niger',          '+227'),
  _Country('🇬🇭', 'Ghana',          '+233'),
  _Country('🇨🇲', 'Cameroun',       '+237'),
  _Country('🇳🇬', 'Nigeria',        '+234'),
  _Country('🇫🇷', 'France',         '+33'),
];

// ── Screen ─────────────────────────────────────────────────────────────────

class CreateFarmerScreen extends ConsumerStatefulWidget {
  const CreateFarmerScreen({super.key});

  @override
  ConsumerState<CreateFarmerScreen> createState() => _CreateFarmerScreenState();
}

class _CreateFarmerScreenState extends ConsumerState<CreateFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameCtrl    = TextEditingController();
  final _lastnameCtrl     = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _identifierCtrl   = TextEditingController();
  final _creditLimitCtrl  = TextEditingController();

  _Country _selectedCountry = _countries.first; // Côte d'Ivoire par défaut

  @override
  void dispose() {
    _firstnameCtrl.dispose();
    _lastnameCtrl.dispose();
    _phoneCtrl.dispose();
    _identifierCtrl.dispose();
    _creditLimitCtrl.dispose();
    super.dispose();
  }

  // ── Sélecteur de pays ──────────────────────────────────────────────────────

  void _pickCountry() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choisir l\'indicatif',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _countries.length,
                itemBuilder: (_, i) {
                  final c = _countries[i];
                  final selected = c.dialCode == _selectedCountry.dialCode;
                  return ListTile(
                    leading: Text(c.flag,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(c.name),
                    trailing: Text(
                      c.dialCode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    selected: selected,
                    selectedTileColor: AppColors.primary.withValues(alpha: 0.07),
                    onTap: () {
                      setState(() => _selectedCountry = c);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  // ── Soumission ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone =
        '${_selectedCountry.dialCode}${_phoneCtrl.text.trim()}';

    final success = await ref.read(farmersNotifierProvider.notifier).create(
          firstname:      _firstnameCtrl.text.trim(),
          lastname:       _lastnameCtrl.text.trim(),
          phoneNumber:    fullPhone,
          identifier:     _identifierCtrl.text.trim(),
          creditLimitFcfa: double.tryParse(_creditLimitCtrl.text.trim()) ?? 0,
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state     = ref.watch(farmersNotifierProvider);
    final isLoading = state.status == FarmersStatus.loading;
    final isTablet  = MediaQuery.of(context).size.width > 600;

    ref.listen(farmersNotifierProvider, (prev, next) {
      if (next.status == FarmersStatus.error &&
          next.errorMessage != null &&
          prev?.status != FarmersStatus.error) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Erreur'),
              ],
            ),
            content: Text(next.errorMessage!),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
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
                    // ── Prénom ──────────────────────────────────────────────
                    AppTextField(
                      label: 'Prénom *',
                      controller: _firstnameCtrl,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Le prénom est requis.'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Nom de famille ──────────────────────────────────────
                    AppTextField(
                      label: 'Nom de famille *',
                      controller: _lastnameCtrl,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Le nom est requis.'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Téléphone (indicatif + numéro) ──────────────────────
                    FormField<String>(
                      validator: (_) {
                        if (_phoneCtrl.text.trim().isEmpty) {
                          return 'Le numéro de téléphone est requis.';
                        }
                        if (_phoneCtrl.text.trim().length < 6) {
                          return 'Numéro trop court.';
                        }
                        return null;
                      },
                      builder: (fieldState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Téléphone *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Sélecteur indicatif
                                GestureDetector(
                                  onTap: _pickCountry,
                                  child: Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: fieldState.hasError
                                            ? AppColors.error
                                            : AppColors.divider,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_selectedCountry.flag,
                                            style: const TextStyle(
                                                fontSize: 22)),
                                        const SizedBox(width: 6),
                                        Text(
                                          _selectedCountry.dialCode,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 18,
                                            color: AppColors.textSecondary),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Champ numéro
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: 'Ex: 0701234567',
                                      hintStyle: const TextStyle(
                                          color: AppColors.textHint),
                                      filled: true,
                                      fillColor: AppColors.surface,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppColors.divider),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppColors.primary,
                                            width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppColors.error),
                                      ),
                                    ),
                                    onChanged: (_) => fieldState.didChange(null),
                                  ),
                                ),
                              ],
                            ),
                            if (fieldState.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  fieldState.errorText!,
                                  style: const TextStyle(
                                      color: AppColors.error, fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Identifiant ─────────────────────────────────────────
                    AppTextField(
                      label: 'Identifiant *',
                      controller: _identifierCtrl,
                      prefixIcon: const Icon(Icons.badge_outlined,
                          color: AppColors.primary),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'L\'identifiant est requis.'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Limite de crédit ────────────────────────────────────
                    AppTextField(
                      label: 'Limite de crédit (FCFA) *',
                      controller: _creditLimitCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'La limite de crédit est requise.';
                        }
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Valeur invalide.';
                        }
                        return null;
                      },
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
