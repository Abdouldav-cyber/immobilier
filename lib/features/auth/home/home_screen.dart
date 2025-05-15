import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/models/services/auth_service.dart';
import 'package:gestion_immo/shared/themes/app_theme.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants/routes.dart';
import '../../data/services/auth_service.dart';
import '../../shared/themes/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion-Immo'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tableau de bord',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    context,
                    icon: MdiIcons.home,
                    title: 'Propriétés',
                    subtitle: 'Gérer vos biens',
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.properties),
                  ),
                  _buildCard(
                    context,
                    icon: MdiIcons.contrast,
                    title: 'Locations',
                    subtitle: 'Gérer les contrats',
                    onTap: () => Navigator.pushNamed(context, Routes.locations),
                  ),
                  _buildCard(
                    context,
                    icon: MdiIcons.cash,
                    title: 'Paiements',
                    subtitle: 'Suivre les paiements',
                    onTap: () => Navigator.pushNamed(context, Routes.payments),
                  ),
                  _buildCard(
                    context,
                    icon: MdiIcons.officeBuilding,
                    title: 'Agences',
                    subtitle: 'Gérer les agences',
                    onTap: () => Navigator.pushNamed(context, Routes.agencies),
                  ),
                  _buildCard(
                    context,
                    icon: MdiIcons.map,
                    title: 'Carte',
                    subtitle: 'Voir sur la carte',
                    onTap: () => Navigator.pushNamed(context, Routes.map),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: AppTheme.primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
