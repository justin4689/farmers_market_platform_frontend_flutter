import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_loader.dart';
import '../domain/transaction_model.dart';
import '../../products/presentation/products_notifier.dart';
import 'cart_notifier.dart';
import 'transactions_notifier.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final int? farmerId;
  final String? farmerName;

  const CheckoutScreen({super.key, this.farmerId, this.farmerName});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    ref.watch(transactionNotifierProvider);

    ref.listen(transactionNotifierProvider, (prev, next) {
      if (next.status == TransactionStatus.error &&
          next.errorMessage != null &&
          prev?.status != TransactionStatus.error) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Error'),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.checkout,
                style: TextStyle(fontSize: 18)),
            if (widget.farmerName != null)
              Text(widget.farmerName!,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      // FAB panier
      floatingActionButton: cartNotifier.count > 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                'Panier (${cartNotifier.count}) — ${cartNotifier.total.toStringAsFixed(0)} F',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showCartSheet(context, ref),
            )
          : null,
      body: Column(
        children: [
          // Category filter
          categoriesAsync.when(
            loading: () => const SizedBox(height: 48, child: AppLoader()),
            error: (_, _) => const SizedBox.shrink(),
            data: (categories) => SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Tous'),
                      selected: selectedCategory == null,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selectedCategory == null
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                      onSelected: (_) =>
                          ref.read(selectedCategoryProvider.notifier).state =
                              null,
                    ),
                  ),
                  ...categories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(c.name),
                        selected: selectedCategory == c.id,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selectedCategory == c.id
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 12,
                        ),
                        onSelected: (_) =>
                            ref.read(selectedCategoryProvider.notifier).state =
                                c.id,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Products list
          Expanded(
            child: productsAsync.when(
              loading: () =>
                  const AppLoader(message: AppStrings.loading),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(productsProvider),
              ),
              data: (products) => products.isEmpty
                  ? const Center(
                      child: Text(AppStrings.noProducts,
                          style:
                              TextStyle(color: AppColors.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: products.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final p = products[i];
                        final qty = cart[p.id]?.quantity ?? 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: qty > 0
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: qty > 0 ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.eco_outlined,
                                    color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        )),
                                    Text(
                                      '${p.priceFcfa.toStringAsFixed(0)} FCFA/u',
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (p.category != null)
                                      Text(p.category!.name,
                                          style: const TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 11,
                                          )),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove,
                                    onTap: qty > 0
                                        ? () => ref
                                            .read(cartProvider.notifier)
                                            .decrement(p.id)
                                        : null,
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '$qty',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: qty > 0
                                            ? AppColors.primary
                                            : AppColors.textHint,
                                      ),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    onTap: () => ref
                                        .read(cartProvider.notifier)
                                        .add(p),
                                    active: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: _CartBottomSheet(
          farmerId: widget.farmerId,
          farmerName: widget.farmerName,
        ),
      ),
    );
  }
}

// ── Quantity button ────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  const _QtyButton({required this.icon, this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.surface
              : active
                  ? AppColors.primary
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap == null ? AppColors.divider : AppColors.primary,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null
              ? AppColors.textHint
              : active
                  ? Colors.white
                  : AppColors.primary,
        ),
      ),
    );
  }
}

// ── Cart bottom sheet ──────────────────────────────────────────────────────

class _CartBottomSheet extends ConsumerStatefulWidget {
  final int? farmerId;
  final String? farmerName;

  const _CartBottomSheet({this.farmerId, this.farmerName});

  @override
  ConsumerState<_CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<_CartBottomSheet> {
  String _paymentMethod = 'cash';
  final _interestCtrl = TextEditingController(text: '15');

  @override
  void dispose() {
    _interestCtrl.dispose();
    super.dispose();
  }

  double get _interestRate =>
      (double.tryParse(_interestCtrl.text) ?? 0) / 100;

  Future<void> _confirm(double subtotal) async {
    if (widget.farmerId == null) return;

    final cart = ref.read(cartProvider);
    final items = cart.values
        .map((e) => CheckoutItem(
              productId: e.product.id,
              quantity: e.quantity.toDouble(),
            ))
        .toList();

    final interestRate =
        _paymentMethod == 'credit' ? _interestRate : null;

    final success = await ref
        .read(transactionNotifierProvider.notifier)
        .checkout(
          farmerId: widget.farmerId!,
          paymentMethod: _paymentMethod,
          interestRate: interestRate,
          items: items,
        );

    if (success && mounted) {
      ref.read(cartProvider.notifier).clear();
      Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.transactionSuccess),
            backgroundColor: AppColors.primary,
          ),
        );
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final txState = ref.watch(transactionNotifierProvider);
    final isLoading = txState.status == TransactionStatus.loading;

    final subtotal = cartNotifier.total;
    final interestAmount =
        _paymentMethod == 'credit' ? subtotal * _interestRate : 0.0;
    final grandTotal = subtotal + interestAmount;

    ref.listen(transactionNotifierProvider, (prev, next) {
      if (next.status == TransactionStatus.error &&
          next.errorMessage != null &&
          prev?.status != TransactionStatus.error) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Error'),
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Farmer
            if (widget.farmerName != null) ...[
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    widget.farmerName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Cart items
            ...cart.values.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${e.product.name} × ${e.quantity}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      '${(e.product.priceFcfa * e.quantity).toStringAsFixed(0)} F',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 20),

            // Payment method
            const Text(
              AppStrings.paymentMethod,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _PaymentChip(
                  label: AppStrings.cash,
                  icon: Icons.money,
                  selected: _paymentMethod == 'cash',
                  onTap: () => setState(() => _paymentMethod = 'cash'),
                ),
                const SizedBox(width: 10),
                _PaymentChip(
                  label: AppStrings.credit,
                  icon: Icons.credit_card,
                  selected: _paymentMethod == 'credit',
                  onTap: () => setState(() => _paymentMethod = 'credit'),
                ),
              ],
            ),

            // Interest rate
            if (_paymentMethod == 'credit') ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _interestCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Interest rate (%)',
                  prefixIcon: const Icon(Icons.percent,
                      color: AppColors.accent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],

            const SizedBox(height: 16),

            // Totals
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _TotalRow(
                      label: 'Subtotal',
                      value: subtotal.toStringAsFixed(0)),
                  if (interestAmount > 0) ...[
                    const SizedBox(height: 4),
                    _TotalRow(
                      label:
                          'Interest (${_interestCtrl.text}%)',
                      value: interestAmount.toStringAsFixed(0),
                    ),
                  ],
                  const Divider(height: 14),
                  _TotalRow(
                    label: AppStrings.totalAmount,
                    value: grandTotal.toStringAsFixed(0),
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Confirm button
            ElevatedButton(
              onPressed: (isLoading || widget.farmerId == null)
                  ? null
                  : () => _confirm(subtotal),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      widget.farmerId == null
                          ? 'Select a farmer first'
                          : AppStrings.confirmTransaction,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? Colors.white : AppColors.textSecondary,
                  size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalRow(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 15 : 13,
            )),
        Text(
          '$value FCFA',
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            fontSize: bold ? 17 : 13,
            color: bold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
