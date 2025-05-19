import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/agence_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class AgencesScreen extends EntityScreen {
  AgencesScreen({super.key})
      : super(title: 'Agences', service: AgenceService(), entityName: 'agence');

  @override
  State<AgencesScreen> createState() => _AgencesScreenState();
}

class _AgencesScreenState extends EntityScreenState<AgencesScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
