import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/photo_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class PhotosScreen extends EntityScreen {
  PhotosScreen({super.key})
      : super(
          title: 'Photos',
          service: PhotoService(),
          fields: [
            {
              'name': 'url',
              'label': 'URL de la Photo',
              'type': 'text',
              'icon': Icons.link,
            },
            {
              'name': 'description',
              'label': 'Description',
              'type': 'text',
              'icon': Icons.description,
            },
            {
              'name': 'maison_id',
              'label': 'ID de la Maison',
              'type': 'number',
              'icon': Icons.home,
            },
          ],
          icon: Icons.photo,
          routeName: Routes.photos,
        );
}
