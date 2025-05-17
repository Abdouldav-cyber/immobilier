import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/commune_service.dart';

class CommunesScreen extends StatefulWidget {
  const CommunesScreen({super.key});

  @override
  _CommunesScreenState createState() => _CommunesScreenState();
}

class _CommunesScreenState extends State<CommunesScreen> {
  final CommuneService _communeService = CommuneService();
  List<dynamic> communes = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchCommunes();
  }

  Future<void> _fetchCommunes() async {
    try {
      final data = await _communeService.getCommunes();
      setState(() {
        communes = data;
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
        title: const Text('Communes'),
      ),
      body: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.city, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Erreur lors du chargement : $error',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            )
          : communes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.city, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucune commune trouvée',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: communes.length,
                  itemBuilder: (context, index) {
                    final commune = communes[index];
                    return ListTile(
                      title: Text(commune['nom'] ?? 'Commune sans nom'),
                      subtitle: Text('Région: ${commune['region'] ?? 'N/A'}'),
                      onTap: () {
                        print('Clic sur commune ${commune['nom']}');
                      },
                    );
                  },
                ),
    );
  }
}
