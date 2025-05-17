import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/commodite_service.dart';

class CommoditesScreen extends StatefulWidget {
  const CommoditesScreen({super.key});

  @override
  _CommoditesScreenState createState() => _CommoditesScreenState();
}

class _CommoditesScreenState extends State<CommoditesScreen> {
  final CommoditeService _commoditeService = CommoditeService();
  List<dynamic> commodites = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchCommodites();
  }

  Future<void> _fetchCommodites() async {
    try {
      final data = await _commoditeService.getCommodites();
      setState(() {
        commodites = data;
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
        title: const Text('Commodités'),
      ),
      body: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MdiIcons.lightbulb, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Erreur lors du chargement : $error',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            )
          : commodites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.lightbulb, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucune commodité trouvée',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: commodites.length,
                  itemBuilder: (context, index) {
                    final commodite = commodites[index];
                    return ListTile(
                      title: Text(commodite['nom'] ?? 'Commodité sans nom'),
                      subtitle: Text('Type: ${commodite['type'] ?? 'N/A'}'),
                      onTap: () {
                        print('Clic sur commodité ${commodite['nom']}');
                      },
                    );
                  },
                ),
    );
  }
}
