class PaymentModel {
  final String id;
  final double amount;
  final String date;
  final String locationId;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.locationId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date,
        'location_id': locationId,
      };

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'].toString(),
        amount: (json['amount'] as num).toDouble(),
        date: json['date'] as String,
        locationId: json['location_id'].toString(),
      );
}
