import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_immo/data/core/config/app_config.dart';

class AuthService {
  final String baseUrl = AppConfig.apiBaseUrl;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  /// Authentifie un utilisateur via email et mot de passe.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Début de l\'appel POST à $baseUrl/api/token/ pour connexion');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/token/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      print(
          'Réponse API (POST /api/token/): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = _decodeJsonResponse(response);
        if (!data.containsKey('access') || !data.containsKey('refresh')) {
          throw Exception('Tokens non trouvés dans la réponse');
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, data['access']);
        await prefs.setString(_refreshTokenKey, data['refresh']);
        print('Token d\'accès sauvegardé: ${data['access']}');
        print('Token de rafraîchissement sauvegardé: ${data['refresh']}');
        final userData = await _fetchUserData(data['access']);
        await prefs.setString(_userDataKey, jsonEncode(userData));
        print('Données utilisateur stockées: $userData');
        return {'success': true};
      } else {
        final errorData = _decodeJsonResponse(response);
        final errorMessage = errorData['detail'] ??
            errorData['non_field_errors']?.join(' ') ??
            'Erreur de connexion';
        print('Erreur de connexion: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('Erreur réseau lors de la connexion: $e');
      return {'success': false, 'error': 'Erreur réseau : $e'};
    }
  }

  /// Inscrit un nouvel utilisateur.
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      print(
          'Début de l\'appel POST à $baseUrl/api/auth/registration/ pour inscription');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/registration/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'username': username,
              'password1': password,
              'password2': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print(
          'Réponse API (POST /api/auth/registration/): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        final data = _decodeJsonResponse(response);
        if (!data.containsKey('access') || !data.containsKey('refresh')) {
          throw Exception('Tokens non trouvés dans la réponse');
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, data['access']);
        await prefs.setString(_refreshTokenKey, data['refresh']);
        print('Token d\'accès sauvegardé: ${data['access']}');
        print('Token de rafraîchissement sauvegardé: ${data['refresh']}');
        final userData = await _fetchUserData(data['access']);
        await prefs.setString(_userDataKey, jsonEncode(userData));
        print('Données utilisateur stockées lors de l\'inscription: $userData');
        return {'success': true};
      } else {
        final errorData = _decodeJsonResponse(response);
        final errorMessage = errorData['detail'] ??
            errorData['non_field_errors']?.join(' ') ??
            'Erreur d\'inscription';
        print('Erreur d\'inscription: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('Erreur réseau lors de l\'inscription: $e');
      return {'success': false, 'error': 'Erreur réseau : $e'};
    }
  }

  /// Réinitialise le mot de passe de l'utilisateur.
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      print(
          'Début de l\'appel POST à $baseUrl/api/auth/password/reset/ pour réinitialisation');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/password/reset/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));

      print(
          'Réponse API (POST /api/auth/password/reset/): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Lien de réinitialisation envoyé à $email',
        };
      } else {
        final errorData = _decodeJsonResponse(response);
        final errorMessage =
            errorData['detail'] ?? 'Erreur lors de la réinitialisation';
        print('Erreur de réinitialisation: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('Erreur réseau lors de la réinitialisation de mot de passe: $e');
      return {'success': false, 'error': 'Erreur réseau : $e'};
    }
  }

  /// Simule la connexion avec Google.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('Simulation de la connexion avec Google');
      // Simule une connexion Google réussie
      final simulatedAccessToken = 'simulated_google_access_token';
      final simulatedRefreshToken = 'simulated_google_refresh_token';
      final simulatedUserData = {
        'username': 'GoogleUser',
        'email': 'googleuser@example.com',
        'agence_id': null,
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, simulatedAccessToken);
      await prefs.setString(_refreshTokenKey, simulatedRefreshToken);
      await prefs.setString(_userDataKey, jsonEncode(simulatedUserData));

      print('Token d\'accès Google simulé sauvegardé: $simulatedAccessToken');
      print(
          'Token de rafraîchissement Google simulé sauvegardé: $simulatedRefreshToken');
      print('Données utilisateur simulées stockées: $simulatedUserData');

      return {'success': true};
    } catch (e) {
      print('Erreur lors de la simulation de la connexion Google: $e');
      return {
        'success': false,
        'error': 'Erreur lors de la simulation Google: $e'
      };
    }
  }

  /// Vérifie si un utilisateur est authentifié.
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    final isAuthenticated = accessToken != null && accessToken.isNotEmpty;
    print('Vérification d\'authentification: $isAuthenticated');
    return isAuthenticated;
  }

  /// Déconnecte l'utilisateur et appelle l'API de déconnexion.
  Future<void> logout() async {
    try {
      print('Début de la déconnexion');
      final token = await getAccessToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/auth/logout/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));
        print(
            'Réponse API (POST /api/auth/logout/): ${response.statusCode} - ${response.body}');
        if (response.statusCode != 200) {
          print('Erreur lors de la déconnexion côté serveur: ${response.body}');
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  /// Sauvegarde les tokens dans SharedPreferences.
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

  /// Récupère les tokens depuis SharedPreferences.
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

  /// Récupère le token d'accès.
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

  /// Récupère les données utilisateur depuis SharedPreferences ou l'API.
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString == null) {
        print('Aucune donnée utilisateur trouvée dans SharedPreferences');
        final accessToken = await getAccessToken();
        if (accessToken != null) {
          final userData = await _fetchUserDataWithRefresh(accessToken);
          await prefs.setString(_userDataKey, jsonEncode(userData));
          print('Données utilisateur rechargées depuis l\'API: $userData');
          return userData;
        }
        return {'username': 'Inconnu', 'email': '', 'agence_id': null};
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

  /// Rafraîchit le token d'accès avec le token de rafraîchissement.
  Future<String?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        print('Aucun token de rafraîchissement disponible');
        await logout();
        return null;
      }

      print(
          'Début de l\'appel POST à $baseUrl/api/token/refresh/ pour rafraîchir le token');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/token/refresh/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      print(
          'Réponse API (POST /api/token/refresh/): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = _decodeJsonResponse(response);
        if (!data.containsKey('access')) {
          throw Exception('Token d\'accès non trouvé dans la réponse');
        }
        final newAccessToken = data['access'];
        await prefs.setString(_accessTokenKey, newAccessToken);
        print('Nouveau token d\'accès sauvegardé: $newAccessToken');
        return newAccessToken;
      } else {
        print('Échec du rafraîchissement du token: ${response.body}');
        await logout();
        return null;
      }
    } catch (e) {
      print('Erreur réseau lors du rafraîchissement du token: $e');
      await logout();
      return null;
    }
  }

  /// Récupère les données utilisateur avec gestion du rafraîchissement du token.
  Future<Map<String, dynamic>> _fetchUserDataWithRefresh(
      String accessToken) async {
    try {
      print(
          'Début de l\'appel GET à $baseUrl/api/user/ avec token: $accessToken');
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      print(
          'Réponse API (GET /api/user/): ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final userData = _decodeJsonResponse(response);
        return userData;
      } else if (response.statusCode == 401) {
        print('Token invalide ou expiré, tentative de rafraîchissement...');
        final newAccessToken = await refreshToken();
        if (newAccessToken != null) {
          return await _fetchUserDataWithRefresh(newAccessToken);
        }
        throw Exception('Non autorisé : impossible de rafraîchir le token');
      } else if (response.statusCode == 404) {
        print('Endpoint non trouvé, vérifiez la configuration du backend');
        throw Exception('Endpoint non trouvé : ${response.body}');
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

  /// Méthode interne pour récupérer les données utilisateur.
  Future<Map<String, dynamic>> _fetchUserData(String accessToken) async {
    return await _fetchUserDataWithRefresh(accessToken);
  }

  /// Décode la réponse JSON avec gestion des erreurs.
  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? data : {};
    } catch (e) {
      print('Erreur de décodage JSON : $e - Réponse : ${response.body}');
      return {'error': 'Réponse non valide', 'detail': response.body};
    }
  }
}
