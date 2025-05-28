import 'package:gestion_immo/data/services/base_service.dart';

class MaisonService extends BaseService {
  MaisonService() : super('maisons');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'adresse': item['adresse'],
      'prix': item['prix'],
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'adresse': item['adresse'],
      'prix': item['prix'],
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
