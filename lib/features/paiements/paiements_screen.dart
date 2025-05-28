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
              'name': 'date',
              'label': 'Date',
              'type': 'text',
              'icon': Icons.date_range,
            },
            {
              'name': 'location_id',
              'label': 'ID de la Location',
              'type': 'number',
              'icon': Icons.location_on,
            },
          ],
          icon: Icons.payment,
          routeName: Routes.paiements,
        );
}
