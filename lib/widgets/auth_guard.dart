import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final AuthService authService;

  const AuthGuard({super.key, required this.child, required this.authService});

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
          return child;
        }
        // Si non authentifié, rediriger vers la page de connexion
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, Routes.login);
        });
        return const SizedBox.shrink();
      },
    );
  }
}
