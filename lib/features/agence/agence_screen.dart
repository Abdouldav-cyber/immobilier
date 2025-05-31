import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
              'name': 'nom',
              'label': 'Nom de l\'agence',
              'type': 'text',
              'icon': MdiIcons.officeBuilding,
            },
            {
              'name': 'ville',
              'label': 'Ville',
              'type': 'text',
              'icon': MdiIcons.city,
            },
            {
              'name': 'quartier',
              'label': 'Quartier',
              'type': 'text',
              'icon': MdiIcons.map,
            },
            {
              'name': 'google_maps_link',
              'label': 'Lien Google Maps',
              'type': 'text',
              'icon': MdiIcons.link,
              'validator': (value) {
                if (value == null || value.isEmpty) {
                  return null; // Non obligatoire
                }
                final urlPattern = RegExp(
                  r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
                  caseSensitive: false,
                );
                if (!urlPattern.hasMatch(value)) {
                  return 'Veuillez entrer une URL valide';
                }
                return null;
              },
            },
            {
              'name': 'immatriculation',
              'label': 'Immatriculation',
              'type': 'text',
              'icon': MdiIcons.fingerprint,
              'validator': (value) {
                if (value == null || value.isEmpty) {
                  return null; // Non obligatoire
                }
                final immatriculationPattern = RegExp(r'^[A-Za-z0-9-]+$');
                if (!immatriculationPattern.hasMatch(value)) {
                  return 'L\'immatriculation ne doit contenir que des lettres, chiffres ou tirets';
                }
                return null;
              },
            },
            {
              'name': 'logo',
              'label': 'Logo de l\'agence',
              'type': 'image',
              'icon': MdiIcons.image,
            },
          ],
          icon: MdiIcons.officeBuilding,
          routeName: Routes.agences,
        );
}
