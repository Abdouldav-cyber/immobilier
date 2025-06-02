import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_immo/data/core/config/app_config.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/data/services/base_service.dart';

class AgenceService extends BaseService {
  final AuthService _authService = AuthService();

  AgenceService() : super('agences');

  Future<Map<String, String>> _getHeaders() async {
    String? accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Utilisateur non authentifié');
    }
    return {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, String>> _getHeadersWithContentType() async {
    String? accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      throw Exception('Utilisateur non authentifié');
    }
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<List<dynamic>> getAll() async {
    final headers = await _getHeaders();
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/agences/'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return _decodeJsonResponse(response);
    } else if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      if (newToken == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final retryHeaders = await _getHeaders();
      final retryResponse = await http
          .get(
            Uri.parse('$baseUrl/api/agences/'),
            headers: retryHeaders,
          )
          .timeout(const Duration(seconds: 10));

      if (retryResponse.statusCode == 200) {
        return _decodeJsonResponse(retryResponse);
      } else {
        throw Exception(
            'Erreur lors de la récupération des agences: ${retryResponse.body}');
      }
    } else {
      throw Exception(
          'Erreur lors de la récupération des agences: ${response.body}');
    }
  }

  @override
  Future<dynamic> create(dynamic item) async {
    final headers = await _getHeadersWithContentType();
    final sanitizedItem = {
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'immatriculation': item['immatriculation']?.toString() ?? '',
      'nom': item['nom']?.toString() ?? '',
    };

    if (item['logo'] != null &&
        item['logo'].isNotEmpty &&
        !item['logo'].startsWith('http')) {
      return createWithImage(item, imagePath: item['logo'], imageField: 'logo');
    }

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/agences/'),
          headers: headers,
          body: jsonEncode(sanitizedItem),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return _decodeJsonResponse(response);
    } else if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      if (newToken == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final retryHeaders = await _getHeadersWithContentType();
      final retryResponse = await http
          .post(
            Uri.parse('$baseUrl/api/agences/'),
            headers: retryHeaders,
            body: jsonEncode(sanitizedItem),
          )
          .timeout(const Duration(seconds: 10));

      if (retryResponse.statusCode == 201) {
        return _decodeJsonResponse(retryResponse);
      } else {
        throw Exception(
            'Erreur lors de la création de l\'agence: ${retryResponse.body}');
      }
    } else {
      throw Exception(
          'Erreur lors de la création de l\'agence: ${response.body}');
    }
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final headers = await _getHeadersWithContentType();
    final sanitizedItem = {
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'immatriculation': item['immatriculation']?.toString() ?? '',
      'nom': item['nom']?.toString() ?? '',
    };

    if (item['logo'] != null && !item['logo'].startsWith('http')) {
      return updateWithImage(id, item,
          imagePath: item['logo'], imageField: 'logo');
    }

    final response = await http
        .put(
          Uri.parse('$baseUrl/api/agences/$id/'),
          headers: headers,
          body: jsonEncode(sanitizedItem),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return _decodeJsonResponse(response);
    } else if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      if (newToken == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final retryHeaders = await _getHeadersWithContentType();
      final retryResponse = await http
          .put(
            Uri.parse('$baseUrl/api/agences/$id/'),
            headers: retryHeaders,
            body: jsonEncode(sanitizedItem),
          )
          .timeout(const Duration(seconds: 10));

      if (retryResponse.statusCode == 200) {
        return _decodeJsonResponse(retryResponse);
      } else {
        throw Exception(
            'Erreur lors de la mise à jour de l\'agence: ${retryResponse.body}');
      }
    } else {
      throw Exception(
          'Erreur lors de la mise à jour de l\'agence: ${response.body}');
    }
  }

  @override
  Future<dynamic> createWithImage(dynamic item,
      {String? imagePath, String? imageField}) async {
    final headers = await _getHeaders();
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/api/agences/'));

    request.fields.addAll({
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'immatriculation': item['immatriculation']?.toString() ?? '',
      'nom': item['nom']?.toString() ?? '',
    });

    if (imagePath != null && imageField != null) {
      request.files
          .add(await http.MultipartFile.fromPath(imageField, imagePath));
    }

    request.headers.addAll(headers);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return _decodeJsonResponse(response);
    } else if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      if (newToken == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final retryHeaders = await _getHeaders();
      var retryRequest =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/api/agences/'));

      retryRequest.fields.addAll(request.fields);
      if (imagePath != null && imageField != null) {
        retryRequest.files
            .add(await http.MultipartFile.fromPath(imageField, imagePath));
      }
      retryRequest.headers.addAll(retryHeaders);

      final retryStreamedResponse = await retryRequest.send();
      final retryResponse =
          await http.Response.fromStream(retryStreamedResponse);

      if (retryResponse.statusCode == 201) {
        return _decodeJsonResponse(retryResponse);
      } else {
        throw Exception(
            'Erreur lors de la création de l\'agence: ${retryResponse.body}');
      }
    } else {
      throw Exception(
          'Erreur lors de la création de l\'agence: ${response.body}');
    }
  }

  @override
  Future<dynamic> updateWithImage(dynamic id, dynamic item,
      {String? imagePath, String? imageField}) async {
    final headers = await _getHeaders();
    var request =
        http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/agences/$id/'));

    request.fields.addAll({
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'immatriculation': item['immatriculation']?.toString() ?? '',
      'nom': item['nom']?.toString() ?? '',
    });

    if (imagePath != null && imageField != null) {
      request.files
          .add(await http.MultipartFile.fromPath(imageField, imagePath));
    }

    request.headers.addAll(headers);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return _decodeJsonResponse(response);
    } else if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      if (newToken == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final retryHeaders = await _getHeaders();
      var retryRequest =
          http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/agences/$id/'));

      retryRequest.fields.addAll(request.fields);
      if (imagePath != null && imageField != null) {
        retryRequest.files
            .add(await http.MultipartFile.fromPath(imageField, imagePath));
      }
      retryRequest.headers.addAll(retryHeaders);

      final retryStreamedResponse = await retryRequest.send();
      final retryResponse =
          await http.Response.fromStream(retryStreamedResponse);

      if (retryResponse.statusCode == 200) {
        return _decodeJsonResponse(retryResponse);
      } else {
        throw Exception(
            'Erreur lors de la mise à jour de l\'agence: ${retryResponse.body}');
      }
    } else {
      throw Exception(
          'Erreur lors de la mise à jour de l\'agence: ${response.body}');
    }
  }

  @override
  Future<void> delete(dynamic id) async {
    final headers = await _getHeaders();
    final response = await http
        .delete(
          Uri.parse('$baseUrl/api/agences/$id/'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      if (newToken == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final retryHeaders = await _getHeaders();
      final retryResponse = await http
          .delete(
            Uri.parse('$baseUrl/api/agences/$id/'),
            headers: retryHeaders,
          )
          .timeout(const Duration(seconds: 10));

      if (retryResponse.statusCode == 204) {
        return;
      } else {
        throw Exception(
            'Erreur lors de la suppression de l\'agence: ${retryResponse.body}');
      }
    } else {
      throw Exception(
          'Erreur lors de la suppression de l\'agence: ${response.body}');
    }
  }

  dynamic _decodeJsonResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data is List ? data : (data is Map ? data : {});
    } catch (e) {
      print('Erreur de décodage JSON : $e - Réponse : ${response.body}');
      throw Exception('Réponse non valide : ${response.body}');
    }
  }
}
