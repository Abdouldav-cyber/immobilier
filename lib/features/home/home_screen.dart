import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/features/agences/agences_screen.dart';
import 'package:gestion_immo/features/commodite_maisons/commodite_maisons_screen.dart';
import 'package:gestion_immo/features/commodites/commodites_screen.dart';
import 'package:gestion_immo/features/communes/communes_screen.dart';
import 'package:gestion_immo/features/documents/documents_screen.dart';
import 'package:gestion_immo/features/locations/locations_screen.dart';
import 'package:gestion_immo/features/paiements/paiements_screen.dart';
import 'package:gestion_immo/features/penalites/penalites_screen.dart';
import 'package:gestion_immo/features/photos/photos_screen.dart';
import 'package:gestion_immo/features/maisons/maisons_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F0E7), Color(0xFFEDE1D2), Color(0xFFD4C4B1)],
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isSidebarOpen ? 250 : 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.brown[700]!, Colors.brown[900]!],
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(2, 0)),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(
                        _isSidebarOpen ? MdiIcons.close : MdiIcons.menu,
                        color: Colors.white),
                    title: _isSidebarOpen
                        ? const Text('Menu',
                            style: TextStyle(color: Colors.white))
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
                        _buildSidebarItem(
                            Icons.location_on,
                            'Locations',
                            () =>
                                Navigator.pushNamed(context, Routes.locations)),
                        _buildSidebarItem(
                            Icons.payment,
                            'Paiements',
                            () =>
                                Navigator.pushNamed(context, Routes.paiements)),
                        _buildSidebarItem(
                            Icons.warning,
                            'Pénalités',
                            () =>
                                Navigator.pushNamed(context, Routes.penalites)),
                        _buildSidebarItem(
                            Icons.description,
                            'Documents',
                            () =>
                                Navigator.pushNamed(context, Routes.documents)),
                        _buildSidebarItem(
                            Icons.location_city,
                            'Communes',
                            () =>
                                Navigator.pushNamed(context, Routes.communes)),
                        _buildSidebarItem(
                            Icons.lightbulb,
                            'Commodités',
                            () => Navigator.pushNamed(
                                context, Routes.commodites)),
                        _buildSidebarItem(
                            Icons.house,
                            'Commodités Maisons',
                            () => Navigator.pushNamed(
                                context, Routes.commoditeMaisons)),
                        _buildSidebarItem(Icons.photo, 'Photos',
                            () => Navigator.pushNamed(context, Routes.photos)),
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        Colors.brown[600]!,
                        Colors.brown[800]!
                      ])),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gestion Immo',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Icon(Icons.notifications,
                              color: Colors.white, size: 28),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bienvenue dans votre application',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3E2723))),
                          const Text('Gérez vos entités avec facilité.',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF6D4C41))),
                          const SizedBox(height: 20),
                          GridView.count(
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
                              _buildFeatureCard(Icons.description, 'Documents',
                                  Routes.documents, Colors.indigo),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onTap,
      [bool isSelected = false]) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[300]),
      title: _isSidebarOpen
          ? Text(title,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300]))
          : null,
      onTap: onTap,
      tileColor: isSelected ? Colors.brown[600] : null,
      hoverColor: Colors.brown[500],
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String route, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white.withOpacity(0.95),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
