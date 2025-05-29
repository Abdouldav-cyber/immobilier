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
              'name': 'date',
              'label': 'Date',
              'type': 'text',
              'icon': Icons.calendar_today
            },
            {
              'name': 'type_de_document',
              'label': 'Type de Document',
              'type': 'dropdown',
              'icon': Icons.description,
              'options_endpoint': 'type_documents'
            },
            {
              'name': 'numero',
              'label': 'Numéro',
              'type': 'text',
              'icon': Icons.numbers
            },
            {
              'name': 'date_etablissement',
              'label': 'Date d\'Établissement',
              'type': 'text',
              'icon': Icons.date_range
            },
            {
              'name': 'date_expiration',
              'label': 'Date d\'Expiration',
              'type': 'text',
              'icon': Icons.event
            },
            {
              'name': 'nom',
              'label': 'Nom',
              'type': 'text',
              'icon': Icons.person
            },
            {
              'name': 'prenom',
              'label': 'Prénom',
              'type': 'text',
              'icon': Icons.person_outline
            },
            {
              'name': 'client',
              'label': 'Client',
              'type': 'text',
              'icon': Icons.account_circle
            },
            {
              'name': 'maison_id',
              'label': 'Maison',
              'type': 'dropdown',
              'icon': Icons.home,
              'options_endpoint': 'maisons'
            },
          ],
          icon: Icons.location_on,
          routeName: Routes.locations,
        );
}
