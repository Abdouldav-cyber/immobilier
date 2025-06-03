import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/features/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _showRegister = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isResetPasswordMode = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    print('Tentative de connexion avec email: ${_emailController.text}');

    try {
      final result = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result['success']) {
        print('Connexion réussie, navigation vers la page d\'accueil');
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur de connexion';
          print('Erreur de connexion: $_errorMessage');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau : $e';
        print('Erreur réseau lors de la connexion: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    print(
        'Tentative d\'inscription avec email: ${_emailController.text}, username: ${_usernameController.text}');

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas';
        _isLoading = false;
        print('Erreur d\'inscription: Les mots de passe ne correspondent pas');
      });
      return;
    }

    try {
      final response = await _authService.register(
        email: _emailController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (response['success']) {
        setState(() {
          _errorMessage = 'Inscription réussie ! Connectez-vous maintenant.';
          _showRegister = false;
          print('Inscription réussie');
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Erreur d\'inscription';
          print('Erreur d\'inscription: $_errorMessage');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau : $e';
        print('Erreur réseau lors de l\'inscription: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    print('Tentative de réinitialisation pour email: ${_emailController.text}');

    try {
      final result =
          await _authService.resetPassword(email: _emailController.text);
      if (result['success']) {
        setState(() {
          _errorMessage = result['message'] ??
              'Un lien de réinitialisation a été envoyé à votre e-mail.';
          _isResetPasswordMode = false;
          _emailController.clear();
          print('Réinitialisation réussie: $_errorMessage');
        });
      } else {
        setState(() {
          _errorMessage =
              result['error'] ?? 'Erreur lors de la réinitialisation';
          print('Erreur de réinitialisation: $_errorMessage');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau : $e';
        print('Erreur réseau lors de la réinitialisation: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    print('Simulation de connexion avec Google');

    try {
      // Simulation de la connexion Google
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Simulation'),
          content: const Text('Connexion Google simulée avec succès !'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.home);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      print('Connexion Google simulée réussie');
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la simulation Google : $e';
        print('Erreur lors de la simulation Google: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[900]!, Colors.teal[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: 16.0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.8 > 400
                    ? 400
                    : MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.teal[900],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Veuillez vous connecter',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_isResetPasswordMode ||
                        _showRegister ||
                        _errorMessage.contains('réinitialisation')) ...[
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              Icon(Icons.email, color: Colors.teal[900]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (!_isResetPasswordMode &&
                        !_errorMessage.contains('réinitialisation')) ...[
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              Icon(Icons.email, color: Colors.teal[900]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock, color: Colors.teal[900]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.teal[900],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        obscureText: _obscurePassword,
                      ),
                      if (_showRegister) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon:
                                Icon(Icons.person, color: Colors.teal[900]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Colors.teal[900]),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.teal[900],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          obscureText: _obscureConfirmPassword,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isResetPasswordMode = true;
                              _errorMessage = '';
                              _emailController.clear();
                            });
                          },
                          child: Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(color: Colors.teal[900]),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.teal[900])
                        : Column(
                            children: [
                              if (_isResetPasswordMode) ...[
                                ElevatedButton(
                                  onPressed: _resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[900],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Réinitialiser le mot de passe',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isResetPasswordMode = false;
                                      _errorMessage = '';
                                      _emailController.clear();
                                    });
                                  },
                                  child: Text(
                                    'Retour à la connexion',
                                    style: TextStyle(color: Colors.teal[900]),
                                  ),
                                ),
                              ] else ...[
                                ElevatedButton(
                                  onPressed: _showRegister ? _register : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[900],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _showRegister
                                        ? 'S\'inscrire'
                                        : 'Se connecter',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: _signInWithGoogle,
                                  icon: const Icon(Icons.account_circle),
                                  label: const Text('Connexion avec Google'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.teal[900],
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showRegister = !_showRegister;
                                      _errorMessage = '';
                                      _emailController.clear();
                                      _passwordController.clear();
                                      _confirmPasswordController.clear();
                                      _usernameController.clear();
                                    });
                                  },
                                  child: Text(
                                    _showRegister
                                        ? 'Déjà un compte ? Se connecter'
                                        : 'Pas de compte ? S\'inscrire',
                                    style: TextStyle(color: Colors.teal[900]),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
