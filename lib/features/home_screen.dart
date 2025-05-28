// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Constructeur constant explicite

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarOpen = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Utilisateur';
    });
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
          // Barre latérale permanente
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
                      _buildSidebarItem(
                          Icons.home, 'Accueil', () => setState(() {}), true),
                      _buildSidebarItem(Icons.view_agenda, 'Maisons',
                          () => Navigator.pushNamed(context, Routes.maisons)),
                      _buildSidebarItem(Icons.business, 'Agences',
                          () => Navigator.pushNamed(context, Routes.agences)),
                      _buildSidebarItem(Icons.location_on, 'Locations',
                          () => Navigator.pushNamed(context, Routes.locations)),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gestion Immo',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Bienvenue, $_username',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications,
                              color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Grille des fonctionnalités
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tableau de bord',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 600,
                          child: GridView.count(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 600 ? 4 : 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: [
                              _buildFeatureCard(Icons.home, 'Maisons',
                                  Routes.maisons, Colors.amber),
                              _buildFeatureCard(Icons.business, 'Agences',
                                  Routes.agences, Colors.orange),
                              _buildFeatureCard(Icons.location_on, 'Locations',
                                  Routes.locations, Colors.green),
                              _buildFeatureCard(Icons.payment, 'Paiements',
                                  Routes.paiements, Colors.teal),
                              _buildFeatureCard(Icons.warning, 'Pénalités',
                                  Routes.penalites, Colors.red),
                              _buildFeatureCard(
                                  Icons.description,
                                  'Types de Documents',
                                  Routes.type_documents,
                                  Colors.indigo),
                              _buildFeatureCard(Icons.location_city, 'Communes',
                                  Routes.communes, Colors.purple),
                              _buildFeatureCard(Icons.lightbulb, 'Commodités',
                                  Routes.commodites, Colors.blue),
                              _buildFeatureCard(
                                  Icons.house,
                                  'Commodités Maisons',
                                  Routes.commoditeMaisons,
                                  Colors.cyan),
                              _buildFeatureCard(Icons.photo, 'Photos',
                                  Routes.photos, Colors.deepPurple),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildFeatureCard(
      IconData icon, String title, String route, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, color.withOpacity(0.1)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: color),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
