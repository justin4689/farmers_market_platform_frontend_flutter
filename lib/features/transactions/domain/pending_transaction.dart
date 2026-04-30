class PendingTransaction {
  final String id;
  final int farmerId;
  final String farmerName;
  final String paymentMethod;
  final double? interestRate;
  final List<Map<String, dynamic>> items;
  final DateTime createdAt;
  final bool isFailed;
  final String? errorMessage;

  const PendingTransaction({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.paymentMethod,
    this.interestRate,
    required this.items,
    required this.createdAt,
    this.isFailed = false,
    this.errorMessage,
  });

  PendingTransaction copyWith({
    bool? isFailed,
    String? errorMessage,
  }) =>
      PendingTransaction(
        id: id,
        farmerId: farmerId,
        farmerName: farmerName,
        paymentMethod: paymentMethod,
        interestRate: interestRate,
        items: items,
        createdAt: createdAt,
        isFailed: isFailed ?? this.isFailed,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'paymentMethod': paymentMethod,
        'interestRate': interestRate,
        'items': items,
        'createdAt': createdAt.toIso8601String(),
        'isFailed': isFailed,
        'errorMessage': errorMessage,
      };

  factory PendingTransaction.fromJson(Map<String, dynamic> json) =>
      PendingTransaction(
        id: json['id'] as String,
        farmerId: json['farmerId'] as int,
        farmerName: json['farmerName'] as String,
        paymentMethod: json['paymentMethod'] as String,
        interestRate: (json['interestRate'] as num?)?.toDouble(),
        items: (json['items'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isFailed: json['isFailed'] as bool? ?? false,
        errorMessage: json['errorMessage'] as String?,
      );
}
