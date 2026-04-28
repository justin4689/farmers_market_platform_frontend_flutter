import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/auth_notifier.dart';
import '../data/products_repository.dart';
import '../domain/product_model.dart';

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) => ProductsRepository(ref.read(apiServiceProvider)),
);

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.read(productsRepositoryProvider).getCategories();
});

final selectedCategoryProvider = StateProvider<int?>((ref) => null);

final productsProvider = FutureProvider<List<ProductModel>>((ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  return ref.read(productsRepositoryProvider).getProducts(categoryId: categoryId);
});
