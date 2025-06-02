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
              'name': 'latitude_degrees',
              'label': 'Latitude (Degrés)',
              'type': 'number',
              'icon': Icons.gps_fixed,
            },
            {
              'name': 'latitude_minutes',
              'label': 'Latitude (Minutes)',
              'type': 'number',
              'icon': Icons.gps_fixed,
            },
            {
              'name': 'latitude_seconds',
              'label': 'Latitude (Secondes)',
              'type': 'number',
              'icon': Icons.gps_fixed,
            },
            {
              'name': 'longitude_degrees',
              'label': 'Longitude (Degrés)',
              'type': 'number',
              'icon': Icons.gps_fixed,
            },
            {
              'name': 'longitude_minutes',
              'label': 'Longitude (Minutes)',
              'type': 'number',
              'icon': Icons.gps_fixed,
            },
            {
              'name': 'longitude_seconds',
              'label': 'Longitude (Secondes)',
              'type': 'number',
              'icon': Icons.gps_fixed,
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
                return null;
              },
            },
            {
              'name': 'etat_maison',
              'label': 'État de la maison',
              'type': 'dropdown',
              'icon': Icons.info,
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
