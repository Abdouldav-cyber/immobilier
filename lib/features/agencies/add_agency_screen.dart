import 'package:flutter/material.dart';
import 'package:gestion_immo/data/models/services/agency_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../data/models/agency_model.dart';
import '../../data/services/agency_service.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class AddAgencyScreen extends StatefulWidget {
  const AddAgencyScreen({super.key});

  @override
  _AddAgencyScreenState createState() => _AddAgencyScreenState();
}

class _AddAgencyScreenState extends State<AddAgencyScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _agencyService = AgencyService();
  bool _isLoading = false;

  void _addAgency() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final agency = AgencyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      );
      await _agencyService.addAgency(agency);
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
        title: const Text('Ajouter une agence'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nom de l\'agence',
                icon: MdiIcons.officeBuilding,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'Adresse',
                icon: MdiIcons.mapMarker,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Téléphone (optionnel)',
                keyboardType: TextInputType.phone,
                icon: MdiIcons.phone,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Ajouter',
                icon: MdiIcons.plus,
                onPressed: _addAgency,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
