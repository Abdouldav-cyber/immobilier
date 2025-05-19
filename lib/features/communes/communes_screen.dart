import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/commune_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class CommunesScreen extends EntityScreen {
  CommunesScreen({super.key})
      : super(
            title: 'Communes',
            service: CommuneService(),
            entityName: 'commune');

  @override
  State<CommunesScreen> createState() => _CommunesScreenState();
}

class _CommunesScreenState extends EntityScreenState<CommunesScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
