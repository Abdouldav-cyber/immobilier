import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/features/agence/agence_screen.dart' as agence;
import 'package:gestion_immo/features/agences/agences_screen.dart' as agences;
import 'package:gestion_immo/features/commune/commune_screen.dart' as commune;
import 'package:gestion_immo/features/commodite_maisons/commodite_maisons_screen.dart';
import 'package:gestion_immo/features/commodites/commodites_screen.dart';
import 'package:gestion_immo/features/communes/communes_screen.dart';
import 'package:gestion_immo/features/home/home_screen.dart';
import 'package:gestion_immo/features/locations/locations_screen.dart';
import 'package:gestion_immo/features/maisons/maisons_screen.dart';
import 'package:gestion_immo/features/paiements/paiements_screen.dart';
import 'package:gestion_immo/features/penalites/penalites_screen.dart';
import 'package:gestion_immo/features/photos/photos_screen.dart';
import 'package:gestion_immo/features/auth/login_screen.dart';
import 'package:gestion_immo/features/type_document/type_document_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isAuthenticated = await AuthService().isAuthenticated();
  runApp(MyApp(
    initialRoute: isAuthenticated ? Routes.home : Routes.login,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmoGest',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardTheme(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.brown),
          bodyMedium: TextStyle(color: Colors.grey),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: {
        Routes.home: (context) => const HomeScreen(),
        Routes.maisons: (context) => const MaisonsScreen(),
        Routes.agences: (context) => const agences.AgenceScreen(),
        Routes.locations: (context) => const LocationsScreen(),
        Routes.paiements: (context) => PaiementsScreen(),
        Routes.penalites: (context) => PenalitesScreen(),
        Routes.type_documents: (context) => const TypeDocumentsScreen(),
        Routes.communes: (context) => commune.CommuneScreen(), // Corrigé
        Routes.commodites: (context) => CommoditesScreen(),
        Routes.commoditeMaisons: (context) => CommoditeMaisonsScreen(),
        Routes.photos: (context) => PhotosScreen(),
        Routes.login: (context) => const LoginScreen(),
      },
    );
  }
}
