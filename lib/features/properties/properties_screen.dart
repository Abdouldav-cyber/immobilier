import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/models/services/property_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants/routes.dart';
import '../../data/services/property_service.dart';
import '../../data/models/bien_model.dart';
import '../../shared/themes/app_theme.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  _PropertiesScreenState createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final _propertyService = PropertyService();
  List<BienModel> _properties = [];
  bool _isLoading = true;

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
        title: const Text('Mes Propriétés'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.plus),
            onPressed: () => Navigator.pushNamed(context, Routes.addProperty),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.home,
                        size: 80,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune propriété trouvée',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _properties.length,
                  itemBuilder: (context, index) {
                    final property = _properties[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Icon(
                          MdiIcons.home,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(property.designation),
                        subtitle: Text(
                          '${property.adresse} • ${property.superficie ?? 0} m² • ${property.loyer} FCFA',
                        ),
                        trailing: Icon(
                          MdiIcons.arrowRight,
                          color: AppTheme.secondaryTextColor,
                        ),
                        onTap: () {
                          // TODO: Naviguer vers les détails du bien
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
