class PenaltyModel {
  final String id;
  final double amount;
  final String reason;
  final String locationId;

  PenaltyModel({
    required this.id,
    required this.amount,
    required this.reason,
    required this.locationId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'reason': reason,
        'location_id': locationId,
      };

  factory PenaltyModel.fromJson(Map<String, dynamic> json) => PenaltyModel(
        id: json['id'].toString(),
        amount: (json['amount'] as num).toDouble(),
        reason: json['reason'] as String,
        locationId: json['location_id'].toString(),
      );
}
