import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/domain/product_model.dart';

class CartEntry {
  final ProductModel product;
  final int quantity;

  const CartEntry({required this.product, required this.quantity});

  CartEntry copyWith({int? quantity}) =>
      CartEntry(product: product, quantity: quantity ?? this.quantity);
}

class CartNotifier extends StateNotifier<Map<int, CartEntry>> {
  CartNotifier() : super({});

  void add(ProductModel product, {int qty = 1}) {
    final current = Map<int, CartEntry>.from(state);
    if (current.containsKey(product.id)) {
      current[product.id] = current[product.id]!.copyWith(
        quantity: current[product.id]!.quantity + qty,
      );
    } else {
      current[product.id] = CartEntry(product: product, quantity: qty);
    }
    state = current;
  }

  void increment(int productId) {
    if (!state.containsKey(productId)) return;
    final current = Map<int, CartEntry>.from(state);
    current[productId] = current[productId]!.copyWith(
      quantity: current[productId]!.quantity + 1,
    );
    state = current;
  }

  void decrement(int productId) {
    if (!state.containsKey(productId)) return;
    final current = Map<int, CartEntry>.from(state);
    if (current[productId]!.quantity <= 1) {
      current.remove(productId);
    } else {
      current[productId] = current[productId]!.copyWith(
        quantity: current[productId]!.quantity - 1,
      );
    }
    state = current;
  }

  void setQuantity(int productId, int quantity) {
    if (!state.containsKey(productId)) return;
    if (quantity <= 0) {
      final current = Map<int, CartEntry>.from(state);
      current.remove(productId);
      state = current;
      return;
    }
    final current = Map<int, CartEntry>.from(state);
    current[productId] = current[productId]!.copyWith(quantity: quantity);
    state = current;
  }

  void removeItem(int productId) {
    if (!state.containsKey(productId)) return;
    final current = Map<int, CartEntry>.from(state);
    current.remove(productId);
    state = current;
  }

  void clear() => state = {};

  int quantityOf(int productId) => state[productId]?.quantity ?? 0;

  double get total =>
      state.values.fold(0, (s, e) => s + e.product.priceFcfa * e.quantity);

  int get count => state.values.fold(0, (s, e) => s + e.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<int, CartEntry>>(
  (_) => CartNotifier(),
);
