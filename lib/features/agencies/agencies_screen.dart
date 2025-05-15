import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/models/services/agency_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants/routes.dart';
import '../../data/services/agency_service.dart';
import '../../data/models/agency_model.dart';
import '../../shared/themes/app_theme.dart';

class AgenciesScreen extends StatefulWidget {
  const AgenciesScreen({super.key});

  @override
  _AgenciesScreenState createState() => _AgenciesScreenState();
}

class _AgenciesScreenState extends State<AgenciesScreen> {
  final _agencyService = AgencyService();
  List<AgencyModel> _agencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAgencies();
  }

  Future<void> _fetchAgencies() async {
    try {
      final agencies = await _agencyService.fetchAgencies();
      setState(() {
        _agencies = agencies;
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
        title: const Text('Mes Agences'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.plus),
            onPressed: () => Navigator.pushNamed(context, Routes.addAgency),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agencies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MdiIcons.officeBuilding,
                        size: 80,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune agence trouvée',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _agencies.length,
                  itemBuilder: (context, index) {
                    final agency = _agencies[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Icon(
                          MdiIcons.officeBuilding,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(agency.name),
                        subtitle: Text(
                          '${agency.address}${agency.phone != null ? ' • ${agency.phone}' : ''}',
                        ),
                        trailing: Icon(
                          MdiIcons.arrowRight,
                          color: AppTheme.secondaryTextColor,
                        ),
                        onTap: () {
                          // TODO: Naviguer vers les détails de l'agence
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
