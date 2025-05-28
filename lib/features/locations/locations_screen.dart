import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/data/services/location_service.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  bool _isSidebarOpen = false;
  final LocationService _service = LocationService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  final TextEditingController _maisonIdController = TextEditingController();
  final TextEditingController _locataireController = TextEditingController();
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _service.getAll();
      setState(() {
        _items = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    }
  }

  Future<void> _addItem() async {
    if (_maisonIdController.text.isEmpty ||
        _locataireController.text.isEmpty ||
        _dateDebutController.text.isEmpty ||
        _montantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont requis')),
      );
      return;
    }
    try {
      await _service.create({
        'maison_id': int.parse(_maisonIdController.text),
        'locataire': _locataireController.text,
        'date_debut': _dateDebutController.text,
        'montant': double.parse(_montantController.text),
      });
      _maisonIdController.clear();
      _locataireController.clear();
      _dateDebutController.clear();
      _montantController.clear();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout: $e')),
      );
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _service.delete(id);
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  Future<void> _closeLocation(int id) async {
    try {
      await _service.closeLocation(id);
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la clôture: $e')),
      );
    }
  }

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
      Navigator.pushReplacementNamed(context, Routes.login);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Barre latérale
          Container(
            width: _isSidebarOpen ? 250 : 70,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.brown[900],
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    _isSidebarOpen ? MdiIcons.close : MdiIcons.menu,
                    color: Colors.white,
                  ),
                  title: _isSidebarOpen
                      ? const Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                  onTap: _toggleSidebar,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSidebarItem(Icons.home, 'Accueil',
                          () => Navigator.pushNamed(context, Routes.home)),
                      _buildSidebarItem(Icons.view_agenda, 'Maisons',
                          () => Navigator.pushNamed(context, Routes.maisons)),
                      _buildSidebarItem(Icons.business, 'Agences',
                          () => Navigator.pushNamed(context, Routes.agences)),
                      _buildSidebarItem(Icons.location_on, 'Locations',
                          () => setState(() {}), true),
                      _buildSidebarItem(Icons.payment, 'Paiements',
                          () => Navigator.pushNamed(context, Routes.paiements)),
                      _buildSidebarItem(Icons.warning, 'Pénalités',
                          () => Navigator.pushNamed(context, Routes.penalites)),
                      _buildSidebarItem(
                          Icons.description,
                          'Types de Documents',
                          () => Navigator.pushNamed(
                              context, Routes.type_documents)),
                      _buildSidebarItem(Icons.location_city, 'Communes',
                          () => Navigator.pushNamed(context, Routes.communes)),
                      _buildSidebarItem(
                          Icons.lightbulb,
                          'Commodités',
                          () =>
                              Navigator.pushNamed(context, Routes.commodites)),
                      _buildSidebarItem(
                          Icons.house,
                          'Commodités Maisons',
                          () => Navigator.pushNamed(
                              context, Routes.commoditeMaisons)),
                      _buildSidebarItem(Icons.photo, 'Photos',
                          () => Navigator.pushNamed(context, Routes.photos)),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Tooltip(
                          message: 'Déconnexion',
                          child: ListTile(
                            leading:
                                Icon(Icons.logout, color: Colors.grey[300]),
                            title: _isSidebarOpen
                                ? Text(
                                    'Déconnexion',
                                    style: TextStyle(color: Colors.grey[300]),
                                  )
                                : null,
                            onTap: _logout,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu principal
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.brown[600]!, Colors.brown[800]!],
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Locations',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Formulaire
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ajouter une Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _maisonIdController,
                              decoration: InputDecoration(
                                labelText: 'ID de la Maison',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locataireController,
                              decoration: InputDecoration(
                                labelText: 'Locataire',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _dateDebutController,
                              decoration: InputDecoration(
                                labelText: 'Date de Début (YYYY-MM-DD)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _montantController,
                              decoration: InputDecoration(
                                labelText: 'Montant',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addItem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Ajouter'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Liste
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _items.isEmpty
                            ? const Center(
                                child: Text('Aucune location trouvée'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  final bool estCloturee =
                                      item['est_cloturee'] ?? false;
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.brown,
                                        child: Icon(Icons.location_on,
                                            color: Colors.white),
                                      ),
                                      title: Text(
                                        'Locataire: ${item['locataire'] ?? 'Inconnu'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown),
                                      ),
                                      subtitle: Text(
                                        'Maison ID: ${item['maison_id']} | Date Début: ${item['date_debut']} | Montant: ${item['montant']}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!estCloturee)
                                            IconButton(
                                              icon: const Icon(Icons.lock,
                                                  color: Colors.orange),
                                              onPressed: () =>
                                                  _closeLocation(item['id']),
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _deleteItem(item['id']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap,
      [bool isSelected = false]) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: title,
        child: ListTile(
          leading:
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[300]),
          title: _isSidebarOpen
              ? Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[300],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                )
              : null,
          onTap: onTap,
          tileColor: isSelected ? Colors.brown[600] : null,
        ),
      ),
    );
  }
}
