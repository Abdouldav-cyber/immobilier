class LocationModel {
  final String id;
  final String dateDebut;
  final String? dateFin;
  final double montant;
  final String clientId;
  final String bienId;

  LocationModel({
    required this.id,
    required this.dateDebut,
    this.dateFin,
    required this.montant,
    required this.clientId,
    required this.bienId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date_debut': dateDebut,
        'date_fin': dateFin,
        'montant': montant,
        'client_id': clientId,
        'bien_id': bienId,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json['id'].toString(),
        dateDebut: json['date_debut'] as String,
        dateFin: json['date_fin'] as String?,
        montant: (json['montant'] as num).toDouble(),
        clientId: json['client_id'].toString(),
        bienId: json['bien_id'].toString(),
      );
}
