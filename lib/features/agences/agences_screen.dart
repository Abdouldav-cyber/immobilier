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
              'name': 'nom',
              'label': 'Nom',
              'type': 'text',
              'icon': Icons.business,
            },
            {
              'name': 'adresse',
              'label': 'Adresse',
              'type': 'text',
              'icon': Icons.location_on,
            },
            {
              'name': 'email',
              'label': 'Email',
              'type': 'email',
              'icon': Icons.email,
            },
            {
              'name': 'telephone',
              'label': 'Téléphone',
              'type': 'text',
              'icon': Icons.phone,
            },
          ],
          icon: Icons.business,
          routeName: Routes.agences,
        );
}
