import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/features/authentication/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginEmailPage extends StatefulWidget {
  @override
  _LoginEmailPageState createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'enter_email';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'invalid_email';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'enter_password';
    }
    if (password.length < 6) {
      return 'password_too_short';
    }
    return null;
  }

  void _handleLogin() {
    final emailError = _validateEmail(emailController.text);
    final passwordError = _validatePassword(passwordController.text);

    if (emailError != null || passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t(emailError ?? passwordError ?? 'error')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    context.read<AuthProvider>().loginWithEmail(
      emailController.text,
      passwordController.text,
    );
  }

  void _handleRegister() {
    final emailError = _validateEmail(emailController.text);
    final passwordError = _validatePassword(passwordController.text);

    if (emailError != null || passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t(emailError ?? passwordError ?? 'error')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    context.read<AuthProvider>().registerWithEmail(
      emailController.text,
      passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: ColorTokens.primary30,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.kBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  // Handle authentication success
                  if (auth.state == AuthState.authenticated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (auth.needsProfileSetup) {
                        context.go(AppRoutes.profile);
                      } else {
                        context.go(AppRoutes.roadsList);
                      }
                    });
                  }

                  // Handle authentication errors
                  if (auth.state == AuthState.error &&
                      auth.errorMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: ColorTokens.primary30,
                          title: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                l.t('error'),
                                style: TextStyle(color: ColorTokens.neutral100),
                              ),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              auth.errorMessage ?? l.t('unknown_error'),
                              style: TextStyle(color: ColorTokens.neutral100),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                context.read<AuthProvider>().clearError();
                              },
                              child: Text(
                                l.t('ok'),
                                style: TextStyle(
                                  color: ColorTokens.secondary50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(Images.kBiuxLogoLettersWhite, width: 200),
                      SizedBox(height: 50),
                      Text(
                        _isLogin ? l.t('login') : l.t('register'),
                        style: TextStyle(
                          color: ColorTokens.neutral100,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: auth.state != AuthState.loading,
                        decoration: InputDecoration(
                          labelText: l.t('email'),
                          labelStyle: TextStyle(color: ColorTokens.neutral100),
                          prefixIcon: Icon(
                            Icons.email,
                            color: ColorTokens.neutral100,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: ColorTokens.neutral100,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: ColorTokens.neutral100,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: ColorTokens.secondary50,
                            ),
                          ),
                        ),
                        style: TextStyle(color: ColorTokens.neutral100),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        enabled: auth.state != AuthState.loading,
                        decoration: InputDecoration(
                          labelText: l.t('password'),
                          labelStyle: TextStyle(color: ColorTokens.neutral100),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: ColorTokens.neutral100,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: ColorTokens.neutral100,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: ColorTokens.neutral100,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: ColorTokens.neutral100,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: ColorTokens.secondary50,
                            ),
                          ),
                        ),
                        style: TextStyle(color: ColorTokens.neutral100),
                      ),
                      SizedBox(height: 20),
                      if (auth.state == AuthState.loading)
                        CircularProgressIndicator(
                          color: ColorTokens.secondary50,
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTokens.secondary50,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _isLogin ? _handleLogin : _handleRegister,
                          child: Text(
                            _isLogin ? l.t('login') : l.t('register'),
                            style: TextStyle(
                              color: ColorTokens.neutral100,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: auth.state != AuthState.loading
                            ? () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  emailController.clear();
                                  passwordController.clear();
                                });
                              }
                            : null,
                        child: Text(
                          _isLogin
                              ? l.t('no_account_register')
                              : l.t('have_account_login'),
                          style: TextStyle(color: ColorTokens.secondary50),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
