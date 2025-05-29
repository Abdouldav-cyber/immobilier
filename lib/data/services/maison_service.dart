import 'package:gestion_immo/data/services/base_service.dart';

class MaisonService extends BaseService {
  MaisonService() : super('maisons');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'ville': item['ville'],
      'quartier': item['quartier'],
      'google_maps_link': item['google_maps_link'],
      'latitude_degrees': item['latitude_degrees'] ?? 0,
      'latitude_minutes': item['latitude_minutes'] ?? 0,
      'latitude_seconds': item['latitude_seconds'] ?? 0,
      'longitude_degrees': item['longitude_degrees'] ?? 0,
      'longitude_minutes': item['longitude_minutes'] ?? 0,
      'longitude_seconds': item['longitude_seconds'] ?? 0,
      'agence_id': item['agence_id'],
      'immatriculation': item['immatriculation'],
      'type_document_ids': item['type_document_ids'] ?? [],
      'commodite_ids': item['commodite_ids'] ?? [],
      'photos': item['photos'] ?? [],
      'etat': item['etat'] ?? 'Libre', // Ajout de l'état par défaut
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'ville': item['ville'],
      'quartier': item['quartier'],
      'google_maps_link': item['google_maps_link'],
      'latitude_degrees': item['latitude_degrees'] ?? 0,
      'latitude_minutes': item['latitude_minutes'] ?? 0,
      'latitude_seconds': item['latitude_seconds'] ?? 0,
      'longitude_degrees': item['longitude_degrees'] ?? 0,
      'longitude_minutes': item['longitude_minutes'] ?? 0,
      'longitude_seconds': item['longitude_seconds'] ?? 0,
      'agence_id': item['agence_id'],
      'immatriculation': item['immatriculation'],
      'type_document_ids': item['type_document_ids'] ?? [],
      'commodite_ids': item['commodite_ids'] ?? [],
      'photos': item['photos'] ?? [],
      'etat': item['etat'] ?? 'Libre', // Ajout de l'état
    };
    return super.update(id, sanitizedItem);
  }
}
