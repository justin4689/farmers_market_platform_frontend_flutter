import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_loader.dart';
import '../../products/presentation/products_notifier.dart';
import 'transactions_notifier.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final int? farmerId;
  final int? productId;

  const CheckoutScreen({super.key, this.farmerId, this.productId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _farmerIdCtrl = TextEditingController();

  String _paymentMethod = 'cash';
  int? _selectedProductId;
  double _pricePerKg = 0;
  double get _total =>
      (double.tryParse(_qtyCtrl.text) ?? 0) * _pricePerKg;

  static const _paymentMethods = [
    (value: 'cash', label: AppStrings.cash, icon: Icons.money),
    (
      value: 'mobile_money',
      label: AppStrings.mobileMoney,
      icon: Icons.phone_android
    ),
    (value: 'credit', label: AppStrings.credit, icon: Icons.credit_card),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _selectedProductId = widget.productId;
    if (widget.farmerId != null) {
      _farmerIdCtrl.text = widget.farmerId.toString();
    }
    _qtyCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _farmerIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un produit.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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
        .read(transactionNotifierProvider.notifier)
        .createTransaction(
          farmerId: farmerId,
          productId: _selectedProductId!,
          quantityKg: double.parse(_qtyCtrl.text),
          paymentMethod: _paymentMethod,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.transactionSuccess),
          backgroundColor: AppColors.primary,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final txState = ref.watch(transactionNotifierProvider);
    final isLoading = txState.status == TransactionStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.checkout),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (txState.status == TransactionStatus.error &&
                    txState.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(txState.errorMessage!,
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

                // Product selection
                const Text(
                  'Produit',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                productsAsync.when(
                  loading: () => const AppLoader(),
                  error: (e, _) => AppErrorWidget(message: e.toString()),
                  data: (products) => DropdownButtonFormField<int>(
                    initialValue: _selectedProductId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    hint: const Text('Choisir un produit'),
                    items: products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.name} — ${p.pricePerKg.toStringAsFixed(0)} F/kg'),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      setState(() {
                        _selectedProductId = id;
                        final p = products.firstWhere((p) => p.id == id);
                        _pricePerKg = p.pricePerKg;
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Veuillez choisir un produit.' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity
                AppTextField(
                  label: AppStrings.quantity,
                  controller: _qtyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.scale_outlined,
                      color: AppColors.primary),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'La quantité est requise.';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Quantité invalide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Total display
                if (_total > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(AppStrings.totalAmount,
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                        Text(
                          '${_total.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Payment method
                const Text(
                  AppStrings.paymentMethod,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _paymentMethods
                      .map(
                        (m) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () =>
                                  setState(() => _paymentMethod = m.value),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                decoration: BoxDecoration(
                                  color: _paymentMethod == m.value
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _paymentMethod == m.value
                                        ? AppColors.primary
                                        : AppColors.divider,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      m.icon,
                                      color: _paymentMethod == m.value
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      m.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _paymentMethod == m.value
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 32),

                AppButton(
                  label: AppStrings.confirmTransaction,
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
