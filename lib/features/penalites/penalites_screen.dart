import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/penalite_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class PenalitesScreen extends EntityScreen {
  PenalitesScreen({super.key})
      : super(
            title: 'Pénalités',
            service: PenaliteService(),
            entityName: 'penalite');

  @override
  State<PenalitesScreen> createState() => _PenalitesScreenState();
}

class _PenalitesScreenState extends EntityScreenState<PenalitesScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
