import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/data/services/paiement_service.dart';

class PaimentsScreen extends StatefulWidget {
  const PaimentsScreen({super.key});

  @override
  _PaimentsScreenState createState() => _PaimentsScreenState();
}

class _PaimentsScreenState extends State<PaimentsScreen> {
  final PaiementService _paiementService = PaiementService();
  List<dynamic> paiements = [];
  String? error;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaiements();
  }

  Future<void> _fetchPaiements() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await _paiementService.getPaiements();
      setState(() {
        paiements = data;
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
        title: const Text('Paiements loyers'),
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
                      Icon(MdiIcons.cash, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Erreur lors du chargement : $error',
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPaiements,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : paiements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(MdiIcons.cash, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aucun paiement trouvé',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: paiements.length,
                      itemBuilder: (context, index) {
                        final paiement = paiements[index];
                        return ListTile(
                          title: Text(
                              'Paiement ${paiement['id']?.toString() ?? 'N/A'}'),
                          subtitle: Text(
                              'Montant: ${paiement['montant']?.toString() ?? 'N/A'}'),
                          onTap: () {
                            print('Clic sur paiement ${paiement['id']}');
                          },
                        );
                      },
                    ),
    );
  }
}
