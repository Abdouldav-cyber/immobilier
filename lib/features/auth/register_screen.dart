import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/models/services/auth_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants/routes.dart';
import '../../data/services/auth_service.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _error;
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.signUp(
        _emailController.text,
        _passwordController.text,
        _firstNameController.text,
        _lastNameController.text,
      );
      Navigator.pushReplacementNamed(context, Routes.login);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Icon(
                MdiIcons.accountPlus,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Créer un compte',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              controller: _firstNameController,
              label: 'Prénom',
              icon: MdiIcons.account,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _lastNameController,
              label: 'Nom',
              icon: MdiIcons.account,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              icon: MdiIcons.email,
              errorText:
                  _error != null && _error!.contains('email') ? _error : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: 'Mot de passe',
              obscureText: true,
              icon: MdiIcons.lock,
              errorText: _error != null && _error!.contains('password')
                  ? _error
                  : null,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'S\'inscrire',
              icon: MdiIcons.accountPlus,
              onPressed: _register,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.login),
                child: Text(
                  'Déjà un compte ? Se connecter',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
