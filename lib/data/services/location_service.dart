import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService extends BaseService {
  LocationService() : super('locations');

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'maison_id': item['maison_id']?.toString() ?? '',
      'locataire': item['locataire']?.toString() ?? '',
      'date_debut': item['date_debut']?.toString() ?? '',
      'date_fin': item['date_fin']?.toString() ?? '',
      'montant_loyer': item['montant_loyer']?.toString() ?? '0',
      'date': item['date']?.toString() ?? '',
      'type_document': item['type_document']?.toString() ?? '',
      'nom_client': item['nom_client']?.toString() ?? '',
      'prenom_client': item['prenom_client']?.toString() ?? '',
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'maison_id': item['maison_id']?.toString() ?? '',
      'locataire': item['locataire']?.toString() ?? '',
      'date_debut': item['date_debut']?.toString() ?? '',
      'date_fin': item['date_fin']?.toString() ?? '',
      'montant_loyer': item['montant_loyer']?.toString() ?? '0',
      'date': item['date']?.toString() ?? '',
      'type_document': item['type_document']?.toString() ?? '',
      'nom_client': item['nom_client']?.toString() ?? '',
      'prenom_client': item['prenom_client']?.toString() ?? '',
    };
    return super.update(id, sanitizedItem);
  }

  Future<dynamic> cloturerLocation(int id, int maisonId) async {
    final url = Uri.parse('$baseUrl/locations/$id/cloturer/');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'maison_id': maisonId, 'statut': 'CLOTUREE'}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la clôture: ${response.body}');
    }
  }
}
