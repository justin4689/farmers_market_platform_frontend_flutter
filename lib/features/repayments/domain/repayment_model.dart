class RepaymentModel {
  final int id;
  final int farmerId;
  final double weightKg;
  final double amountFcfa;
  final String createdAt;

  const RepaymentModel({
    required this.id,
    required this.farmerId,
    required this.weightKg,
    required this.amountFcfa,
    required this.createdAt,
  });

  factory RepaymentModel.fromJson(Map<String, dynamic> json) {
    return RepaymentModel(
      id: json['id'] as int,
      farmerId: json['farmer_id'] as int,
      weightKg: (json['weight_kg'] as num).toDouble(),
      amountFcfa: (json['amount_fcfa'] as num).toDouble(),
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
