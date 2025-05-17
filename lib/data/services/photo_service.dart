import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:gestion_immo/data/services/auth_service.dart';

class PhotoService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final AuthService _authService = AuthService();

  Future<List<dynamic>> getPhotos() async {
    print('Début de l\'appel à /photos/');
    final url = Uri.parse('$baseUrl/photos/');
    final token = await _authService.getAccessToken();
    if (token == null) {
      await _authService.simulateLogin();
      return getPhotos();
    }
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      print('Réponse API (photos): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'appel à /photos/: $e');
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('SocketException')) {
        throw Exception(
            'Erreur réseau : Impossible de se connecter au serveur à $baseUrl.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Erreur : Le serveur n\'a pas répondu dans les 10 secondes.');
      }
      throw Exception('Erreur lors de l\'appel à /photos/: $e');
    }
  }
}
