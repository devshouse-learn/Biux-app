
import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/social/data/datasources/report_datasource.dart';

class ReportDialog extends StatefulWidget {
  final String reporterId;
  final String reportedUserId;
  final String contentId;
  final String contentType;

  const ReportDialog({
    Key? key,
    required this.reporterId,
    required this.reportedUserId,
    required this.contentId,
    required this.contentType,
  }) : super(key: key);

  static Future<void> show(BuildContext context, {
    required String reporterId,
    required String reportedUserId,
    required String contentId,
    required String contentType,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ReportDialog(
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        contentId: contentId,
        contentType: contentType,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final _detailsCtrl = TextEditingController();
  bool _submitting = false;

  final _reasons = [
    'Contenido inapropiado',
    'Spam o publicidad',
    'Acoso o bullying',
    'Información falsa',
    'Suplantación de identidad',
    'Contenido violento',
    'Venta de productos ilegales',
    'Otro',
  ];

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    setState(() => _submitting = true);

    try {
      await ReportDatasource().reportContent(
        reporterId: widget.reporterId,
        reportedUserId: widget.reportedUserId,
        contentId: widget.contentId,
        type: widget.contentType,
        reason: _selectedReason!,
        details: _detailsCtrl.text.trim().isNotEmpty ? _detailsCtrl.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte enviado. Revisaremos tu caso.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.flag_rounded, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Reportar contenido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('¿Por qué quieres reportar esto?', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _selectedReason ?? '',
            onChanged: (v) => setState(() => _selectedReason = v),
            child: Column(
              children: _reasons.map((reason) => InkWell(
                onTap: () => setState(() => _selectedReason = reason),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: reason,
                        activeColor: ColorTokens.primary30,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Expanded(child: Text(reason, style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _detailsCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Detalles adicionales (opcional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedReason != null && !_submitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar reporte', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
