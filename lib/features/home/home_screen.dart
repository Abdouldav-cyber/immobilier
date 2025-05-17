import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/shared/themes/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          DashboardCard(
            title: 'Propriétés',
            icon: MdiIcons.home,
            route: Routes.properties,
          ),
          DashboardCard(
            title: 'Agences',
            icon: MdiIcons.officeBuilding,
            route: Routes.agencies,
          ),
          DashboardCard(
            title: 'Locations',
            icon: MdiIcons.key,
            route: Routes.locations,
          ),
          DashboardCard(
            title: 'Paiements loyers', // Changé de Paiements à Paiements loyers
            icon: MdiIcons.cash,
            route: Routes.paiments, // Changé de payments à paiments
          ),
          DashboardCard(
            title: 'Pénalités',
            icon: MdiIcons.alert,
            route: Routes.penalites, // Changé de penalties à penalites
          ),
          DashboardCard(
            title: 'Documents',
            icon: MdiIcons.fileDocument,
            route: Routes.documents,
          ),
          DashboardCard(
            title: 'Communes',
            icon: MdiIcons.city,
            route: Routes.communes,
          ),
          DashboardCard(
            title: 'Commodités',
            icon: MdiIcons.lightbulb,
            route: Routes.commodites,
          ),
          DashboardCard(
            title: 'Commodité-Maisons',
            icon: MdiIcons.homeLightbulb,
            route: Routes.commoditeMaisons,
          ),
          DashboardCard(
            title: 'Photos',
            icon: MdiIcons.camera,
            route: Routes.photos,
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
