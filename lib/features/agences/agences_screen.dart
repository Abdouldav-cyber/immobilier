import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/agence_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class AgencesScreen extends EntityScreen {
  AgencesScreen({super.key})
      : super(
          title: 'Agences',
          service: AgenceService(),
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
              'name': 'immatriculation',
              'label': 'Immatriculation',
              'type': 'text',
              'icon': Icons.badge,
            },
            {
              'name': 'nom',
              'label': 'Nom',
              'type': 'text',
              'icon': Icons.business,
            },
            {
              'name': 'logo',
              'label': 'Logo',
              'type': 'image',
              'icon': MdiIcons.image,
            },
          ],
          icon: Icons.business,
          routeName: Routes.agences,
        );
}
