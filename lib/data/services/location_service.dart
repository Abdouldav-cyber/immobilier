import 'package:gestion_immo/data/services/base_service.dart';
import 'package:gestion_immo/data/services/maison_service.dart';

class LocationService extends BaseService {
  LocationService() : super('locations');

  @override
  Future<dynamic> create(Map<String, dynamic> data) async {
    final sanitizedData = {
      'date': data['date'],
      'type_de_document': data['type_de_document'],
      'numero': data['numero'],
      'date_etablissement': data['date_etablissement'],
      'date_expiration': data['date_expiration'],
      'nom': data['nom'],
      'prenom': data['prenom'],
      'client': data['client'],
      'maison_id': data['maison_id'],
    };
    try {
      final result = await super.create(sanitizedData);
      // Mettre à jour l'état de la maison à 'Occuper'
      final maisonService = MaisonService();
      await maisonService.update(data['maison_id'], {'etat': 'Occuper'});
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> update(int id, Map<String, dynamic> data) async {
    final sanitizedData = {
      'date': data['date'],
      'type_de_document': data['type_de_document'],
      'numero': data['numero'],
      'date_etablissement': data['date_etablissement'],
      'date_expiration': data['date_expiration'],
      'nom': data['nom'],
      'prenom': data['prenom'],
      'client': data['client'],
      'maison_id': data['maison_id'],
    };
    try {
      final result = await super.update(id, sanitizedData);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cloturerLocation(int id, int maisonId) async {
    try {
      // Mettre à jour la location avec un statut "Clôturée" (ajouter un champ si nécessaire)
      await super.update(id, {'statut': 'Clôturée'});
      // Mettre à jour l'état de la maison à 'Libre'
      final maisonService = MaisonService();
      await maisonService.update(maisonId, {'etat': 'Libre'});
    } catch (e) {
      rethrow;
    }
  }
}
