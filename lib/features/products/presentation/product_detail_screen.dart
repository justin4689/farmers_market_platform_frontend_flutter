import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/product_model.dart';
import '../../transactions/presentation/cart_notifier.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final inCart = cart[widget.product.id]?.quantity ?? 0;
    final cartCount = cart.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(widget.product.name),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/cart'),
        child: Badge(
          isLabelVisible: cartCount > 0,
          label: Text('$cartCount'),
          child: const Icon(Icons.shopping_cart),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon header
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.eco_outlined,
                    color: AppColors.primary,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Price
              Text(
                '${widget.product.priceFcfa.toStringAsFixed(0)} FCFA / unité',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),

              // Category
              if (widget.product.category != null)
                Row(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.product.category!.name,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

              // Description
              if (widget.product.description != null &&
                  widget.product.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.product.description!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Quantity selector (only visible when in cart)
              if (inCart > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () {
                        if (inCart > 1) {
                          ref
                              .read(cartProvider.notifier)
                              .decrement(widget.product.id);
                        } else {
                          // Remove from cart when reaching 0
                          ref
                              .read(cartProvider.notifier)
                              .decrement(widget.product.id);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '$inCart',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .increment(widget.product.id),
                      active: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Sous-total : ${(widget.product.priceFcfa * inCart).toStringAsFixed(0)} FCFA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Add to cart button
              ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  inCart > 0 ? 'Déjà dans le panier' : 'Ajouter au panier',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: inCart > 0
                      ? AppColors.textHint
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: inCart > 0
                    ? null
                    : () {
                        ref
                            .read(cartProvider.notifier)
                            .add(widget.product, qty: 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${widget.product.name} ajouté au panier',
                            ),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  const _QtyButton({required this.icon, this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.surface
              : active
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap == null ? AppColors.divider : AppColors.primary,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
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
