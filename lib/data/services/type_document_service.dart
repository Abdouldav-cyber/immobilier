import 'package:gestion_immo/data/services/base_service.dart';

class TypeDocumentService extends BaseService {
  TypeDocumentService() : super('type_documents');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'description': item['description'] ?? '',
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'nom': item['nom'],
      'description': item['description'] ?? '',
    };
    return super.update(id, sanitizedItem);
  }
}
