import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/commodite_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class CommoditesScreen extends EntityScreen {
  CommoditesScreen({super.key})
      : super(
            title: 'Commodités',
            service: CommoditeService(),
            entityName: 'commodite');

  @override
  State<CommoditesScreen> createState() => _CommoditesScreenState();
}

class _CommoditesScreenState extends EntityScreenState<CommoditesScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
