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
      identifier: json['identifier']?.toString() ?? '',
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      creditLimitFcfa: (json['credit_limit_fcfa'] as num?)?.toDouble() ?? 0,
      totalOutstandingDebt: (json['total_outstanding_debt'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'identifier': identifier,
        'firstname': firstname,
        'lastname': lastname,
        'phone_number': phoneNumber,
        'credit_limit_fcfa': creditLimitFcfa,
        'total_outstanding_debt': totalOutstandingDebt,
        'created_at': createdAt,
      };
}
