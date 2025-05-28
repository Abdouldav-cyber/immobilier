import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/data/services/agence_service.dart';
import 'dart:convert';

class AgenceScreen extends StatefulWidget {
  const AgenceScreen({super.key});

  @override
  State<AgenceScreen> createState() => _AgenceScreenState();
}

class _AgenceScreenState extends State<AgenceScreen> {
  bool _isSidebarOpen = false;
  final AgenceService _service = AgenceService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

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
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _service.update(id, {'sup': true});
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showAddDialog() {
    final TextEditingController nomController = TextEditingController();
    final TextEditingController immatriculationController =
        TextEditingController();
    final TextEditingController villeController = TextEditingController();
    final TextEditingController quartierController = TextEditingController();
    final TextEditingController lienGoogleMapsController =
        TextEditingController();
    final TextEditingController logoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ajouter une Agence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom de l\'Agence',
                    prefixIcon: const Icon(Icons.business, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.brown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: immatriculationController,
                  decoration: InputDecoration(
                    labelText: 'Immatriculation',
                    prefixIcon:
                        const Icon(Icons.fingerprint, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.brown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: villeController,
                  decoration: InputDecoration(
                    labelText: 'Ville',
                    prefixIcon:
                        const Icon(Icons.location_city, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.brown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quartierController,
                  decoration: InputDecoration(
                    labelText: 'Quartier',
                    prefixIcon: const Icon(Icons.map, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.brown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lienGoogleMapsController,
                  decoration: InputDecoration(
                    labelText: 'Lien Google Maps',
                    prefixIcon: const Icon(Icons.link, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.brown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: logoController,
                  decoration: InputDecoration(
                    labelText: 'URL du Logo',
                    prefixIcon: const Icon(Icons.image, color: Colors.brown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.brown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.brown, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.brown[50],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (nomController.text.isEmpty ||
                            immatriculationController.text.isEmpty ||
                            villeController.text.isEmpty ||
                            quartierController.text.isEmpty ||
                            lienGoogleMapsController.text.isEmpty ||
                            logoController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tous les champs sont requis'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        try {
                          await _service.create({
                            'nom': nomController.text,
                            'immatriculation': immatriculationController.text,
                            'ville': villeController.text,
                            'quartier': quartierController.text,
                            'lien_google_maps': lienGoogleMapsController.text,
                            'logo': logoController.text,
                            'sup': false,
                          });
                          Navigator.pop(context);
                          _loadData();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur lors de l\'ajout: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child:
                          const Text('Ajouter', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarOpen ? 250 : 70,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.brown[900],
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 0)),
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
                            fontSize: 18,
                          ),
                        )
                      : null,
                  onTap: _toggleSidebar,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSidebarItem(
                        Icons.home,
                        'Accueil',
                        () => Navigator.pushNamed(context, Routes.home),
                      ),
                      _buildSidebarItem(
                        Icons.view_agenda,
                        'Maisons',
                        () => Navigator.pushNamed(context, Routes.maisons),
                      ),
                      _buildSidebarItem(
                        Icons.business,
                        'Agences',
                        () => setState(() {}),
                        true,
                      ),
                      _buildSidebarItem(
                        Icons.location_on,
                        'Locations',
                        () => Navigator.pushNamed(context, Routes.locations),
                      ),
                      _buildSidebarItem(
                        Icons.payment,
                        'Paiements',
                        () => Navigator.pushNamed(context, Routes.paiements),
                      ),
                      _buildSidebarItem(
                        Icons.warning,
                        'Pénalités',
                        () => Navigator.pushNamed(context, Routes.penalites),
                      ),
                      _buildSidebarItem(
                        Icons.description,
                        'Types de Documents',
                        () =>
                            Navigator.pushNamed(context, Routes.type_documents),
                      ),
                      _buildSidebarItem(
                        Icons.location_city,
                        'Communes',
                        () => Navigator.pushNamed(context, Routes.communes),
                      ),
                      _buildSidebarItem(
                        Icons.lightbulb,
                        'Commodités',
                        () => Navigator.pushNamed(context, Routes.commodites),
                      ),
                      _buildSidebarItem(
                        Icons.house,
                        'Commodités Maisons',
                        () => Navigator.pushNamed(
                            context, Routes.commoditeMaisons),
                      ),
                      _buildSidebarItem(
                        Icons.photo,
                        'Photos',
                        () => Navigator.pushNamed(context, Routes.photos),
                      ),
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.brown[600]!, Colors.brown[800]!],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Agences Immobilières',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            onPressed: _loadData,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.brown))
                        : _items.isEmpty
                            ? Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 50),
                                    Icon(
                                      Icons.business_outlined,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Aucune agence pour le moment',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return Card(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.brown[100],
                                        child: const Icon(
                                          Icons.business,
                                          color: Colors.brown,
                                        ),
                                      ),
                                      title: Text(
                                        item['nom'] ?? 'Sans nom',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.brown,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Immatriculation: ${item['immatriculation']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'Ville: ${item['ville']}, Quartier: ${item['quartier']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'Supprimé: ${item['sup'] ? 'Oui' : 'Non'}',
                                              style: TextStyle(
                                                color: item['sup']
                                                    ? Colors.redAccent
                                                    : Colors.green,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blueAccent,
                                            ),
                                            onPressed: () {
                                              // Ajouter une fonction d'édition ici
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () =>
                                                _deleteItem(item['id']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Ajouter une Agence',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[300],
              size: 26,
            ),
            title: _isSidebarOpen
                ? Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  )
                : null,
            onTap: onTap,
            tileColor: isSelected ? Colors.brown[600] : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
