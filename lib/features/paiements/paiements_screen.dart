import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/paiement_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class PaiementsScreen extends EntityScreen {
  PaiementsScreen({super.key})
      : super(
            title: 'Paiements',
            service: PaiementService(),
            entityName: 'paiement');

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends EntityScreenState<PaiementsScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
