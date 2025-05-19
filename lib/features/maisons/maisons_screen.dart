import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/maison_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class MaisonsScreen extends EntityScreen {
  MaisonsScreen({super.key})
      : super(title: 'Maisons', service: MaisonService(), entityName: 'maison');

  @override
  State<MaisonsScreen> createState() => _MaisonsScreenState();
}

class _MaisonsScreenState extends EntityScreenState<MaisonsScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
