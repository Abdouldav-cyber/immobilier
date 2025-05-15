class ClientModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;

  ClientModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
      };

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        id: json['id'].toString(),
        nom: json['nom'] as String,
        prenom: json['prenom'] as String,
        email: json['email'] as String,
        telephone: json['telephone'] as String?,
      );
}
