import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/presentation/widgets/bike_registration_step1.dart';
import 'package:biux/features/bikes/presentation/widgets/bike_registration_step2.dart';
import 'package:biux/features/bikes/presentation/widgets/bike_registration_step3.dart';
import 'package:biux/features/bikes/presentation/widgets/bike_registration_step4.dart';

/// Pantalla de registro de bicicleta en 4 pasos
class BikeRegistrationScreen extends StatefulWidget {
  const BikeRegistrationScreen({super.key});

  @override
  State<BikeRegistrationScreen> createState() => _BikeRegistrationScreenState();
}

class _BikeRegistrationScreenState extends State<BikeRegistrationScreen> {
  @override
  void initState() {
    super.initState();
    // Reiniciar el formulario al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BikeProvider>().resetRegistrationForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        final bikeProvider = context.read<BikeProvider>();
        if (bikeProvider.currentStep > 0) {
          bikeProvider.previousStep();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            l.t('register_bike'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: ColorTokens.primary30,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              final bikeProvider = context.read<BikeProvider>();
              if (bikeProvider.currentStep > 0) {
                bikeProvider.previousStep();
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Consumer<BikeProvider>(
          builder: (context, bikeProvider, child) {
            return Column(
              children: [
                _buildProgressIndicator(bikeProvider.currentStep),
                Expanded(child: _buildCurrentStep(bikeProvider.currentStep)),
                _buildNavigationButtons(bikeProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Indicador de progreso visual
          Row(
            children: List.generate(4, (index) {
              final isActive = index <= currentStep;
              final isCompleted = index < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? ColorTokens.primary30
                            : ColorTokens.neutral90,
                        border: Border.all(
                          color: isActive
                              ? ColorTokens.primary30
                              : ColorTokens.neutral70,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : ColorTokens.neutral70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < currentStep
                              ? ColorTokens.primary30
                              : ColorTokens.neutral90,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Título del paso actual
          Text(
            _getStepTitle(currentStep),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorTokens.primary30,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    switch (step) {
      case 0:
        return l.t('step1_title');
      case 1:
        return l.t('step2_title');
      case 2:
        return l.t('step3_title');
      case 3:
        return l.t('step4_title');
      default:
        return '';
    }
  }

  Widget _buildCurrentStep(int currentStep) {
    switch (currentStep) {
      case 0:
        return const BikeRegistrationStep1();
      case 1:
        return const BikeRegistrationStep2();
      case 2:
        return const BikeRegistrationStep3();
      case 3:
        return const BikeRegistrationStep4();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons(BikeProvider bikeProvider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón Cancelar
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(bikeProvider),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorTokens.error50,
                side: const BorderSide(color: ColorTokens.error50),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                l.t('cancel'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Botón Siguiente/Finalizar
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: bikeProvider.isLoading
                  ? null
                  : () => _handleNextStep(bikeProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                disabledBackgroundColor: ColorTokens.neutral70,
              ),
              child: bikeProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _getNextButtonText(bikeProvider.currentStep),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextButtonText(int currentStep) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    switch (currentStep) {
      case 3:
        return l.t('finish');
      default:
        return l.t('next');
    }
  }

  void _showCancelDialog(BikeProvider bikeProvider) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.t('cancel_registration')),
        content: Text(l.t('cancel_registration_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: ColorTokens.neutral60),
            child: Text(
              l.t('continue_editing'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              bikeProvider.resetRegistrationForm();
              this.context.pop(); // Volver a Mis Bicis
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l.t('cancel_registration'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNextStep(BikeProvider bikeProvider) async {
    // Validar el paso actual con mensaje específico
    final validationError = bikeProvider.validateCurrentStepWithMessage();

    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    if (bikeProvider.currentStep < 3) {
      // Avanzar al siguiente paso
      bikeProvider.nextStep();
    } else {
      // Paso final: registrar la bicicleta
      await _registerBike(bikeProvider);
    }
  }

  void _showValidationError([String? message]) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? l.t('complete_required_fields')),
        backgroundColor: ColorTokens.error50,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _registerBike(BikeProvider bikeProvider) async {
    // Obtener el userId del usuario autenticado
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      final l = Provider.of<LocaleNotifier>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('must_login_register')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    final bike = await bikeProvider.registerBike(userId);

    if (!mounted) return;

    if (bike != null) {
      final l = Provider.of<LocaleNotifier>(context, listen: false);
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('bike_registered_success')),
          backgroundColor: ColorTokens.success40,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reiniciar formulario y navegar después del frame actual
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          bikeProvider.resetRegistrationForm();
          context.go('/bikes/${bike.id}');
        }
      });
    } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bikeProvider.errorMessage ??
                Provider.of<LocaleNotifier>(
                  context,
                  listen: false,
                ).t('error_registering_bike'),
          ),
          backgroundColor: ColorTokens.error50,
        ),
      );
    }
  }
}
