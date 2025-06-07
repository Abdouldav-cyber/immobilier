import 'package:gestion_immo/data/services/base_service.dart';

class PenaliteService extends BaseService {
  PenaliteService() : super('penalites');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'montant': item['montant']?.toString() ?? '0',
      'description': item['description']?.toString() ?? '',
      'route': item['route']?.toString() ?? '',
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'montant': item['montant']?.toString() ?? '0',
      'description': item['description']?.toString() ?? '',
      'route': item['route']?.toString() ?? '',
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
