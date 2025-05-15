class CommodityModel {
  final String id;
  final String name;

  CommodityModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory CommodityModel.fromJson(Map<String, dynamic> json) => CommodityModel(
        id: json['id'].toString(),
        name: json['name'] as String,
      );
}
