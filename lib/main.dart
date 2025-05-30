import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/features/agences/agences_screen.dart';
import 'package:gestion_immo/features/home_screen.dart';
import 'package:gestion_immo/features/locations/locations_screen.dart';
import 'package:gestion_immo/features/maisons/maisons_screen.dart';
import 'package:gestion_immo/features/paiements/paiements_screen.dart';
import 'package:gestion_immo/features/penalites/penalites_screen.dart';
import 'package:gestion_immo/features/photos/photos_screen.dart';
import 'package:gestion_immo/features/parametres/parametres_screen.dart'; // Ajout de l'import pour ParametresScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmoGest',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => HomeScreen(),
        Routes.maisons: (context) => MaisonsScreen(),
        Routes.agences: (context) => AgencesScreen(),
        Routes.locations: (context) => LocationsScreen(),
        Routes.paiements: (context) => PaiementsScreen(),
        Routes.penalites: (context) => PenalitesScreen(),
        Routes.photos: (context) => PhotosScreen(),
        // Ajout de la route pour ParametresScreen
        Routes.parametres: (context) => const ParametresScreen(),
        // Commenter les routes des écrans déplacés vers parametres/
        // Routes.communes: (context) => CommuneScreen(),
        // Routes.commodites: (context) => CommoditesScreen(),
        // Routes.commoditeMaisons: (context) => CommoditeMaisonsScreen(),
        // Routes.type_documents: (context) => TypeDocumentsScreen(),
        // Routes.type_document: (context) => TypeDocumentScreen(),
      },
    );
  }
}
