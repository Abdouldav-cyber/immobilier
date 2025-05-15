import 'dart:convert';
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:gestion_immo/data/models/agency_model.dart';
import 'package:http/http.dart' as http;
import '../models/agency_model.dart';
import '../../core/config/app_config.dart';
import 'auth_service.dart';

class AgencyService {
  final AuthService _authService = AuthService();

  Future<List<AgencyModel>> fetchAgencies() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/agences/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AgencyModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des agences : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des agences : $e');
    }
  }

  Future<void> addAgency(AgencyModel agency) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/agences/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(agency.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Erreur lors de l\'ajout de l\'agence : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'agence : $e');
    }
  }
}
