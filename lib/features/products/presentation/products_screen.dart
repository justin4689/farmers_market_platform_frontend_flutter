import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_loader.dart';
import '../../transactions/presentation/cart_notifier.dart';
import 'product_detail_screen.dart';
import 'products_notifier.dart';

// ── Shimmer skeleton helpers ───────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1.5 + _anim.value * 3, 0),
          end: Alignment(-0.5 + _anim.value * 3, 0),
          colors: const [
            Color(0xFFE8E8E8),
            Color(0xFFF5F5F5),
            Color(0xFFE8E8E8),
          ],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

Widget _bone({double? w, double? h, double radius = 8}) => Container(
      width: w,
      height: h ?? 14,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );

// Skeleton for one category chip
Widget _chipSkeleton() => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: _bone(w: 72, h: 32, radius: 16),
    );

// Skeleton for one product card
Widget _productCardSkeleton() => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _bone(w: 60, h: 60, radius: 30),
          const SizedBox(height: 10),
          _bone(w: 80),
          const SizedBox(height: 6),
          _bone(w: 50, h: 12),
          const SizedBox(height: 6),
          _bone(w: 40, h: 10),
          const SizedBox(height: 12),
          _bone(w: 90, h: 28, radius: 8),
        ],
      ),
    );

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cart = ref.watch(cartProvider);
    final cartCount = ref.watch(cartProvider.select((c) => c.length));
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.products),
        actions: [],
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
      body: Column(
        children: [
          // Category filter chips
          categoriesAsync.when(
            loading: () => _Shimmer(
              child: SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: List.generate(5, (_) => _chipSkeleton()),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (categories) => SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text(AppStrings.allProducts),
                      selected: selectedCategory == null,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selectedCategory == null
                            ? Colors.white
                            : AppColors.textPrimary,
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

          // Products grid
          Expanded(
            child: productsAsync.when(
              loading: () => _Shimmer(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: isTablet ? 9 : 6,
                  itemBuilder: (_, _) => _productCardSkeleton(),
                ),
              ),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(productsProvider),
              ),
              data: (products) => products.isEmpty
                  ? const Center(
                      child: Text(
                        AppStrings.noProducts,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        final p = products[i];
                        final inCart = cart[p.id]?.quantity ?? 0;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: p),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: inCart > 0
                                    ? AppColors.primary
                                    : AppColors.divider,
                                width: inCart > 0 ? 1.5 : 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.eco_outlined,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    p.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.priceFcfa.toStringAsFixed(0)} F',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                if (p.category != null)
                                  Text(
                                    p.category!.name,
                                    style: const TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 10,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // Add to cart button
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: inCart > 0
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _SmallQtyBtn(
                                              icon: Icons.remove,
                                              onTap: () => ref
                                                  .read(cartProvider.notifier)
                                                  .decrement(p.id),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Text(
                                                '$inCart',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            _SmallQtyBtn(
                                              icon: Icons.add,
                                              onTap: () => ref
                                                  .read(cartProvider.notifier)
                                                  .increment(p.id),
                                              active: true,
                                            ),
                                          ],
                                        )
                                      : SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => ref
                                                .read(cartProvider.notifier)
                                                .add(p),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            child: const Text('Ajouter'),
                                          ),
                                        ),
                                ),
                              ],
                            ),
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
}

class _SmallQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _SmallQtyBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary),
        ),
        child: Icon(
          icon,
          size: 14,
          color: active ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}
