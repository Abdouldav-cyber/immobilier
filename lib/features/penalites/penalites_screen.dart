import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/penalite_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class PenalitesScreen extends EntityScreen {
  PenalitesScreen({super.key})
      : super(
          title: 'Pénalités',
          service: PenaliteService(),
          fields: [
            {
              'name': 'montant',
              'label': 'Montant',
              'type': 'number',
              'icon': Icons.attach_money,
            },
            {
              'name': 'description',
              'label': 'Description',
              'type': 'text',
              'icon': Icons.description,
            },
            {
              'name': 'location_id',
              'label': 'ID de la Location',
              'type': 'dropdown',
              'icon': Icons.location_on,
              'options_endpoint': 'locations',
              'validator': (value) {
                return null; // Optionnel
              },
            },
          ],
          icon: Icons.warning,
          routeName: Routes.penalites,
        );
}
