import 'package:gestion_immo/data/services/base_service.dart';

class LocationService extends BaseService {
  LocationService() : super('locations');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'dateDebut': item['dateDebut'],
      'dateFin': item['dateFin'],
      'status': item['status'] ?? 'open',
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'dateDebut': item['dateDebut'],
      'dateFin': item['dateFin'],
      'status': item['status'] ?? 'open',
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
