import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

abstract class BaseService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String endpoint;

  BaseService(this.endpoint);

  /// Récupère les en-têtes avec le token d'authentification.
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    String? token = await AuthService().getAccessToken();
    final headers = <String, String>{};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Convertit les champs problématiques en chaînes.
  dynamic _sanitizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) {
        if (value is Map &&
            value.runtimeType.toString().contains('IdentityMap')) {
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

  /// Récupère tous les éléments avec gestion du rafraîchissement du token.
  Future<dynamic> getAll() async {
    print('Début de l\'appel GET à $baseUrl/$endpoint/');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      final response = await _performGetRequest(url);
      print('Données décodées: ${response.body}');
      final data = jsonDecode(response.body);
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
    } catch (e) {
      print('Erreur lors de l\'appel GET à $baseUrl/$endpoint/: $e');
      rethrow;
    }
  }

  /// Récupère un élément par ID avec gestion du rafraîchissement du token.
  Future<dynamic> getById(int id) async {
    print('Début de l\'appel GET à $baseUrl/$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await _performGetRequest(url);
      final data = jsonDecode(response.body);
      return _sanitizeData(data);
    } catch (e) {
      print('Erreur lors de l\'appel GET à $baseUrl/$endpoint/$id/: $e');
      rethrow;
    }
  }

  /// Crée un nouvel élément et retourne les données créées.
  Future<dynamic> create(Map<String, dynamic> data) async {
    print('Début de l\'appel POST à $baseUrl/$endpoint/ avec données: $data');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      final response = await _performPostRequest(url, data);
      final createdData = jsonDecode(response.body);
      return _sanitizeData(createdData);
    } catch (e) {
      print('Erreur lors de l\'appel POST à $baseUrl/$endpoint/: $e');
      rethrow;
    }
  }

  /// Crée un nouvel élément avec une image et retourne les données créées.
  Future<dynamic> createWithImage(Map<String, dynamic> data,
      {String? imagePath, required String imageField}) async {
    print(
        'Début de l\'appel POST (multipart) à $baseUrl/$endpoint/ avec données: $data et image: $imagePath');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      var request = http.MultipartRequest('POST', url);
      final headers = await _getHeaders(isMultipart: true);
      request.headers.addAll(headers);
      print('En-têtes de la requête: ${request.headers}');

      // Ajouter les champs textuels
      final sanitizedData = _sanitizeData(data);
      print('Données nettoyées avant envoi: $sanitizedData');
      sanitizedData.forEach((key, value) {
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
      }
      throw Exception(
          'Erreur création: ${response.statusCode} - $responseBody');
    } catch (e) {
      print('Erreur lors de l\'appel POST multipart à $baseUrl/$endpoint/: $e');
      rethrow;
    }
  }

  /// Met à jour un élément existant et retourne les données mises à jour.
  Future<dynamic> update(int id, Map<String, dynamic> data) async {
    print(
        'Début de l\'appel PUT à $baseUrl/$endpoint/$id/ avec données: $data');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await _performPutRequest(url, data);
      final updatedData = jsonDecode(response.body);
      return _sanitizeData(updatedData);
    } catch (e) {
      print('Erreur lors de l\'appel PUT à $baseUrl/$endpoint/$id/: $e');
      rethrow;
    }
  }

  /// Met à jour le statut d'un élément (par exemple, pour fermer une location).
  Future<dynamic> updateStatus(
      int id, String statusField, dynamic statusValue) async {
    print(
        'Début de l\'appel PUT pour mise à jour du statut à $baseUrl/$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    final data = {statusField: statusValue};
    try {
      final response = await _performPutRequest(url, data);
      final updatedData = jsonDecode(response.body);
      return _sanitizeData(updatedData);
    } catch (e) {
      print(
          'Erreur lors de l\'appel PUT pour mise à jour statut à $baseUrl/$endpoint/$id/: $e');
      rethrow;
    }
  }

  /// Supprime un élément.
  Future<void> delete(int id) async {
    print('Début de l\'appel DELETE à $baseUrl/$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await _performDeleteRequest(url);
      if (response.statusCode != 204) {
        throw Exception(
            'Erreur suppression: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'appel DELETE à $baseUrl/$endpoint/$id/: $e');
      rethrow;
    }
  }

  /// Effectue une requête GET avec gestion du rafraîchissement du token.
  Future<http.Response> _performGetRequest(Uri url) async {
    final headers = await _getHeaders();
    print('En-têtes de la requête: $headers');
    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 10));
    print('Réponse API (GET $url): ${response.statusCode} - ${response.body}');
    return response;
  }

  /// Effectue une requête POST avec gestion du rafraîchissement du token.
  Future<http.Response> _performPostRequest(
      Uri url, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    print('En-têtes de la requête: $headers');
    final sanitizedData = _sanitizeData(data);
    print('Données nettoyées avant envoi: $sanitizedData');
    final response = await http
        .post(
          url,
          headers: headers,
          body: jsonEncode(sanitizedData),
        )
        .timeout(const Duration(seconds: 10));
    print('Réponse API (POST $url): ${response.statusCode} - ${response.body}');
    return response;
  }

  /// Effectue une requête PUT avec gestion du rafraîchissement du token.
  Future<http.Response> _performPutRequest(
      Uri url, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    print('En-têtes de la requête: $headers');
    final sanitizedData = _sanitizeData(data);
    print('Données nettoyées avant envoi: $sanitizedData');
    final response = await http
        .put(
          url,
          headers: headers,
          body: jsonEncode(sanitizedData),
        )
        .timeout(const Duration(seconds: 10));
    print('Réponse API (PUT $url): ${response.statusCode} - ${response.body}');
    return response;
  }

  /// Effectue une requête DELETE avec gestion du rafraîchissement du token.
  Future<http.Response> _performDeleteRequest(Uri url) async {
    final headers = await _getHeaders();
    print('En-têtes de la requête: $headers');
    final response = await http
        .delete(url, headers: headers)
        .timeout(const Duration(seconds: 10));
    print(
        'Réponse API (DELETE $url): ${response.statusCode} - ${response.body}');
    return response;
  }
}
