import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class MaisonService extends BaseService {
  MaisonService() : super('maisons');

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'latitude_degrees': item['latitude_degrees'] ?? 0,
      'latitude_minutes': item['latitude_minutes'] ?? 0,
      'latitude_seconds': item['latitude_seconds'] ?? 0,
      'longitude_degrees': item['longitude_degrees'] ?? 0,
      'longitude_minutes': item['longitude_minutes'] ?? 0,
      'longitude_seconds': item['longitude_seconds'] ?? 0,
      'agence_id': item['agence_id']?.toString() ?? '',
      'coordonnees_point': item['coordonnees_point']?.toString() ?? '',
      'etat': (item['etat']?.toString() ?? 'LIBRE').toUpperCase(),
      'photos': item['photos'] != null ? List<String>.from(item['photos']) : [],
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'latitude_degrees': item['latitude_degrees'] ?? 0,
      'latitude_minutes': item['latitude_minutes'] ?? 0,
      'latitude_seconds': item['latitude_seconds'] ?? 0,
      'longitude_degrees': item['longitude_degrees'] ?? 0,
      'longitude_minutes': item['longitude_minutes'] ?? 0,
      'longitude_seconds': item['longitude_seconds'] ?? 0,
      'agence_id': item['agence_id']?.toString() ?? '',
      'coordonnees_point': item['coordonnees_point']?.toString() ?? '',
      'etat': (item['etat']?.toString() ?? 'LIBRE').toUpperCase(),
      'photos': item['photos'] != null ? List<String>.from(item['photos']) : [],
    };
    return super.update(id, sanitizedItem);
  }

  @override
  Future<dynamic> createWithImage(dynamic item,
      {String? imagePath, String? imageField}) async {
    final url = Uri.parse('$baseUrl/$endpoint/');
    final headers = await _getHeaders();
    var request = http.MultipartRequest('POST', url);

    // Ajouter les champs texte
    request.fields.addAll({
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'latitude_degrees': (item['latitude_degrees'] ?? 0).toString(),
      'latitude_minutes': (item['latitude_minutes'] ?? 0).toString(),
      'latitude_seconds': (item['latitude_seconds'] ?? 0).toString(),
      'longitude_degrees': (item['longitude_degrees'] ?? 0).toString(),
      'longitude_minutes': (item['longitude_minutes'] ?? 0).toString(),
      'longitude_seconds': (item['longitude_seconds'] ?? 0).toString(),
      'agence_id': item['agence_id']?.toString() ?? '',
      'coordonnees_point': item['coordonnees_point']?.toString() ?? '',
      'etat': (item['etat']?.toString() ?? 'LIBRE').toUpperCase(),
    });

    // Ajouter les fichiers images (plusieurs photos)
    if (item['photos'] != null && (item['photos'] as List).isNotEmpty) {
      for (var photoPath in item['photos']) {
        request.files.add(
          await http.MultipartFile.fromPath('photos', photoPath),
        );
      }
    }

    request.headers.addAll(headers);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la création: ${response.body}');
    }
  }

  @override
  Future<dynamic> updateWithImage(dynamic id, dynamic item,
      {String? imagePath, String? imageField}) async {
    final url = Uri.parse('$baseUrl/$endpoint/$id/');
    final headers = await _getHeaders();
    var request = http.MultipartRequest('PUT', url);

    // Ajouter les champs texte
    request.fields.addAll({
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'latitude_degrees': (item['latitude_degrees'] ?? 0).toString(),
      'latitude_minutes': (item['latitude_minutes'] ?? 0).toString(),
      'latitude_seconds': (item['latitude_seconds'] ?? 0).toString(),
      'longitude_degrees': (item['longitude_degrees'] ?? 0).toString(),
      'longitude_minutes': (item['longitude_minutes'] ?? 0).toString(),
      'longitude_seconds': (item['longitude_seconds'] ?? 0).toString(),
      'agence_id': item['agence_id']?.toString() ?? '',
      'coordonnees_point': item['coordonnees_point']?.toString() ?? '',
      'etat': (item['etat']?.toString() ?? 'LIBRE').toUpperCase(),
    });

    // Ajouter les fichiers images (plusieurs photos)
    if (item['photos'] != null && (item['photos'] as List).isNotEmpty) {
      for (var photoPath in item['photos']) {
        request.files.add(
          await http.MultipartFile.fromPath('photos', photoPath),
        );
      }
    }

    request.headers.addAll(headers);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.body}');
    }
  }
}
