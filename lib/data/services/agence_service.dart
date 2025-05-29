import 'package:gestion_immo/data/services/base_service.dart';

class AgenceService extends BaseService {
  AgenceService() : super('agences');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'logo': item['logo'],
      'ville': item['ville'],
      'quartier': item['quartier'],
      'google_maps_link': item['google_maps_link'],
      'immatriculation': item['immatriculation'],
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'logo': item['logo'],
      'ville': item['ville'],
      'quartier': item['quartier'],
      'google_maps_link': item['google_maps_link'],
      'immatriculation': item['immatriculation'],
    };
    return super.update(id, sanitizedItem);
  }
}
