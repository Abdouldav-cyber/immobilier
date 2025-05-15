class AgencyModel {
  final String id;
  final String name;
  final String address;
  final String? phone;

  AgencyModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
      };

  factory AgencyModel.fromJson(Map<String, dynamic> json) => AgencyModel(
        id: json['id'].toString(),
        name: json['name'] as String,
        address: json['address'] as String,
        phone: json['phone'] as String?,
      );
}
