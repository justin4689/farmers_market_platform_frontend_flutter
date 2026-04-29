double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

// ── Debt summary (used when listing a farmer's outstanding debts) ──────────

class DebtSummaryModel {
  final int id;
  final int transactionId;
  final double amountFcfa;
  final double remainingFcfa;
  final String status;
  final String createdAt;

  const DebtSummaryModel({
    required this.id,
    required this.transactionId,
    required this.amountFcfa,
    required this.remainingFcfa,
    required this.status,
    required this.createdAt,
  });

  bool get isPaid => status == 'paid';
  bool get isPartial => status == 'partial';

  factory DebtSummaryModel.fromJson(Map<String, dynamic> json) {
    return DebtSummaryModel(
      id: json['id'] as int,
      transactionId: json['transaction_id'] as int,
      amountFcfa: _toDouble(json['amount_fcfa']),
      remainingFcfa: _toDouble(json['remaining_fcfa']),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

// ── Repayment result ───────────────────────────────────────────────────────

class RepaymentModel {
  final int id;
  final int farmerId;
  final double kgReceived;
  final double commodityRateFcfa;
  final double totalFcraCredited;
  final List<int> debtsAffected;
  final String createdAt;

  const RepaymentModel({
    required this.id,
    required this.farmerId,
    required this.kgReceived,
    required this.commodityRateFcfa,
    required this.totalFcraCredited,
    required this.debtsAffected,
    required this.createdAt,
  });

  factory RepaymentModel.fromJson(Map<String, dynamic> json) {
    final rawDebts = json['debts_affected'] as List<dynamic>? ?? [];
    return RepaymentModel(
      id: json['id'] as int,
      farmerId: json['farmer_id'] as int,
      kgReceived: _toDouble(json['kg_received']),
      commodityRateFcfa: _toDouble(json['commodity_rate_fcfa']),
      totalFcraCredited: _toDouble(json['total_fcfa_credited']),
      debtsAffected: rawDebts.map((e) => int.tryParse(e.toString()) ?? 0).toList(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
