import 'package:gestion_immo/data/services/base_service.dart';

class CommoditeMaisonService extends BaseService {
  CommoditeMaisonService() : super('commodite_maisons');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'maison_id': item['maison_id'],
      'commodite_id': item['commodite_id'],
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'maison_id': item['maison_id'],
      'commodite_id': item['commodite_id'],
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
