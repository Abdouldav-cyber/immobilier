import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

abstract class BaseService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String endpoint;

  BaseService(this.endpoint);

  // Récupère le token d'authentification depuis AuthService
  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Convertit les champs problématiques (comme IdentityMap) en chaînes
  dynamic _sanitizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) {
        if (value is Map &&
            value.runtimeType.toString().contains('IdentityMap')) {
          // Convertit IdentityMap en String (prend la première valeur si possible)
          return MapEntry(key, value.toString());
        } else if (value is Map<String, dynamic>) {
          return MapEntry(key, _sanitizeData(value));
        } else if (value is List) {
          return MapEntry(
              key, value.map((item) => _sanitizeData(item)).toList());
        }
        return MapEntry(key, value);
      });
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }
    return data;
  }

  // Récupère tous les éléments
  Future<List<dynamic>> getAll() async {
    print('Début de l\'appel GET à /$endpoint/');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      final response = await http
          .get(
            url,
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      print(
          'Réponse API (GET $endpoint): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Données décodées: $data');
        final sanitizedData = _sanitizeData(data);
        print('Données nettoyées: $sanitizedData');
        if (sanitizedData is Map<String, dynamic> &&
            sanitizedData.containsKey('results')) {
          return sanitizedData['results'] is List
              ? sanitizedData['results'] as List<dynamic>
              : [];
        }
        if (sanitizedData is List<dynamic>) return sanitizedData;
        print('Structure de réponse inattendue, retour d\'une liste vide');
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : token invalide ou expiré');
      }
      throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Erreur lors de l\'appel GET à /$endpoint/: $e');
      rethrow;
    }
  }

  // Récupère un élément par ID
  Future<dynamic> getById(int id) async {
    print('Début de l\'appel GET à /$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await http
          .get(
            url,
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      print(
          'Réponse API (GET $endpoint/$id): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _sanitizeData(data);
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : token invalide ou expiré');
      }
      throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Erreur lors de l\'appel GET à /$endpoint/$id/: $e');
      rethrow;
    }
  }

  // Crée un nouvel élément et retourne les données créées
  Future<dynamic> create(Map<String, dynamic> data) async {
    print('Début de l\'appel POST à /$endpoint/ avec données: $data');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      final response = await http
          .post(
            url,
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      print(
          'Réponse API (POST $endpoint): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return _sanitizeData(data);
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : token invalide ou expiré');
      }
      throw Exception(
          'Erreur création: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Erreur lors de l\'appel POST à /$endpoint/: $e');
      rethrow;
    }
  }

  // Crée un nouvel élément avec une image et retourne les données créées
  Future<dynamic> createWithImage(Map<String, dynamic> data,
      {String? imagePath, required String imageField}) async {
    print(
        'Début de l\'appel POST (multipart) à /$endpoint/ avec données: $data et image: $imagePath');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(await _getHeaders());

      // Ajouter les champs textuels
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Ajouter l'image si elle est sélectionnée
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          imageField,
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response =
          await request.send().timeout(const Duration(seconds: 10));
      final responseBody = await response.stream.bytesToString();
      print(
          'Réponse API (POST multipart $endpoint): ${response.statusCode} - $responseBody');
      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return _sanitizeData(data);
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : token invalide ou expiré');
      }
      throw Exception(
          'Erreur création: ${response.statusCode} - $responseBody');
    } catch (e) {
      print('Erreur lors de l\'appel POST multipart à /$endpoint/: $e');
      rethrow;
    }
  }

  // Met à jour un élément existant et retourne les données mises à jour
  Future<dynamic> update(int id, Map<String, dynamic> data) async {
    print('Début de l\'appel PUT à /$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await http
          .put(
            url,
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      print(
          'Réponse API (PUT $endpoint): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _sanitizeData(data);
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : token invalide ou expiré');
      }
      throw Exception(
          'Erreur modification: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Erreur lors de l\'appel PUT à /$endpoint/$id/: $e');
      rethrow;
    }
  }

  // Met à jour le statut d'un élément (par exemple, pour fermer une location)
  Future<dynamic> updateStatus(
      int id, String statusField, dynamic statusValue) async {
    print('Début de l\'appel PUT pour mise à jour du statut à /$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await http
          .put(
            url,
            headers: await _getHeaders(),
            body: jsonEncode({statusField: statusValue}),
          )
          .timeout(const Duration(seconds: 10));
      print(
          'Réponse API (PUT $endpoint status): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _sanitizeData(data);
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : token invalide ou expiré');
      }
      throw Exception(
          'Erreur mise à jour statut: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print(
          'Erreur lors de l\'appel PUT pour mise à jour statut à /$endpoint/$id/: $e');
      rethrow;
    }
  }

  // Supprime un élément
  Future<void> delete(int id) async {
    print('Début de l\'appel DELETE à /$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await http
          .delete(
            url,
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      print(
          'Réponse API (DELETE $endpoint): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : token invalide ou expiré');
      }
      throw Exception(
          'Erreur suppression: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Erreur lors de l\'appel DELETE à /$endpoint/$id/: $e');
      rethrow;
    }
  }
}
