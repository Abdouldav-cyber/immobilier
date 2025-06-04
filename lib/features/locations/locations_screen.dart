import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/location_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LocationsScreen extends EntityScreen {
  LocationsScreen({super.key})
      : super(
          title: 'Locations',
          service: LocationService(),
          fields: [
            {
              'name': 'maison_id',
              'label': 'Maison',
              'type': 'dropdown',
              'icon': Icons.home,
              'options_endpoint': 'maisons',
            },
            {
              'name': 'locataire',
              'label': 'Locataire',
              'type': 'text',
              'icon': Icons.person,
            },
            {
              'name': 'date_debut',
              'label': 'Date de début',
              'type': 'date',
              'icon': Icons.calendar_today,
            },
            {
              'name': 'date_fin',
              'label': 'Date de fin',
              'type': 'date',
              'icon': Icons.calendar_today,
            },
            {
              'name': 'montant_loyer',
              'label': 'Montant du loyer',
              'type': 'number',
              'icon': Icons.attach_money,
            },
            {
              'name': 'date',
              'label': 'Date',
              'type': 'date',
              'icon': MdiIcons.calendar,
            },
            {
              'name': 'nom_client',
              'label': 'Nom du client',
              'type': 'text',
              'icon': MdiIcons.account,
            },
            {
              'name': 'prenom_client',
              'label': 'Prénom du client',
              'type': 'text',
              'icon': MdiIcons.account,
            },
          ],
          icon: Icons.location_on,
          routeName: Routes.locations,
        );
}
