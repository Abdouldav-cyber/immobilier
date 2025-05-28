import 'package:gestion_immo/data/services/base_service.dart';

class PenaliteService extends BaseService {
  PenaliteService() : super('penalites');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'montant': item['montant'],
      'description': item['description'],
      'location_id': item['location_id'],
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'montant': item['montant'],
      'description': item['description'],
      'location_id': item['location_id'],
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
