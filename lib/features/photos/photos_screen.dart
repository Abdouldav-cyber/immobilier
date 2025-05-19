import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/photo_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class PhotosScreen extends EntityScreen {
  PhotosScreen({super.key})
      : super(title: 'Photos', service: PhotoService(), entityName: 'photo');

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends EntityScreenState<PhotosScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
