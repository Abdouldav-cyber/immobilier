import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/commune_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class CommunesScreen extends EntityScreen {
  CommunesScreen({super.key})
      : super(
          title: 'Communes',
          service: CommuneService(),
          fields: [
            {
              'name': 'nom',
              'label': 'Nom',
              'type': 'text',
              'icon': Icons.location_city,
            },
            {
              'name': 'code_postal',
              'label': 'Code Postal',
              'type': 'text',
              'icon': Icons.pin,
            },
          ],
          icon: Icons.location_city,
          routeName: Routes.communes,
        );
}
