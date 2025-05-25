import 'package:flutter/material.dart';
import 'package:gestion_immo/core/config/constants/routes.dart';
import 'package:gestion_immo/data/services/auth_service.dart';
import 'package:gestion_immo/features/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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

    try {
      final result = await _authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (result['success']) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur de connexion';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau : $e';
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

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas';
        _isLoading = false;
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
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Erreur d\'inscription';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau : $e';
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

    try {
      final result =
          await _authService.resetPassword(email: _emailController.text);
      if (result['success']) {
        setState(() {
          _errorMessage = result['message'] ??
              'Un lien de réinitialisation a été envoyé à votre e-mail.';
          _isResetPasswordMode = false;
          _emailController.clear();
        });
      } else {
        setState(() {
          _errorMessage =
              result['error'] ?? 'Erreur lors de la réinitialisation';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur réseau : $e';
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

    try {
      await _authService.signInWithGoogle();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la connexion Google : $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
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
                        Icons.home,
                        size: 80,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bienvenue sur ImmoGest',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
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
                              Icon(Icons.email, color: Colors.blue.shade900),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (!_isResetPasswordMode &&
                        !_errorMessage.contains('réinitialisation')) ...[
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Nom d\'utilisateur',
                          prefixIcon:
                              Icon(Icons.person, color: Colors.blue.shade900),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon:
                              Icon(Icons.lock, color: Colors.blue.shade900),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blue.shade900,
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
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Colors.blue.shade900),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue.shade900,
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
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.blue.shade900)
                        : Column(
                            children: [
                              if (_isResetPasswordMode) ...[
                                ElevatedButton(
                                  onPressed: _resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade900,
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
                                    style:
                                        TextStyle(color: Colors.blue.shade900),
                                  ),
                                ),
                              ] else ...[
                                ElevatedButton(
                                  onPressed: _showRegister ? _register : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade900,
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
                                    foregroundColor: Colors.blue.shade900,
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
                                      _usernameController.clear();
                                      _passwordController.clear();
                                      _emailController.clear();
                                      _confirmPasswordController.clear();
                                    });
                                  },
                                  child: Text(
                                    _showRegister
                                        ? 'Déjà un compte ? Se connecter'
                                        : 'Pas de compte ? S\'inscrire',
                                    style:
                                        TextStyle(color: Colors.blue.shade900),
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
