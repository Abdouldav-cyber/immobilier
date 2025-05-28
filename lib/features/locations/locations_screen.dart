import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/location_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class LocationsScreen extends EntityScreen {
  LocationsScreen({super.key})
      : super(
          title: 'Locations',
          service: LocationService(),
          fields: [
            {
              'name': 'nom',
              'label': 'Nom',
              'type': 'text',
              'icon': Icons.person,
            },
            {
              'name': 'dateDebut',
              'label': 'Date de début',
              'type': 'text',
              'icon': Icons.date_range,
            },
            {
              'name': 'dateFin',
              'label': 'Date de fin',
              'type': 'text',
              'icon': Icons.date_range,
            },
            {
              'name': 'status',
              'label': 'Statut',
              'type': 'text',
              'icon': Icons.info,
            },
          ],
          icon: Icons.location_on,
          routeName: Routes.locations,
        );
}
