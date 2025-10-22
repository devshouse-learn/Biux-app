import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:biux/core/config/strings.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/bikes/presentation/providers/bike_provider.dart';
import 'package:biux/features/bikes/domain/entities/bike_enums.dart';

/// Cuarto paso del registro: Generar QR y finalizar
class BikeRegistrationStep4 extends StatelessWidget {
  const BikeRegistrationStep4({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BikeProvider>(
      builder: (context, bikeProvider, child) {
        final registrationData = bikeProvider.registrationData;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),

              // Título de revisión
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorTokens.primary95,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorTokens.primary80),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.fact_check_outlined,
                      size: 48,
                      color: ColorTokens.primary30,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.step4Title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.primary30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.step4Description,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTokens.neutral30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Resumen de la bicicleta
              _buildBikeSummary(registrationData),

              const SizedBox(height: 24),

              // Nota informativa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Al presionar "Finalizar" se registrará tu bicicleta y recibirás tu código QR.',
                        style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBikeSummary(Map<String, dynamic> data) {
    final bikeType = data['type'] as BikeType?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.neutral90),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_bike,
                color: ColorTokens.primary30,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen de tu bicicleta',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.primary30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Foto principal si existe
          if (data['mainPhoto'] != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (data['mainPhoto'] as String).startsWith('http')
                    ? Image.network(
                        data['mainPhoto'],
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          );
                        },
                      )
                    : Image.file(
                        File(data['mainPhoto']),
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image),
                          );
                        },
                      ),
              ),
            ),

          if (data['mainPhoto'] != null) const SizedBox(height: 16),

          // Información básica
          _buildInfoRow('Marca:', data['brand'] ?? ''),
          _buildInfoRow('Modelo:', data['model'] ?? ''),
          _buildInfoRow('Año:', data['year']?.toString() ?? ''),
          _buildInfoRow('Color:', data['color'] ?? ''),
          _buildInfoRow('Talla:', data['size'] ?? ''),
          _buildInfoRow('Tipo:', bikeType?.displayName ?? ''),
          _buildInfoRow('Ciudad:', data['city'] ?? ''),

          if (data['neighborhood'] != null &&
              data['neighborhood'].toString().isNotEmpty)
            _buildInfoRow('Barrio:', data['neighborhood']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorTokens.neutral70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
