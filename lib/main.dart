import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/features/agences/agences_screen.dart';
import 'package:gestion_immo/features/auth/login_screen.dart';
import 'package:gestion_immo/features/home_screen.dart';
import 'package:gestion_immo/features/locations/locations_screen.dart';
import 'package:gestion_immo/features/maisons/maisons_screen.dart';
import 'package:gestion_immo/features/paiements/paiements_screen.dart';
import 'package:gestion_immo/features/penalites/penalites_screen.dart';
import 'package:gestion_immo/features/photos/photos_screen.dart';
import 'package:gestion_immo/features/parametres/parametres_screen.dart';
import 'package:gestion_immo/widgets/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return MaterialApp(
      title: 'ImmoGest',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: Routes.initial,
      routes: {
        Routes.initial: (context) => AuthWrapper(authService: authService),
        Routes.login: (context) => const LoginScreen(),
        Routes.home: (context) => AuthGuard(
              authService: authService,
              child: HomeScreen(),
            ),
        Routes.maisons: (context) => AuthGuard(
              authService: authService,
              child: MaisonsScreen(),
            ),
        Routes.agences: (context) => AuthGuard(
              authService: authService,
              child: AgencesScreen(),
            ),
        Routes.locations: (context) => AuthGuard(
              authService: authService,
              child: LocationsScreen(),
            ),
        Routes.paiements: (context) => AuthGuard(
              authService: authService,
              child: PaiementsScreen(),
            ),
        Routes.penalites: (context) => AuthGuard(
              authService: authService,
              child: PenalitesScreen(),
            ),
        Routes.photos: (context) => AuthGuard(
              authService: authService,
              child: PhotosScreen(),
            ),
        Routes.parametres: (context) => AuthGuard(
              authService: authService,
              child: const ParametresScreen(),
            ),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService authService;

  const AuthWrapper({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, Routes.home);
          });
          return const SizedBox.shrink();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, Routes.login);
        });
        return const SizedBox.shrink();
      },
    );
  }
}
