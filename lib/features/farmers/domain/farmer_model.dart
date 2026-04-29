class FarmerModel {
  final int id;
  final String identifier;
  final String firstname;
  final String lastname;
  final String phoneNumber;
  final double creditLimitFcfa;
  final double totalOutstandingDebt;
  final String createdAt;

  const FarmerModel({
    required this.id,
    required this.identifier,
    required this.firstname,
    required this.lastname,
    required this.phoneNumber,
    required this.creditLimitFcfa,
    required this.totalOutstandingDebt,
    required this.createdAt,
  });

  String get fullName => '$firstname $lastname';

  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      id: json['id'] as int,
      identifier: json['identifier'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      phoneNumber: json['phone_number'] as String,
      creditLimitFcfa: (json['credit_limit_fcfa'] as num).toDouble(),
      totalOutstandingDebt:
          (json['total_outstanding_debt'] as num).toDouble(),
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
