import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/paiement_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class PaiementsScreen extends EntityScreen {
  PaiementsScreen({super.key})
      : super(
          title: 'Paiements',
          service: PaiementService(),
          fields: [
            {
              'name': 'montant',
              'label': 'Montant',
              'type': 'number',
              'icon': Icons.attach_money,
            },
            {
              'name': 'date_paiement',
              'label': 'Date',
              'type': 'date',
              'icon': Icons.date_range,
            },
            {
              'name': 'location',
              'label': 'ID de la Location',
              'type': 'dropdown',
              'icon': Icons.location_on,
              'options_endpoint': 'locations',
              'display_field': 'id', // Utiliser l'ID comme référence
              'validator': (value) =>
                  value == null ? 'Choisissez une location' : null,
            },
          ],
          icon: Icons.payment,
          routeName: Routes.paiements,
        );
}
