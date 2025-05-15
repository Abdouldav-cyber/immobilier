import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/features/auth/home/home_screen.dart';
import 'core/config/app_config.dart';
import 'core/constants/routes.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/home/home_screen.dart';
import 'features/properties/properties_screen.dart';
import 'features/properties/add_property_screen.dart';
import 'features/locations/locations_screen.dart';
import 'features/locations/add_location_screen.dart';
import 'features/payments/payments_screen.dart';
import 'features/payments/add_payment_screen.dart';
import 'features/agencies/agencies_screen.dart';
import 'features/agencies/add_agency_screen.dart';
import 'features/map/map_screen.dart';
import 'shared/themes/app_theme.dart';

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
      initialRoute: Routes.login,
      routes: {
        Routes.login: (context) => const LoginScreen(),
        Routes.register: (context) => const RegisterScreen(),
        Routes.forgotPassword: (context) => const ForgotPasswordScreen(),
        Routes.home: (context) => const HomeScreen(),
        Routes.properties: (context) => const PropertiesScreen(),
        Routes.addProperty: (context) => const AddPropertyScreen(),
        Routes.locations: (context) => const LocationsScreen(),
        Routes.addLocation: (context) => const AddLocationScreen(),
        Routes.payments: (context) => const PaymentsScreen(),
        Routes.addPayment: (context) => const AddPaymentScreen(),
        Routes.agencies: (context) => const AgenciesScreen(),
        Routes.addAgency: (context) => const AddAgencyScreen(),
        Routes.map: (context) => const MapScreen(),
      },
    );
  }
}
