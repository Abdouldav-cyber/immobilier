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
        SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap,
      [bool isSelected = false]) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: title,
        child: ListTile(
          leading: Icon(icon,
              color: isSelected ? Colors.white : Colors.grey[300], size: 26),
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
          tileColor: isSelected ? Colors.teal[700] : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                SizedBox(height: 10),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          Container(
            width: _isSidebarOpen ? 250 : 70,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal[900],
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(2, 0))
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(_isSidebarOpen ? MdiIcons.close : MdiIcons.menu,
                      color: Colors.white),
                  title: _isSidebarOpen
                      ? Text(
                          'Menu',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )
                      : null,
                  onTap: _toggleSidebar,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _buildSidebarItem(
                          Icons.home,
                          'Accueil',
                          () => Navigator.pushNamed(context, Routes.home),
                          true),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _buildSidebarItem(Icons.view_agenda, 'Maisons',
                          () => Navigator.pushNamed(context, Routes.maisons)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _buildSidebarItem(Icons.business, 'Agences',
                          () => Navigator.pushNamed(context, Routes.agences)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _buildSidebarItem(Icons.location_on, 'Locations',
                          () => Navigator.pushNamed(context, Routes.locations)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _buildSidebarItem(Icons.payment, 'Paiements',
                          () => Navigator.pushNamed(context, Routes.paiements)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _buildSidebarItem(Icons.warning, 'Pénalités',
                          () => Navigator.pushNamed(context, Routes.penalites)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _buildSidebarItem(Icons.photo, 'Photos',
                          () => Navigator.pushNamed(context, Routes.photos)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _buildSidebarItem(
                          Icons.settings,
                          'Paramètres',
                          () =>
                              Navigator.pushNamed(context, Routes.parametres)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.teal[600]!, Colors.teal[800]!]),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestion Immo',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              'Bienvenue, $_username',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white70),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: Icon(Icons.logout, color: Colors.white),
                          label: Text('Déconnexion',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[900],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tableau de bord',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[900]),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 600,
                          child: GridView.count(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 600 ? 4 : 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
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
}
