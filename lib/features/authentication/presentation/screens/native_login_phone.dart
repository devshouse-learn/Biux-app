import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/config/images.dart';
import 'package:biux/core/config/router/app_routes.dart';
import 'package:biux/features/authentication/presentation/providers/native_phone_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Pantalla de login con Firebase Phone Auth NATIVO
/// ✅ Incluye autocompletado iOS con textContentType: TextContentType.oneTimeCode
class NativeLoginPhonePage extends StatefulWidget {
  @override
  _NativeLoginPhonePageState createState() => _NativeLoginPhonePageState();
}

class _NativeLoginPhonePageState extends State<NativeLoginPhonePage> {
  final TextEditingController phoneController = TextEditingController();
  
  // Controladores individuales para los 6 dígitos (visual)
  final List<TextEditingController> codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  
  // Controlador para autocompletado iOS (invisible)
  final TextEditingController otpAutoFillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // ✅ Listener para autocompletado de iOS
    otpAutoFillController.addListener(_handleAutoFill);
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpAutoFillController.removeListener(_handleAutoFill);
    otpAutoFillController.dispose();
    for (var c in codeControllers) {
      c.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  /// ✅ Maneja el autocompletado de iOS cuando detecta el SMS
  void _handleAutoFill() {
    final code = otpAutoFillController.text;
    
    if (code.length == 6) {
      print('✅ iOS autocompletó el código: $code');
      
      // Distribuir dígitos en los 6 campos visuales
      for (int i = 0; i < 6; i++) {
        if (i < code.length) {
          codeControllers[i].text = code[i];
        }
      }
      
      // Auto-validar después de 500ms
      Future.delayed(Duration(milliseconds: 500), () {
        _handleValidateCode();
      });
    }
  }

  String? _validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      return 'Por favor ingresa tu número de teléfono';
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length != 10) {
      return 'El número debe tener 10 dígitos';
    }

    return null;
  }

  void _handleSendCode() {
    final validationError = _validatePhoneNumber(phoneController.text);

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Agregar el prefijo +57 al número antes de enviar
    final fullPhone = '+57${phoneController.text}';
    print('✅ Enviando código a: $fullPhone');
    context.read<NativePhoneAuthProvider>().sendCode(fullPhone);
  }

  void _handleValidateCode() {
    String code = codeControllers.map((c) => c.text).join();
    print('🔐 Validando código: $code');
    
    if (code.length == 6) {
      // Remover focus de los campos
      FocusScope.of(context).unfocus();
      
      context.read<NativePhoneAuthProvider>().validateCode(code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingresa los 6 dígitos'),
          backgroundColor: ColorTokens.error50,
        ),
      );
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
              child: Consumer<NativePhoneAuthProvider>(
                builder: (context, auth, child) {
                  // Manejar autenticación exitosa
                  if (auth.state == AuthState.authenticated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (auth.needsProfileSetup) {
                        context.go(AppRoutes.profile);
                      } else {
                        context.go(AppRoutes.roadsList);
                      }
                    });
                  }

                  // Mostrar errores
                  if (auth.state == AuthState.error && auth.errorMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          backgroundColor: ColorTokens.primary30,
                          title: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Error', style: TextStyle(color: ColorTokens.neutral100)),
                            ],
                          ),
                          content: Text(
                            auth.errorMessage!,
                            style: TextStyle(color: ColorTokens.neutral100),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                context.read<NativePhoneAuthProvider>().clearError();
                              },
                              child: Text('OK', style: TextStyle(color: ColorTokens.secondary50)),
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
                      
                      // Campo de teléfono
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: auth.state != AuthState.loading,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Número de teléfono',
                          hintText: '3001234567',
                          labelStyle: TextStyle(color: ColorTokens.neutral100),
                          prefixIcon: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            child: Text(
                              '+57',
                              style: TextStyle(
                                color: ColorTokens.neutral100,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: ColorTokens.neutral100),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: ColorTokens.neutral100),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: ColorTokens.secondary50),
                          ),
                        ),
                        style: TextStyle(color: ColorTokens.neutral100),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Botón enviar o loading
                      if (auth.state == AuthState.loading)
                        CircularProgressIndicator(color: ColorTokens.secondary50)
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
                      
                      // Campos del código
                      if (auth.state == AuthState.codeSent) ...[
                        Text(
                          'Código enviado a: ${phoneController.text}',
                          style: TextStyle(color: ColorTokens.neutral100, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        
                        // Stack para combinar campos visuales + campo invisible de autocompletado
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // 📱 Campo INVISIBLE para autocompletado iOS
                            // ✅ textContentType: TextContentType.oneTimeCode
                            Opacity(
                              opacity: 0.01,
                              child: SizedBox(
                                width: 1,
                                height: 1,
                                child: TextField(
                                  controller: otpAutoFillController,
                                  keyboardType: TextInputType.number,
                                  autofillHints: [AutofillHints.oneTimeCode],
                                  textInputAction: TextInputAction.done,
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                  style: TextStyle(fontSize: 1),
                                ),
                              ),
                            ),
                            
                            // 👁️ Campos VISUALES para entrada manual
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
                                    style: TextStyle(
                                      color: ColorTokens.neutral100,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) {
                                      if (value.isNotEmpty && i < 5) {
                                        // Avanzar al siguiente campo
                                        FocusScope.of(context).requestFocus(focusNodes[i + 1]);
                                      } else if (value.isEmpty && i > 0) {
                                        // Retroceder al campo anterior
                                        FocusScope.of(context).requestFocus(focusNodes[i - 1]);
                                      } else if (value.isNotEmpty && i == 5) {
                                        // Último dígito, quitar focus
                                        FocusScope.of(context).unfocus();
                                      }
                                      
                                      // Actualizar el campo invisible también
                                      String fullCode = codeControllers.map((c) => c.text).join();
                                      if (fullCode.length == 6) {
                                        otpAutoFillController.text = fullCode;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: ColorTokens.neutral100),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: ColorTokens.neutral100),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: ColorTokens.secondary50, width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          onPressed: auth.state != AuthState.loading ? _handleValidateCode : null,
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
                        TextButton(
                          onPressed: _handleSendCode,
                          child: Text(
                            'Reenviar código (${auth.resendSeconds}s)',
                            style: TextStyle(color: ColorTokens.neutral100),
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
