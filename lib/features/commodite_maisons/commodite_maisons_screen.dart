import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/commodite_maison_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class CommoditeMaisonsScreen extends EntityScreen {
  CommoditeMaisonsScreen({super.key})
      : super(
          title: 'Commodités Maisons',
          service: CommoditeMaisonService(),
          fields: [
            {
              'name': 'maison_id',
              'label': 'ID de la Maison',
              'type': 'number',
              'icon': Icons.home,
            },
            {
              'name': 'commodite_id',
              'label': 'ID de la Commodité',
              'type': 'number',
              'icon': Icons.lightbulb,
            },
          ],
          icon: Icons.house,
          routeName: Routes.commoditeMaisons,
        );
}
