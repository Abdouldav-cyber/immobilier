import 'dart:convert';
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:gestion_immo/data/models/payment_model.dart';
import 'package:gestion_immo/data/models/penalty_model.dart';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';
import '../models/penalty_model.dart';
import '../../core/config/app_config.dart';
import 'auth_service.dart';

class PaymentService {
  final AuthService _authService = AuthService();

  Future<List<PaymentModel>> fetchPayments() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/paiements/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PaymentModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des paiements : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des paiements : $e');
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/paiements/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payment.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Erreur lors de l\'ajout du paiement : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du paiement : $e');
    }
  }

  Future<List<PenaltyModel>> fetchPenalties() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/penalites/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PenaltyModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des pénalités : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des pénalités : $e');
    }
  }
}
