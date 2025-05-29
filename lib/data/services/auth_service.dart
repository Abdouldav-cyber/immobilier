import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_immo/data/core/config/app_config.dart';
import 'package:gestion_immo/data/models/user.dart';

class AuthService {
  final String baseUrl = AppConfig.apiBaseUrl;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('Début de l\'appel POST à $baseUrl/api/token/ pour connexion');
      final response = await http.post(
        Uri.parse('$baseUrl/api/token/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
        },
      );

      print(
          'Réponse API (POST /api/token/): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, data['access']);
        await prefs.setString(_refreshTokenKey, data['refresh']);
        final userData = await _fetchUserData(data['access']);
        await prefs.setString(_userDataKey, jsonEncode(userData));
        print('Données utilisateur stockées: $userData');
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
      print('Erreur lors de la connexion: $e');
      return {'success': false, 'error': 'Erreur réseau : $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      print(
          'Début de l\'appel POST à $baseUrl/api/auth/registration/ pour inscription');
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

      print(
          'Réponse API (POST /api/auth/registration/): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await saveTokens(authResponse.accessToken, authResponse.refreshToken);
        final prefs = await SharedPreferences.getInstance();
        if (authResponse.user != null) {
          await prefs.setString('username', authResponse.user!.username);
          await prefs.setString('email', authResponse.user!.email);
          await prefs.setString(
              _userDataKey, jsonEncode(authResponse.user!.toJson()));
          print(
              'Données utilisateur stockées lors de l\'inscription: ${authResponse.user!.toJson()}');
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
      print('Erreur lors de l\'inscription: $e');
      return {'success': false, 'error': 'Erreur réseau : $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      print('Simulation de réinitialisation de mot de passe pour $email');
      return {
        'success': true,
        'message': 'Lien de réinitialisation simulé envoyé à $email',
      };
    } catch (e) {
      print(
          'Erreur lors de la simulation de réinitialisation de mot de passe: $e');
      return {'success': false, 'error': 'Erreur simulée : $e'};
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      print('Simulation de connexion avec Google');
      const String simulatedEmail = 'utilisateur@exemple.com';
      const String simulatedAccessToken = 'simulated_access_token';
      const String simulatedRefreshToken = 'simulated_refresh_token';

      final authResponse = AuthResponse(
        accessToken: simulatedAccessToken,
        refreshToken: simulatedRefreshToken,
        user: null,
      );
      await saveTokens(authResponse.accessToken, authResponse.refreshToken);
      final simulatedUserData = {
        'email': simulatedEmail,
        'username': 'utilisateur_google',
        'agence_id': '999',
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(simulatedUserData));
      print('Données utilisateur simulées stockées: $simulatedUserData');
      return authResponse;
    } catch (e) {
      print('Erreur lors de la simulation de connexion Google: $e');
      throw Exception('Erreur lors de la simulation de connexion Google: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.containsKey(_accessTokenKey);
    print('Vérification d\'authentification: $isAuthenticated');
    return isAuthenticated;
  }

  Future<void> logout() async {
    try {
      print('Début de la déconnexion');
      final prefs = await SharedPreferences.getInstance();
      final token = await getAccessToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/logout/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        print(
            'Réponse API (POST /api/logout/): ${response.statusCode} - ${response.body}');
        if (response.statusCode != 200) {
          print('Erreur lors de la déconnexion côté serveur: ${response.body}');
        }
      }
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove('username');
      await prefs.remove('email');
      await prefs.remove(_userDataKey);
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      print(
          'Sauvegarde des tokens: access=$accessToken, refresh=$refreshToken');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      print('Erreur lors de la sauvegarde des tokens: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> getTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokens = {
        'access_token': prefs.getString(_accessTokenKey) ?? '',
        'refresh_token': prefs.getString(_refreshTokenKey) ?? '',
      };
      print('Tokens récupérés: $tokens');
      return tokens;
    } catch (e) {
      print('Erreur lors de la récupération des tokens: $e');
      return {'access_token': '', 'refresh_token': ''};
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      print('Token d\'accès récupéré: $accessToken');
      return accessToken;
    } catch (e) {
      print('Erreur lors de la récupération du token d\'accès: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    return await getAccessToken();
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString == null) {
        print('Aucune donnée utilisateur trouvée dans SharedPreferences');
        // Tenter de recharger les données depuis l'API si un token existe
        final accessToken = await getAccessToken();
        if (accessToken != null) {
          final userData = await _fetchUserData(accessToken);
          await prefs.setString(_userDataKey, jsonEncode(userData));
          print('Données utilisateur rechargées depuis l\'API: $userData');
          return userData;
        }
        return {
          'username': 'Inconnu',
          'email': '',
          'agence_id': null
        }; // Valeur par défaut
      }
      final userData = jsonDecode(userDataString);
      print('Données utilisateur récupérées: $userData');
      return userData;
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      throw Exception(
          'Erreur lors de la récupération des données utilisateur: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(String accessToken) async {
    try {
      print(
          'Début de l\'appel GET à $baseUrl/api/user/ pour récupérer les données utilisateur');
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print(
          'Réponse API (GET /api/user/): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return userData;
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé : token invalide ou expiré');
      }
      throw Exception(
          'Erreur lors de la récupération des données utilisateur: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print(
          'Erreur lors de la récupération des données utilisateur via API: $e');
      throw Exception(
          'Erreur lors de la récupération des données utilisateur via API: $e');
    }
  }
}
