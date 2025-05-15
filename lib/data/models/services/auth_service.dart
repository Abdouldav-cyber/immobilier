import 'dart:convert';
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class AuthService {
  Future<void> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      } else {
        throw Exception('Erreur de connexion : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  Future<void> signUp(
      String email, String password, String firstName, String lastName) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email,
          'email': email,
          'password1': password,
          'password2': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Erreur d\'inscription : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur d\'inscription : $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/password/reset/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la demande de réinitialisation : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la demande de réinitialisation : $e');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
