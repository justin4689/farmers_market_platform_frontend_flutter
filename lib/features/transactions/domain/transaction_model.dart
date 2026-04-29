// Helper : accepte num ET String (ex: "15.00" renvoyé par Laravel)
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

// ── Nested reference models ────────────────────────────────────────────────

class TransactionFarmerRef {
  final int id;
  final String identifier;
  final String firstname;
  final String lastname;

  const TransactionFarmerRef({
    required this.id,
    required this.identifier,
    required this.firstname,
    required this.lastname,
  });

  String get fullName => '$firstname $lastname';

  factory TransactionFarmerRef.fromJson(Map<String, dynamic> json) {
    return TransactionFarmerRef(
      id: json['id'] as int,
      identifier: json['identifier']?.toString() ?? '',
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
    );
  }
}

class TransactionOperatorRef {
  final int id;
  final String name;
  final String email;

  const TransactionOperatorRef({
    required this.id,
    required this.name,
    required this.email,
  });

  factory TransactionOperatorRef.fromJson(Map<String, dynamic> json) {
    return TransactionOperatorRef(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

// ── Transaction item (line in a sale) ─────────────────────────────────────

class TransactionItemModel {
  final int productId;
  final String productName;
  final double quantity;
  final double unitPriceFcfa;
  final double subtotalFcfa;

  const TransactionItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPriceFcfa,
    required this.subtotalFcfa,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      productId: json['product_id'] as int,
      productName: json['product_name']?.toString() ?? '',
      quantity: _toDouble(json['quantity']),
      unitPriceFcfa: _toDouble(json['unit_price_fcfa']),
      subtotalFcfa: _toDouble(json['subtotal_fcfa']),
    );
  }
}

// ── Debt created for credit transactions ──────────────────────────────────

class DebtModel {
  final int id;
  final double amountFcfa;
  final double remainingFcfa;
  final String status;
  final String createdAt;

  const DebtModel({
    required this.id,
    required this.amountFcfa,
    required this.remainingFcfa,
    required this.status,
    required this.createdAt,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as int,
      amountFcfa: _toDouble(json['amount_fcfa']),
      remainingFcfa: _toDouble(json['remaining_fcfa']),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

// ── Full transaction ───────────────────────────────────────────────────────

class TransactionModel {
  final int id;
  final TransactionFarmerRef farmer;
  final TransactionOperatorRef operator;
  final List<TransactionItemModel> items;
  final double totalFcfa;
  final String paymentMethod;
  final double interestRate;
  final double interestAmountFcfa;
  final DebtModel? debt;
  final String createdAt;

  const TransactionModel({
    required this.id,
    required this.farmer,
    required this.operator,
    required this.items,
    required this.totalFcfa,
    required this.paymentMethod,
    required this.interestRate,
    required this.interestAmountFcfa,
    this.debt,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawDebt = json['debt'];
    return TransactionModel(
      id: json['id'] as int,
      farmer: TransactionFarmerRef.fromJson(
          json['farmer'] as Map<String, dynamic>),
      operator: TransactionOperatorRef.fromJson(
          json['operator'] as Map<String, dynamic>),
      items: rawItems
          .map((e) => TransactionItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalFcfa: _toDouble(json['total_fcfa']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      interestRate: _toDouble(json['interest_rate']),
      interestAmountFcfa: _toDouble(json['interest_amount_fcfa']),
      debt: rawDebt is Map<String, dynamic> ? DebtModel.fromJson(rawDebt) : null,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

// ── Input model for checkout request ──────────────────────────────────────

class CheckoutItem {
  final int productId;
  final double quantity;

  const CheckoutItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}
