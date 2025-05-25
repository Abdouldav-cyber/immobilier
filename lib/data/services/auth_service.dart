import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_immo/data/core/config/app_config.dart';
import 'package:gestion_immo/data/models/user.dart';

class AuthService {
  final String baseUrl = AppConfig.apiBaseUrl;

  // Connexion
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/token/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        return {'success': true};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error':
              errorData['non_field_errors']?.join(' ') ?? 'Erreur de connexion',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau : $e'};
    }
  }

  // Inscription
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/registration/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password1': password,
          'password2': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await saveTokens(authResponse.accessToken, authResponse.refreshToken);
        if (authResponse.user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', authResponse.user!.username);
          await prefs.setString('email', authResponse.user!.email);
        }
        return {'success': true};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['non_field_errors']?.join(' ') ??
              'Erreur d\'inscription',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau : $e'};
    }
  }

  // Réinitialisation de mot de passe (simulation pour le développement)
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      // Simulation : Pas d'appel réel au backend
      return {
        'success': true,
        'message': 'Lien de réinitialisation simulé envoyé à $email',
      };
    } catch (e) {
      return {'success': false, 'error': 'Erreur simulée : $e'};
    }
  }

  // Simulation de la connexion avec Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Simuler une connexion Google (pas d'appel réel à Google)
      const String simulatedEmail = 'utilisateur@exemple.com';
      const String simulatedAccessToken = 'simulated_access_token';
      const String simulatedRefreshToken = 'simulated_refresh_token';

      // Simuler une réponse fictive
      final authResponse = AuthResponse(
        accessToken: simulatedAccessToken,
        refreshToken: simulatedRefreshToken,
        user: null,
      );
      await saveTokens(authResponse.accessToken, authResponse.refreshToken);
      return authResponse;
    } catch (e) {
      throw Exception('Erreur lors de la simulation de connexion Google: $e');
    }
  }

  // Vérification de l'authentification
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
    await prefs.remove('email');
  }

  // Sauvegarder les tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Récupérer les tokens
  Future<Map<String, String>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'access_token': prefs.getString('access_token') ?? '',
      'refresh_token': prefs.getString('refresh_token') ?? '',
    };
  }

  // Récupérer le token d'accès
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
