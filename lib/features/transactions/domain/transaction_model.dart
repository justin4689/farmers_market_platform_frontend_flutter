class TransactionModel {
  final int id;
  final int farmerId;
  final int productId;
  final double quantityKg;
  final double totalAmount;
  final String paymentMethod;
  final String createdAt;

  const TransactionModel({
    required this.id,
    required this.farmerId,
    required this.productId,
    required this.quantityKg,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      farmerId: json['farmer_id'] as int,
      productId: json['product_id'] as int,
      quantityKg: (json['quantity_kg'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
