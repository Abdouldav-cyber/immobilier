class CommuneModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  CommuneModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory CommuneModel.fromJson(Map<String, dynamic> json) => CommuneModel(
        id: json['id'].toString(),
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}
