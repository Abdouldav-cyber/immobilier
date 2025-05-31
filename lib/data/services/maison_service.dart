import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestion_immo/data/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaisonService extends BaseService {
  MaisonService() : super('maisons');

  @override
  Future<dynamic> create(dynamic item) async {
    final sanitizedItem = {
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'latitude_degrees': item['latitude_degrees'] ?? 0,
      'latitude_minutes': item['latitude_minutes'] ?? 0,
      'latitude_seconds': item['latitude_seconds'] ?? 0,
      'longitude_degrees': item['longitude_degrees'] ?? 0,
      'longitude_minutes': item['longitude_minutes'] ?? 0,
      'longitude_seconds': item['longitude_seconds'] ?? 0,
      'agence_id': item['agence_id']?.toString() ?? '',
      'coordonnees_point': item['coordonnees_point']?.toString() ?? '',
      'etat': (item['etat']?.toString() ?? 'LIBRE').toUpperCase(),
    };
    return super.create(sanitizedItem);
  }

  @override
  Future<dynamic> update(dynamic id, dynamic item) async {
    final sanitizedItem = {
      'ville': item['ville']?.toString() ?? '',
      'quartier': item['quartier']?.toString() ?? '',
      'google_maps_link': item['google_maps_link']?.toString() ?? '',
      'latitude_degrees': item['latitude_degrees'] ?? 0,
      'latitude_minutes': item['latitude_minutes'] ?? 0,
      'latitude_seconds': item['latitude_seconds'] ?? 0,
      'longitude_degrees': item['longitude_degrees'] ?? 0,
      'longitude_minutes': item['longitude_minutes'] ?? 0,
      'longitude_seconds': item['longitude_seconds'] ?? 0,
      'agence_id': item['agence_id']?.toString() ?? '',
      'coordonnees_point': item['coordonnees_point']?.toString() ?? '',
      'etat': (item['etat']?.toString() ?? 'LIBRE').toUpperCase(),
    };
    return super.update(id, sanitizedItem);
  }
}
