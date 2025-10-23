import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/features/authentication/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPhonePage extends StatefulWidget {
  @override
  _LoginPhonePageState createState() => _LoginPhonePageState();
}

class _LoginPhonePageState extends State<LoginPhonePage> {
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    phoneController.dispose();
    for (var c in codeControllers) {
      c.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleSendCode() {
    if (phoneController.text.isNotEmpty) {
      context.read<AuthProvider>().sendCode(phoneController.text);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ingresa tu teléfono')));
    }
  }

  void _handleValidateCode() {
    String code = codeControllers.map((c) => c.text).join();
    if (code.length == 6) {
      context.read<AuthProvider>().validateCode(code);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ingresa los 6 dígitos')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Manejar estados de autenticación
                  if (auth.state == AuthState.authenticated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go(AppRoutes.roadsList); // Redirigir a rodadas
                    });
                  }

                  if (auth.state == AuthState.error &&
                      auth.errorMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(auth.errorMessage!),
                          action: SnackBarAction(
                            label: 'OK',
                            onPressed: () {
                              context.read<AuthProvider>().clearError();
                            },
                          ),
                        ),
                      );
                    });
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(Images.kBiuxLogoLettersWhite, width: 200),
                      SizedBox(height: 50),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: auth.state != AuthState.loading,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          labelStyle: TextStyle(color: ColorTokens.neutral100),
                          prefixIcon: Icon(
                            Icons.phone,
                            color: ColorTokens.secondary50,
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
                      else if (auth.state != AuthState.codeSent)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTokens.secondary50,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _handleSendCode,
                          child: Text(
                            'Enviar código',
                            style: TextStyle(
                              color: ColorTokens.neutral100,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (auth.state == AuthState.codeSent) ...[
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (i) => SizedBox(
                              width: 40,
                              child: TextField(
                                controller: codeControllers[i],
                                focusNode: focusNodes[i],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                enabled: auth.state != AuthState.loading,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: ColorTokens.neutral100),
                                onChanged: (value) {
                                  if (value.isNotEmpty && i < 5) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(focusNodes[i + 1]);
                                  } else if (value.isEmpty && i > 0) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(focusNodes[i - 1]);
                                  }
                                },
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.1,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: ColorTokens.neutral100,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: ColorTokens.neutral100,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: ColorTokens.secondary50,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTokens.secondary50,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: auth.state != AuthState.loading
                              ? _handleValidateCode
                              : null,
                          child: Text(
                            'Validar código',
                            style: TextStyle(
                              color: ColorTokens.neutral100,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: auth.canResendCode
                                ? ColorTokens.secondary50
                                : ColorTokens.neutral60,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed:
                              auth.canResendCode &&
                                  auth.state != AuthState.loading
                              ? () => context.read<AuthProvider>().resendCode()
                              : null,
                          child: auth.canResendCode
                              ? Text(
                                  'Reenviar código',
                                  style: TextStyle(
                                    color: ColorTokens.neutral100,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'Reenviar en ${auth.resendSeconds} s',
                                  style: TextStyle(
                                    color: ColorTokens.neutral100,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ],
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
