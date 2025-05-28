import 'package:gestion_immo/data/services/base_service.dart';

class CommuneService extends BaseService {
  CommuneService() : super('communes');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'code_postal': item['code_postal'] ?? '',
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'code_postal': item['code_postal'] ?? '',
    };
    return super.update(id, sanitizedItem);
  }
}
