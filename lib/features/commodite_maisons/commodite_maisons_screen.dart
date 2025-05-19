import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/commodite_maison_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class CommoditeMaisonsScreen extends EntityScreen {
  CommoditeMaisonsScreen({super.key})
      : super(
            title: 'Commodités Maisons',
            service: CommoditeMaisonService(),
            entityName: 'commodite-maison');

  @override
  State<CommoditeMaisonsScreen> createState() => _CommoditeMaisonsScreenState();
}

class _CommoditeMaisonsScreenState
    extends EntityScreenState<CommoditeMaisonsScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
