import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          // Sidebar permanente
          Container(
            width: 250,
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
                  leading: Icon(MdiIcons.menu, color: Colors.white),
                  title: const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                          Icons.settings,
                          'Paramètres',
                          () =>
                              Navigator.pushNamed(context, Routes.parametres)),
                      _buildSidebarItem(Icons.photo, 'Photos',
                          () => Navigator.pushNamed(context, Routes.photos)),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Tooltip(
                          message: 'Déconnexion',
                          child: ListTile(
                            leading:
                                Icon(Icons.logout, color: Colors.grey[300]),
                            title: Text(
                              'Déconnexion',
                              style: TextStyle(color: Colors.grey[300]),
                            ),
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
                  // Navbar (inchangée)
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
                  // Nouveau design du tableau de bord
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
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Bienvenue sur votre espace ImmoGest !',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Image.asset(
                                'assets/dashboard_banner.png', // Remplacez par votre image d'accueil
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Gérez vos propriétés, paiements et plus encore depuis un seul endroit. Explorez les sections pour commencer.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[300],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
          tileColor: isSelected ? Colors.brown[600] : null,
        ),
      ),
    );
  }
}
