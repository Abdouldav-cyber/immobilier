import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/type_document_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class TypeDocumentsScreen extends EntityScreen {
  TypeDocumentsScreen({super.key})
      : super(
          title: 'Types de Documents',
          service: TypeDocumentService(),
          fields: [
            {
              'name': 'nom',
              'label': 'Nom',
              'type': 'text',
              'icon': Icons.description,
            },
            {
              'name': 'description',
              'label': 'Description',
              'type': 'text',
              'icon': Icons.notes,
            },
          ],
          icon: Icons.description,
          routeName: Routes.type_documents,
        );
}
