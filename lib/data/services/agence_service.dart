import 'package:gestion_immo/data/services/base_service.dart';

class AgenceService extends BaseService {
  AgenceService() : super('agences');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'adresse': item['adresse'],
      'email': item['email'],
      'telephone': item['telephone'],
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'adresse': item['adresse'],
      'email': item['email'],
      'telephone': item['telephone'],
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
