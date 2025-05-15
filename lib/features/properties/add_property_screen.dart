import 'package:flutter/material.dart';
import 'package:gestion_immo/data/models/services/property_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../data/models/bien_model.dart';
import '../../data/models/commune_model.dart';
import '../../data/models/commodity_model.dart';
import '../../data/services/property_service.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _designationController = TextEditingController();
  final _adresseController = TextEditingController();
  final _villeController = TextEditingController();
  final _superficieController = TextEditingController();
  final _loyerController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _propertyService = PropertyService();
  String? _selectedCommuneId;
  List<String> _selectedCommodities = [];
  List<CommuneModel> _communes = [];
  List<CommodityModel> _commodities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCommunes();
    _fetchCommodities();
  }

  Future<void> _fetchCommunes() async {
    try {
      final communes = await _propertyService.fetchCommunes();
      setState(() {
        _communes = communes;
        if (communes.isNotEmpty) _selectedCommuneId = communes[0].id;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des communes : $e')),
      );
    }
  }

  Future<void> _fetchCommodities() async {
    try {
      final commodities = await _propertyService.fetchCommodities();
      setState(() {
        _commodities = commodities;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du chargement des commodités : $e')),
      );
    }
  }

  void _addProperty() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final bien = BienModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        designation: _designationController.text,
        adresse: _adresseController.text,
        ville: _villeController.text,
        superficie: int.tryParse(_superficieController.text),
        loyer: double.parse(_loyerController.text),
        communeId: _selectedCommuneId,
        photos: [],
        commodites: _selectedCommodities,
        latitude: double.tryParse(_latitudeController.text),
        longitude: double.tryParse(_longitudeController.text),
      );
      await _propertyService.addProperty(bien);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
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
        title: const Text('Ajouter un bien'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _designationController,
                label: 'Désignation',
                icon: MdiIcons.home,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _adresseController,
                label: 'Adresse',
                icon: MdiIcons.mapMarker,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _villeController,
                label: 'Ville',
                icon: MdiIcons.city,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _superficieController,
                label: 'Superficie (m²)',
                keyboardType: TextInputType.number,
                icon: MdiIcons.rulerSquare,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _loyerController,
                label: 'Loyer (FCFA)',
                keyboardType: TextInputType.number,
                icon: MdiIcons.cash,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCommuneId,
                decoration: InputDecoration(
                  labelText: 'Commune',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _communes
                    .map((commune) => DropdownMenuItem(
                          value: commune.id,
                          child: Text(commune.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCommuneId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Commodités',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Wrap(
                spacing: 8,
                children: _commodities
                    .map((commodity) => FilterChip(
                          label: Text(commodity.name),
                          selected: _selectedCommodities.contains(commodity.id),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCommodities.add(commodity.id);
                              } else {
                                _selectedCommodities.remove(commodity.id);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _latitudeController,
                label: 'Latitude',
                keyboardType: TextInputType.number,
                icon: MdiIcons.mapMarker,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _longitudeController,
                label: 'Longitude',
                keyboardType: TextInputType.number,
                icon: MdiIcons.mapMarker,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Ajouter',
                icon: MdiIcons.plus,
                onPressed: _addProperty,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
