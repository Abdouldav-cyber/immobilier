import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/commodite_maison_service.dart';

class CommoditeMaisonsScreen extends StatefulWidget {
  const CommoditeMaisonsScreen({super.key});

  @override
  _CommoditeMaisonsScreenState createState() => _CommoditeMaisonsScreenState();
}

class _CommoditeMaisonsScreenState extends State<CommoditeMaisonsScreen> {
  final CommoditeMaisonService _commoditeMaisonService =
      CommoditeMaisonService();
  List<dynamic> commoditeMaisons = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchCommoditeMaisons();
  }

  Future<void> _fetchCommoditeMaisons() async {
    try {
      final data = await _commoditeMaisonService.getCommoditeMaisons();
      setState(() {
        commoditeMaisons = data;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commodité-Maisons'),
      ),
      body: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.homeLightbulb, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Erreur lors du chargement : $error',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            )
          : commoditeMaisons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.homeLightbulb,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucune relation commodité-maison trouvée',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: commoditeMaisons.length,
                  itemBuilder: (context, index) {
                    final relation = commoditeMaisons[index];
                    return ListTile(
                      title: Text(
                          'Maison ID: ${relation['maison_id']?.toString() ?? 'N/A'}'),
                      subtitle: Text(
                          'Commodité ID: ${relation['commodite_id']?.toString() ?? 'N/A'}'),
                      onTap: () {
                        print('Clic sur relation ${relation['id']}');
                      },
                    );
                  },
                ),
    );
  }
}
