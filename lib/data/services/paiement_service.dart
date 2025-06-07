import 'package:gestion_immo/data/services/base_service.dart';

class PaiementService extends BaseService {
  PaiementService() : super('paiements');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'montant': item['montant']?.toString() ?? '0',
      'date_paiement':
          item['date_paiement']?.toString() ?? '', // Utiliser date_paiement
      'location': item['location']?.toString() ?? '',
      'sup': item['sup'] ?? false,
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'montant': item['montant']?.toString() ?? '0',
      'date_paiement': item['date_paiement']?.toString() ?? '',
      'location': item['location']?.toString() ?? '',
      'sup': item['sup'] ?? false,
    };
    return super.update(id, sanitizedItem);
  }
}
