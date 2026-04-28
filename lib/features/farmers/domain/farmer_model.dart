class FarmerModel {
  final int id;
  final String name;
  final String phone;
  final String? village;
  final double totalDebt;

  const FarmerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.village,
    this.totalDebt = 0,
  });

  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      village: json['village'] as String?,
      totalDebt: (json['total_debt'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (village != null) 'village': village,
      };
}

class DebtModel {
  final int id;
  final String description;
  final double amount;
  final String date;

  const DebtModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as int,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      date: json['created_at'] as String? ?? '',
    );
  }
}
