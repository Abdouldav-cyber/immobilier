import 'package:flutter/material.dart';
import 'package:gestion_immo/data/models/services/property_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/config/app_config.dart';
import '../../data/models/bien_model.dart';
//import '../../data/services/property_service.dart';
import '../../shared/themes/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _propertyService = PropertyService();
  List<BienModel> _properties = [];
  bool _isLoading = true;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  static const LatLng _center = LatLng(12.371428, -1.519660); // Ouagadougou

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    try {
      final properties = await _propertyService.fetchProperties();
      setState(() {
        _properties = properties;
        _isLoading = false;
        _addMarkers();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement : $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMarkers() {
    for (var property in _properties) {
      if (property.latitude != null && property.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(property.id),
            position: LatLng(property.latitude!, property.longitude!),
            infoWindow: InfoWindow(
              title: property.designation,
              snippet: property.adresse,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des biens'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: _center,
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
