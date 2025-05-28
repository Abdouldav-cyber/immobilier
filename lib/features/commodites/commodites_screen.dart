import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/commodite_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class CommoditesScreen extends EntityScreen {
  CommoditesScreen({super.key})
      : super(
          title: 'Commodités',
          service: CommoditeService(),
          fields: [
            {
              'name': 'nom',
              'label': 'Nom',
              'type': 'text',
              'icon': Icons.lightbulb,
            },
            {
              'name': 'description',
              'label': 'Description',
              'type': 'text',
              'icon': Icons.description,
            },
          ],
          icon: Icons.lightbulb,
          routeName: Routes.commodites,
        );
}
