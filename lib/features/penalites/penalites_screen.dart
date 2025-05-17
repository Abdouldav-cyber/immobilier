import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/penalite_service.dart';

class PenalitesScreen extends StatefulWidget {
  const PenalitesScreen({super.key});

  @override
  _PenalitesScreenState createState() => _PenalitesScreenState();
}

class _PenalitesScreenState extends State<PenalitesScreen> {
  final PenaliteService _penaliteService = PenaliteService();
  List<dynamic> penalites = [];
  String? error;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPenalites();
  }

  Future<void> _fetchPenalites() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await _penaliteService.getPenalites();
      setState(() {
        penalites = data;
        error = null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pénalités'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MdiIcons.alert, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Erreur lors du chargement : $error',
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPenalites,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : penalites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(MdiIcons.alert, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Aucune pénalité trouvée',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: penalites.length,
                      itemBuilder: (context, index) {
                        final penalite = penalites[index];
                        return ListTile(
                          title: Text(
                              'Pénalité ${penalite['id']?.toString() ?? 'N/A'}'),
                          subtitle: Text(
                              'Montant: ${penalite['montant']?.toString() ?? 'N/A'}'),
                          onTap: () {
                            print('Clic sur pénalité ${penalite['id']}');
                          },
                        );
                      },
                    ),
    );
  }
}
