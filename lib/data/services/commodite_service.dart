import 'package:gestion_immo/data/services/base_service.dart';

class CommoditeService extends BaseService {
  CommoditeService() : super('commodites');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'description': item['description'],
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'description': item['description'],
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
