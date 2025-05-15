import 'package:flutter/material.dart';
import 'package:gestion_immo/data/models/services/auth_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../data/services/auth_service.dart';
import '../../shared/themes/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  String? _error;
  bool _isLoading = false;
  bool _isSent = false;

  void _resetPassword() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.forgotPassword(_emailController.text);
      setState(() {
        _isSent = true;
        _isLoading = false;
      });
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
        title: const Text('Mot de passe oublié'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Icon(
                MdiIcons.lockReset,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Réinitialiser le mot de passe',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Entrez votre email pour recevoir un lien de réinitialisation',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            if (!_isSent) ...[
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                icon: MdiIcons.email,
                errorText: _error != null ? _error : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Envoyer',
                icon: MdiIcons.send,
                onPressed: _resetPassword,
                isLoading: _isLoading,
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      MdiIcons.checkCircle,
                      size: 60,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Email envoyé !',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vérifiez votre boîte de réception pour le lien de réinitialisation.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Retour à la connexion',
                      icon: MdiIcons.login,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
