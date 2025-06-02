import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class AgenceService extends BaseService {
  AgenceService() : super('agences');

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  @override
  Future<List<dynamic>> getAll() async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('Utilisateur non authentifié');

    final response = await http.get(
      Uri.parse('$baseUrl/api/agences/'), // Ajout du préfixe /api/
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept':
            'application/json', // Indique que l'on attend une réponse JSON
      },
    );

    if (response.statusCode == 200) {
      return _decodeJsonResponse(response);
    } else {
      throw Exception(
          'Erreur lors de la récupération des agences: ${response.body}');
    }
  }

  @override
  Future<dynamic> create(dynamic item) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('Utilisateur non authentifié');

    final sanitizedItem = {
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'immatriculation': item['immatriculation']?.toString() ?? '',
      'nom': item['nom']?.toString() ?? '',
    };

    // Si un logo est présent, utiliser une requête multipart
    if (item['logo'] != null && item['logo'].isNotEmpty) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/agences/'), // Ajout du préfixe /api/
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(sanitizedItem);
      request.files.add(
        await http.MultipartFile.fromPath(
          'logo',
          item['logo'],
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return _decodeJsonResponseString(responseBody);
      } else {
        throw Exception(
            'Erreur lors de la création de l\'agence: $responseBody');
      }
    } else {
      // Sans logo, utiliser une requête JSON classique
      final response = await http.post(
        Uri.parse('$baseUrl/api/agences/'), // Ajout du préfixe /api/
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(sanitizedItem),
      );

      if (response.statusCode == 201) {
        return _decodeJsonResponse(response);
      } else {
        throw Exception(
            'Erreur lors de la création de l\'agence: ${response.body}');
      }
    }
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('Utilisateur non authentifié');

    final sanitizedItem = {
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'immatriculation': item['immatriculation']?.toString() ?? '',
      'nom': item['nom']?.toString() ?? '',
    };

    if (item['logo'] != null && !item['logo'].startsWith('http')) {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/agences/$id/'), // Ajout du préfixe /api/
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields.addAll(sanitizedItem);
      request.files.add(
        await http.MultipartFile.fromPath(
          'logo',
          item['logo'],
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return _decodeJsonResponseString(responseBody);
      } else {
        throw Exception(
            'Erreur lors de la mise à jour de l\'agence: $responseBody');
      }
    } else {
      final response = await http.put(
        Uri.parse('$baseUrl/api/agences/$id/'), // Ajout du préfixe /api/
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(sanitizedItem),
      );

      if (response.statusCode == 200) {
        return _decodeJsonResponse(response);
      } else {
        throw Exception(
            'Erreur lors de la mise à jour de l\'agence: ${response.body}');
      }
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('Utilisateur non authentifié');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/agences/$id/'), // Ajout du préfixe /api/
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception(
          'Erreur lors de la suppression de l\'agence: ${response.body}');
    }
  }

  /// Décode la réponse JSON avec gestion des erreurs.
  List<dynamic> _decodeJsonResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data is List ? data : [];
    } catch (e) {
      print('Erreur de décodage JSON : $e - Réponse : ${response.body}');
      throw Exception('Réponse non valide : ${response.body}');
    }
  }

  /// Décode une chaîne JSON avec gestion des erreurs.
  dynamic _decodeJsonResponseString(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      return data is Map ? data : {};
    } catch (e) {
      print('Erreur de décodage JSON : $e - Réponse : $responseBody');
      throw Exception('Réponse non valide : $responseBody');
    }
  }
}
