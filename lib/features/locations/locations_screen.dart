import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/models/services/location_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants/routes.dart';
import '../../data/services/location_service.dart';
import '../../data/models/location_model.dart';
import '../../shared/themes/app_theme.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final _locationService = LocationService();
  List<LocationModel> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final locations = await _locationService.fetchLocations();
      setState(() {
        _locations = locations;
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Locations'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.plus),
            onPressed: () => Navigator.pushNamed(context, Routes.addLocation),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _locations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.contrast,
                        size: 80,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune location trouvée',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Icon(
                          MdiIcons.contrast,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text('Location #${location.id}'),
                        subtitle: Text(
                          'Début: ${location.dateDebut} • Montant: ${location.montant} FCFA',
                        ),
                        trailing: Icon(
                          MdiIcons.arrowRight,
                          color: AppTheme.secondaryTextColor,
                        ),
                        onTap: () {
                          // TODO: Naviguer vers les détails de la location
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
