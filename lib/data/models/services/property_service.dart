import 'dart:convert';
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:gestion_immo/data/models/bien_model.dart';
import 'package:gestion_immo/data/models/commodity_model.dart';
import 'package:gestion_immo/data/models/commune_model.dart';
import 'package:http/http.dart' as http;
import '../models/bien_model.dart';
import '../models/commune_model.dart';
import '../models/commodity_model.dart';
import '../../core/config/app_config.dart';
import 'auth_service.dart';

class PropertyService {
  final AuthService _authService = AuthService();

  Future<List<BienModel>> fetchProperties() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/maisons/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BienModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des biens : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des biens : $e');
    }
  }

  Future<void> addProperty(BienModel bien) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/maisons/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bien.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Erreur lors de l\'ajout du bien : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du bien : $e');
    }
  }

  Future<List<CommuneModel>> fetchCommunes() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/communes/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CommuneModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des communes : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des communes : $e');
    }
  }

  Future<List<CommodityModel>> fetchCommodities() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/commodites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CommodityModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des commodités : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commodités : $e');
    }
  }
}
