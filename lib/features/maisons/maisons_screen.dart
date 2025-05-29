import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/maison_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

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
              'name': 'immatriculation',
              'label': 'Immatriculation',
              'type': 'text',
              'icon': Icons.fingerprint,
              'readOnly': true, // Ce champ sera généré automatiquement
            },
            {
              'name': 'type_document_ids',
              'label': 'Types de Documents',
              'type': 'multi_select',
              'icon': Icons.description,
              'options_endpoint': 'type_documents',
            },
            {
              'name': 'commodite_ids',
              'label': 'Commodités',
              'type': 'multi_select',
              'icon': Icons.checklist,
              'options_endpoint': 'commodites',
            },
            {
              'name': 'photos',
              'label': 'Photos',
              'type': 'photo_list',
              'icon': Icons.photo,
            },
          ],
          icon: Icons.home,
          routeName: Routes.maisons,
        );
}
