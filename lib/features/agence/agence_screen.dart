import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/agence_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class AgencesScreen extends EntityScreen {
  AgencesScreen({super.key})
      : super(
          title: 'Agences',
          service: AgenceService(),
          fields: [
            {
              'name': 'logo',
              'label': 'Logo de l\'agence',
              'type': 'text',
              'icon': Icons.image,
            },
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
              'name': 'immatriculation',
              'label': 'Immatriculation',
              'type': 'text',
              'icon': Icons.fingerprint,
            },
          ],
          icon: Icons.business,
          routeName: Routes.agences,
        );
}
