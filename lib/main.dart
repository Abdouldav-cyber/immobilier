import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/app_config.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/features/home/home_screen.dart';
import 'package:gestion_immo/features/properties/properties_screen.dart';
import 'package:gestion_immo/features/agencies/agencies_screen.dart';
import 'package:gestion_immo/features/locations/locations_screen.dart';
import 'package:gestion_immo/features/paiments/paiments_screen.dart';
import 'package:gestion_immo/features/penalites/penalites_screen.dart';
import 'package:gestion_immo/features/documents/documents_screen.dart';
import 'package:gestion_immo/features/communes/communes_screen.dart';
import 'package:gestion_immo/features/commodites/commodites_screen.dart';
import 'package:gestion_immo/features/commodite_maisons/commodite_maisons_screen.dart';
import 'package:gestion_immo/features/photos/photos_screen.dart';
import 'package:gestion_immo/shared/themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GestionImmoApp());
}

class GestionImmoApp extends StatelessWidget {
  const GestionImmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => const HomeScreen(),
        Routes.properties: (context) => const PropertiesScreen(),
        Routes.agencies: (context) => const AgenciesScreen(),
        Routes.locations: (context) => const LocationsScreen(),
        Routes.paiments: (context) => const PaimentsScreen(),
        Routes.penalites: (context) => const PenalitesScreen(),
        Routes.documents: (context) => const DocumentsScreen(),
        Routes.communes: (context) => const CommunesScreen(),
        Routes.commodites: (context) => const CommoditesScreen(),
        Routes.commoditeMaisons: (context) => const CommoditeMaisonsScreen(),
        Routes.photos: (context) => const PhotosScreen(),
      },
    );
  }
}
