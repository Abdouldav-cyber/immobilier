import 'dart:convert';
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:gestion_immo/data/models/location_model.dart';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../../core/config/app_config.dart';
import 'auth_service.dart';

class LocationService {
  final AuthService _authService = AuthService();

  Future<List<LocationModel>> fetchLocations() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/locations/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LocationModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des locations : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des locations : $e');
    }
  }

  Future<void> addLocation(LocationModel location) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/locations/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(location.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Erreur lors de l\'ajout de la location : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la location : $e');
    }
  }
}
