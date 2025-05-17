import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/maison_service.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  _PropertiesScreenState createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final MaisonService _maisonService = MaisonService();
  List<dynamic> maisons = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchMaisons();
  }

  Future<void> _fetchMaisons() async {
    try {
      final data = await _maisonService.getMaisons();
      setState(() {
        maisons = data;
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
        title: const Text('Mes Propriétés'),
      ),
      body: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.home, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Erreur lors du chargement : $error',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            )
          : maisons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.home, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucune propriété trouvée',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: maisons.length,
                  itemBuilder: (context, index) {
                    final maison = maisons[index];
                    return ListTile(
                      title: Text(maison['nom'] ?? 'Propriété sans nom'),
                      subtitle:
                          Text(maison['adresse'] ?? 'Adresse non disponible'),
                      onTap: () {
                        // Logique pour afficher les détails
                        print('Clic sur ${maison['nom']}');
                      },
                    );
                  },
                ),
    );
  }
}
