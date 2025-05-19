import 'package:flutter/material.dart';
import 'package:gestion_immo/data/services/location_service.dart';
import 'package:gestion_immo/features/entity_screen.dart';

class LocationsScreen extends EntityScreen {
  LocationsScreen({super.key})
      : super(
            title: 'Locations',
            service: LocationService(),
            entityName: 'location');

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends EntityScreenState<LocationsScreen> {
  @override
  Widget build(BuildContext context) {
    return super.build(context); // Délègue la construction à EntityScreenState
  }
}
