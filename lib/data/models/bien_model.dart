class BienModel {
  final String id;
  final String designation;
  final String adresse;
  final String? ville;
  final int? superficie;
  final double loyer;
  final String? communeId;
  final List<String> photos;
  final List<String> commodites;
  final double? latitude;
  final double? longitude;

  BienModel({
    required this.id,
    required this.designation,
    required this.adresse,
    this.ville,
    this.superficie,
    required this.loyer,
    this.communeId,
    required this.photos,
    required this.commodites,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'designation': designation,
        'adresse': adresse,
        'ville': ville,
        'superficie': superficie,
        'loyer': loyer,
        'commune_id': communeId,
        'photos': photos,
        'commodites': commodites,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory BienModel.fromJson(Map<String, dynamic> json) => BienModel(
        id: json['id'].toString(),
        designation: json['designation'] as String,
        adresse: json['adresse'] as String,
        ville: json['ville'] as String?,
        superficie: json['superficie'] as int?,
        loyer: (json['loyer'] as num).toDouble(),
        communeId: json['commune_id']?.toString(),
        photos: List<String>.from(json['photos'] as List? ?? []),
        commodites: List<String>.from(json['commodites'] as List? ?? []),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
