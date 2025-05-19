import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/document_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class DocumentsScreen extends EntityScreen {
  DocumentsScreen({super.key})
      : super(
            title: 'Documents',
            service: DocumentService(),
            entityName: 'document');

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends EntityScreenState<DocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
