import 'package:gestion_immo/data/services/base_service.dart';
import 'package:http/http.dart' as http;

class LocationService extends BaseService {
  LocationService() : super('locations'); // Endpoint correct

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'maison_id': item['maison_id'],
      'locataire': item['locataire'],
      'date_debut': item['date_debut'],
      'montant': item['montant'],
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'maison_id': item['maison_id'],
      'locataire': item['locataire'],
      'date_debut': item['date_debut'],
      'montant': item['montant'],
    };
    return super.update(id, sanitizedItem);
  }

  Future<void> closeLocation(dynamic id) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/locations/$id/cloturer/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Ajoutez un token d'authentification si nécessaire
        // 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la clôture de la location: ${response.body}');
    }
  }
}
