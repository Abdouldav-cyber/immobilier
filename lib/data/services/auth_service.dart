import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_immo/core/config/app_config.dart';

class AuthService {
  final String baseUrl = AppConfig.apiBaseUrl;

  // Simuler un jeton d'accès (remplacez par le jeton obtenu via Postman)
  Future<void> simulateLogin() async {
    final prefs = await SharedPreferences.getInstance();
    // Remplacez ce jeton par celui obtenu via Postman
    const String simulatedAccessToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // À remplacer
    await prefs.setString('access_token', simulatedAccessToken);
    print('Jeton simulé stocké: $simulatedAccessToken');
  }

  // Méthode pour appeler /maisons/
  Future<List<dynamic>> getMaisons() async {
    print('Début de l\'appel à /maisons/');
    final url = Uri.parse('$baseUrl/maisons/');
    final token = await getAccessToken();
    if (token == null) {
      throw Exception(
          'Aucun jeton d\'accès disponible. Simulez une connexion d\'abord.');
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
      print('Réponse API (maisons): ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'appel à /maisons/: $e');
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('SocketException')) {
        throw Exception(
            'Erreur réseau : Impossible de se connecter au serveur à $baseUrl. Vérifiez si le serveur est en cours d\'exécution et si CORS est configuré correctement.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Erreur : Le serveur n\'a pas répondu dans les 10 secondes. Vérifiez votre connexion ou le serveur.');
      }
      throw Exception('Erreur lors de l\'appel à /maisons/: $e');
    }
  }

  // Méthode pour obtenir le token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('Jeton d\'accès récupéré: $token');
    return token;
  }

  // Gardons les méthodes existantes pour l'authentification (à revoir plus tard)
  Future<void> signIn(String email, String password) async {
    print('Début de la connexion avec email: $email');
    print('URL utilisée: $baseUrl/api/auth/login/');
    final url = Uri.parse('$baseUrl/api/auth/login/');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: 10));
      print(
          'Réponse API (connexion): ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        print(
            'Connexion réussie, jetons stockés: access=${data['access']}, refresh=${data['refresh']}');
      } else {
        throw Exception(
            'Erreur API: ${response.statusCode} - ${jsonDecode(response.body)['non_field_errors']?.join(' ') ?? 'Identifiants incorrects'}');
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('SocketException')) {
        throw Exception(
            'Erreur réseau : Impossible de se connecter au serveur à $baseUrl. Vérifiez si le serveur est en cours d\'exécution et si CORS est configuré correctement.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Erreur : Le serveur n\'a pas répondu dans les 10 secondes. Vérifiez votre connexion ou le serveur.');
      }
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  Future<void> signUp(
      String email, String password, String firstName, String lastName) async {
    print('Début de l\'inscription avec email: $email');
    print('URL utilisée: $baseUrl/api/auth/registration/');
    final url = Uri.parse('$baseUrl/api/auth/registration/');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password1': password,
              'password2': password,
              'first_name': firstName,
              'last_name': lastName,
            }),
          )
          .timeout(Duration(seconds: 10));
      print(
          'Réponse API (inscription): ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        print('Inscription réussie, jetons stockés');
      } else {
        throw Exception(
            'Erreur API: ${response.statusCode} - ${jsonDecode(response.body)['non_field_errors']?.join(' ') ?? 'Données invalides'}');
      }
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('SocketException')) {
        throw Exception(
            'Erreur réseau : Impossible de se connecter au serveur à $baseUrl. Vérifiez si le serveur est en cours d\'exécution et si CORS est configuré correctement.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Erreur : Le serveur n\'a pas répondu dans les 10 secondes. Vérifiez votre connexion ou le serveur.');
      }
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    print('Début de la réinitialisation avec email: $email');
    print('URL utilisée: $baseUrl/api/auth/password/reset/');
    final url = Uri.parse('$baseUrl/api/auth/password/reset/');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(Duration(seconds: 10));
      print(
          'Réponse API (réinitialisation): ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur API: ${response.statusCode} - ${jsonDecode(response.body)['email']?.join(' ') ?? 'Email invalide'}');
      }
      print('Demande de réinitialisation réussie');
    } catch (e) {
      print('Erreur lors de la réinitialisation: $e');
      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('SocketException')) {
        throw Exception(
            'Erreur réseau : Impossible de se connecter au serveur à $baseUrl. Vérifiez si le serveur est en cours d\'exécution et si CORS est configuré correctement.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Erreur : Le serveur n\'a pas répondu dans les 10 secondes. Vérifiez votre connexion ou le serveur.');
      }
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }
}
