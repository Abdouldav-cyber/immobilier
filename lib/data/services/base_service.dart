import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:http_parser/http_parser.dart';

abstract class BaseService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final String endpoint;

  BaseService(this.endpoint);

  Future<List<dynamic>> getAll() async {
    print('Début de l\'appel GET à /$endpoint/');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      ).timeout(const Duration(seconds: 10));
      print(
          'Réponse API (GET $endpoint): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('results')) {
          return data['results'] as List<dynamic>;
        }
        if (data is List<dynamic>) return data;
        throw Exception('Structure de réponse inattendue');
      }
      throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Erreur lors de l\'appel GET à /$endpoint/: $e');
      rethrow;
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    print('Début de l\'appel POST à /$endpoint/ avec données: $data');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      print(
          'Réponse API (POST $endpoint): ${response.statusCode} - ${response.body}');
      if (response.statusCode != 201)
        throw Exception(
            'Erreur création: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Erreur lors de l\'appel POST à /$endpoint/: $e');
      rethrow;
    }
  }

  Future<void> createWithImage(Map<String, dynamic> data,
      {String? imagePath, required String imageField}) async {
    print(
        'Début de l\'appel POST (multipart) à /$endpoint/ avec données: $data et image: $imagePath');
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      var request = http.MultipartRequest('POST', url);

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
      if (response.statusCode != 201)
        throw Exception(
            'Erreur création: ${response.statusCode} - $responseBody');
    } catch (e) {
      print('Erreur lors de l\'appel POST multipart à /$endpoint/: $e');
      rethrow;
    }
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    print('Début de l\'appel PUT à /$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      print(
          'Réponse API (PUT $endpoint): ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200)
        throw Exception('Erreur modification: ${response.statusCode}');
    } catch (e) {
      print('Erreur lors de l\'appel PUT à /$endpoint/$id/: $e');
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    print('Début de l\'appel DELETE à /$endpoint/$id/');
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      ).timeout(const Duration(seconds: 10));
      print(
          'Réponse API (DELETE $endpoint): ${response.statusCode} - ${response.body}');
      if (response.statusCode != 204)
        throw Exception('Erreur suppression: ${response.statusCode}');
    } catch (e) {
      print('Erreur lors de l\'appel DELETE à /$endpoint/$id/: $e');
      rethrow;
    }
  }
}
