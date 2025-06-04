import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/maison_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MaisonsScreen extends EntityScreen {
  MaisonsScreen({super.key})
      : super(
          title: 'Maisons',
          service: MaisonService(),
          fields: [
            {
              'name': 'ville',
              'label': 'Ville',
              'type': 'text',
              'icon': Icons.location_city,
            },
            {
              'name': 'quartier',
              'label': 'Quartier',
              'type': 'text',
              'icon': Icons.map,
            },
            {
              'name': 'google_maps_link',
              'label': 'Lien Google Maps',
              'type': 'text',
              'icon': Icons.link,
              'validator': (value) {
                if (value != null && value.isNotEmpty) {
                  final urlPattern = RegExp(
                    r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
                    caseSensitive: false,
                  );
                  if (!urlPattern.hasMatch(value)) {
                    return 'Veuillez entrer une URL valide';
                  }
                }
                return null;
              },
            },
            {
              'name': 'agence_id',
              'label': 'Agence',
              'type': 'dropdown',
              'icon': Icons.business,
              'options_endpoint': 'agences',
            },
            {
              'name': 'coordonnees_point',
              'label': 'Coordonnées du point',
              'type': 'text',
              'icon': Icons.location_pin,
              'validator': (value) {
                if (value != null && value.isNotEmpty) {
                  final coordPattern = RegExp(r'^-?\d+\.?\d*, -?\d+\.?\d*$');
                  if (!coordPattern.hasMatch(value)) {
                    return 'Format attendu : latitude, longitude (ex: 48.8566, 2.3522)';
                  }
                }
                return null; // Optionnel
              },
            },
            {
              'name': 'loyer',
              'label': 'Loyer (en FCFA)',
              'type': 'number',
              'icon': Icons.monetization_on,
              'validator': (value) {
                if (value != null && value.isNotEmpty) {
                  final parsedValue = int.tryParse(value);
                  if (parsedValue == null || parsedValue < 0) {
                    return 'Veuillez entrer un loyer valide (nombre positif)';
                  }
                }
                return null;
              },
            },
            {
              'name': 'etat_maison',
              'label': 'État de la maison',
              'type': 'dropdown',
              'icon': Icons.info,
              'options': [
                {'value': 'Disponible', 'label': 'Disponible'},
                {'value': 'Occupé', 'label': 'Occupé'},
                {'value': 'En maintenance', 'label': 'En maintenance'},
              ],
            },
            {
              'name': 'photos',
              'label': 'Photos',
              'type': 'image',
              'icon': MdiIcons.imageMultiple,
            },
          ],
          icon: Icons.home,
          routeName: Routes.maisons,
        );
}
