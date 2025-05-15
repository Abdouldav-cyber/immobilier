import 'package:flutter/material.dart';
import 'package:gestion_immo/data/models/services/location_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../data/models/location_model.dart';
import '../../data/services/location_service.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _dateDebutController = TextEditingController();
  final _dateFinController = TextEditingController();
  final _montantController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _bienIdController = TextEditingController();
  final _locationService = LocationService();
  bool _isLoading = false;

  void _addLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final location = LocationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateDebut: _dateDebutController.text,
        dateFin:
            _dateFinController.text.isEmpty ? null : _dateFinController.text,
        montant: double.parse(_montantController.text),
        clientId: _clientIdController.text,
        bienId: _bienIdController.text,
      );
      await _locationService.addLocation(location);
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
        title: const Text('Ajouter une location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _dateDebutController,
                label: 'Date de début (YYYY-MM-DD)',
                icon: MdiIcons.calendarStart,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dateFinController,
                label: 'Date de fin (YYYY-MM-DD, optionnel)',
                icon: MdiIcons.calendarEnd,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _montantController,
                label: 'Montant (FCFA)',
                keyboardType: TextInputType.number,
                icon: MdiIcons.cash,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _clientIdController,
                label: 'ID du client',
                icon: MdiIcons.account,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bienIdController,
                label: 'ID du bien',
                icon: MdiIcons.home,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Ajouter',
                icon: MdiIcons.plus,
                onPressed: _addLocation,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
