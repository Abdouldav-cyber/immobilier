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
  bool _isEntitiesVisible = true;

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

  void _toggleEntities() {
    setState(() {
      _isEntitiesVisible = !_isEntitiesVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2 > 250
                ? 250
                : MediaQuery.of(context).size.width * 0.2 < 200
                    ? 200
                    : MediaQuery.of(context).size.width * 0.2,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal[900],
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
                      fontSize: 18,
                    ),
                  ),
                  onTap: _toggleEntities,
                ),
                if (_isEntitiesVisible)
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSidebarItem(
                            Icons.home, 'Accueil', () => setState(() {}), true),
                        _buildSidebarItem(Icons.view_agenda, 'Maisons', () {
                          Navigator.pushNamed(context, Routes.maisons);
                          setState(() {
                            _isEntitiesVisible = false;
                          });
                        }),
                        _buildSidebarItem(Icons.business, 'Agences', () {
                          Navigator.pushNamed(context, Routes.agences);
                          setState(() {
                            _isEntitiesVisible = false;
                          });
                        }),
                        _buildSidebarItem(Icons.location_on, 'Locations', () {
                          Navigator.pushNamed(context, Routes.locations);
                          setState(() {
                            _isEntitiesVisible = false;
                          });
                        }),
                        _buildSidebarItem(Icons.payment, 'Paiements', () {
                          Navigator.pushNamed(context, Routes.paiements);
                          setState(() {
                            _isEntitiesVisible = false;
                          });
                        }),
                        _buildSidebarItem(Icons.warning, 'Pénalités', () {
                          Navigator.pushNamed(context, Routes.penalites);
                          setState(() {
                            _isEntitiesVisible = false;
                          });
                        }),
                        _buildSidebarItem(Icons.settings, 'Paramètres', () {
                          Navigator.pushNamed(context, Routes.parametres);
                          setState(() {
                            _isEntitiesVisible = false;
                          });
                        }),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Tooltip(
                            message: 'Déconnexion',
                            child: ListTile(
                              leading:
                                  Icon(Icons.logout, color: Colors.grey[300]),
                              title: Text(
                                'Déconnexion',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[600]!, Colors.teal[800]!],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gestion Immo',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.teal[200]!, Colors.teal[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.home_work,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Bienvenue sur votre espace ImmoGest !',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[900],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Gérez vos propriétés, paiements et plus encore depuis un seul endroit. Explorez les sections pour commencer.',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onTap: onTap,
          tileColor: isSelected ? Colors.teal[600] : null,
        ),
      ),
    );
  }
}
