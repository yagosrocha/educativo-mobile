import 'dart:async';

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

@immutable
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const path = '/login';

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _initalized = ValueNotifier<bool>(false);
  final _loading = ValueNotifier<bool>(false);
  final _user = ValueNotifier<clerk.User?>(null);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final StreamSubscription<clerk.AuthError> _errorSubscription;
  late final ClerkAuthState _authState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authState = ClerkAuth.of(context);
      _user.value = _authState.user;
      _authState.addListener(_clerkAuthListener);
      _errorSubscription = _authState.errorStream.listen(_onError);
      _initalized.value = true;
    });
  }

  void _clerkAuthListener() {
    final user = _authState.user;
    _user.value = user;
  }

  void _onError(clerk.AuthError error) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    _loading.value = true;
    try {
      await _authState.attemptSignIn(
        strategy: clerk.Strategy.password,
        identifier: _emailController.text,
        password: _passwordController.text,
      );
    } finally {
      _loading.value = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _authState.removeListener(_clerkAuthListener);
    _errorSubscription.cancel();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    VoidCallback? onSubmitted,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: (_) => onSubmitted?.call(),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF1D2D5E), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D2D5E),
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: const Color(0xFF1D2D5E).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: ListenableBuilder(
          listenable: _initalized,
          builder: (context, _) {
            if (!_initalized.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1D2D5E)),
              );
            }
            return ValueListenableBuilder<bool>(
              valueListenable: _loading,
              builder: (context, bool loading, child) {
                if (loading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF1D2D5E)),
                        SizedBox(height: 16),
                                                 Text(
                           'Entrando...',
                           style: TextStyle(fontSize: 16, color: Colors.grey),
                         ),
                      ],
                    ),
                  );
                }
                return ValueListenableBuilder<clerk.User?>(
                  valueListenable: _user,
                  builder: (context, clerk.User? user, child) {
                    if (user != null) {
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                                                         const Text('Conectado!'),
                            const SizedBox(height: 16),
                            if (user.profileImageUrl case String imageUrl) ...[
                              CircleAvatar(
                                backgroundImage: NetworkImage(imageUrl),
                                radius: 32.0,
                              ),
                              const SizedBox(height: 16),
                            ],
                                                         Text('Email: ${user.email}'),
                             const SizedBox(height: 16),
                             if (user.username case String username) ...[
                               Text('Nome de usuário: $username'),
                               const SizedBox(height: 16),
                             ],
                             Text('Nome: ${user.firstName}'),
                             const SizedBox(height: 16),
                             Text('Sobrenome: ${user.lastName}'),
                             const SizedBox(height: 16),
                             ElevatedButton(
                               onPressed: () => _authState.signOut(),
                               child: const Text('Sair'),
                             ),
                          ],
                        ),
                      );
                    }
                    return SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            // Login Card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Educativo Logo Banner
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 24,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1D2D5E),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/logo-white.png',
                                          height: 60,
                                          fit: BoxFit.contain,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'EDUCATIVO',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                  // Login Form Content
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        // Welcome Text
                                        Text(
                                          'Digite suas credenciais para iniciar sessão',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 32),

                                        // Email Field
                                        _buildTextField(
                                          controller: _emailController,
                                          label: 'Endereço de Email',
                                          icon: Icons.email_outlined,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                        ),

                                        // Password Field
                                        _buildTextField(
                                          controller: _passwordController,
                                          label: 'Senha',
                                          icon: Icons.lock_outlined,
                                          isPassword: true,
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: _signIn,
                                        ),

                                        // Sign In Button
                                        _buildLoginButton(
                                          text: 'Entrar',
                                          onPressed: _signIn,
                                          isLoading: loading,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
