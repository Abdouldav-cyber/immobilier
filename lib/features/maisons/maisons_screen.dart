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
              'name': 'nom',
              'label': 'Nom',
              'type': 'text',
              'icon': Icons.home,
            },
            {
              'name': 'adresse',
              'label': 'Adresse',
              'type': 'text',
              'icon': Icons.location_on,
            },
          ],
          icon: Icons.home,
          routeName: Routes.maisons,
        );
}
