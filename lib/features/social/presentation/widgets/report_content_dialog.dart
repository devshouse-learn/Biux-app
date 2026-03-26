import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/social/data/datasources/report_datasource.dart';

/// Diálogo para reportar contenido (posts, comentarios, usuarios, rodadas)
class ReportContentDialog {
  static const _reasons = [
    'Contenido inapropiado',
    'Spam o publicidad',
    'Acoso o bullying',
    'Información falsa',
    'Contenido violento',
    'Suplantación de identidad',
    'Otro',
  ];

  /// Mostrar diálogo de reporte
  static void show({
    required BuildContext context,
    required String contentId,
    required String contentOwnerId,
    required String contentType, // 'post', 'comment', 'user', 'ride'
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    String? selectedReason;
    final detailsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ColorTokens.primary40
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Título
              Row(
                children: [
                  Icon(Icons.flag_outlined, color: ColorTokens.error50),
                  SizedBox(width: 8),
                  Text(
                    'Reportar contenido',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '¿Por qué deseas reportar este contenido?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: 16),

              // Razones
              RadioGroup<String>(
                groupValue: selectedReason ?? '',
                onChanged: (val) => setState(() => selectedReason = val),
                child: Column(
                  children: _reasons.map((reason) {
                    return RadioListTile<String>(
                      value: reason,
                      title: Text(reason, style: TextStyle(fontSize: 14)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: ColorTokens.primary30,
                    );
                  }).toList(),
                ),
              ),

              // Detalles opcionales
              if (selectedReason != null) ...[
                SizedBox(height: 8),
                TextField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    hintText: 'Detalles adicionales (opcional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  maxLines: 3,
                  maxLength: 300,
                ),
              ],
              SizedBox(height: 16),

              // Botón enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () async {
                          try {
                            await ReportDatasource().reportContent(
                              reporterId: uid,
                              reportedUserId: contentOwnerId,
                              contentId: contentId,
                              type: contentType,
                              reason: selectedReason!,
                              details: detailsController.text.trim().isNotEmpty
                                  ? detailsController.text.trim()
                                  : null,
                            );
                            Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reporte enviado. Revisaremos el contenido.',
                                  ),
                                  backgroundColor: ColorTokens.success40,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error enviando reporte'),
                                  backgroundColor: ColorTokens.error50,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.error50,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Enviar Reporte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
