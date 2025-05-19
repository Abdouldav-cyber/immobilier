import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/features/home/home_screen.dart';
import 'package:gestion_immo/features/maisons/maisons_screen.dart';
import 'package:gestion_immo/features/agences/agences_screen.dart';
import 'package:gestion_immo/features/locations/locations_screen.dart';
import 'package:gestion_immo/features/paiements/paiements_screen.dart';
import 'package:gestion_immo/features/penalites/penalites_screen.dart';
import 'package:gestion_immo/features/documents/documents_screen.dart';
import 'package:gestion_immo/features/communes/communes_screen.dart';
import 'package:gestion_immo/features/commodites/commodites_screen.dart';
import 'package:gestion_immo/features/commodite_maisons/commodite_maisons_screen.dart';
import 'package:gestion_immo/features/photos/photos_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Immo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) => HomeScreen(),
        Routes.maisons: (context) => MaisonsScreen(),
        Routes.agences: (context) => AgencesScreen(),
        Routes.locations: (context) => LocationsScreen(),
        Routes.paiements: (context) => PaiementsScreen(),
        Routes.penalites: (context) => PenalitesScreen(),
        Routes.documents: (context) => DocumentsScreen(),
        Routes.communes: (context) => CommunesScreen(),
        Routes.commodites: (context) => CommoditesScreen(),
        Routes.commoditeMaisons: (context) => CommoditeMaisonsScreen(),
        Routes.photos: (context) => PhotosScreen(),
      },
    );
  }
}
