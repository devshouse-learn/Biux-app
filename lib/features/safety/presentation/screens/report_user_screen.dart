// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/safety/domain/entities/block_report_entity.dart';
import 'package:biux/features/safety/presentation/providers/safety_provider.dart';

class ReportUserScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;
  const ReportUserScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  @override
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  ReportReason? _selectedReason;
  final _descController = TextEditingController();
  bool _loading = false;
  bool _alsoBlock = true;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final provider = context.read<SafetyProvider>();
    final ok = await provider.reportUser(
      reporterId: uid,
      reportedId: widget.reportedUserId,
      reason: _selectedReason!,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
    );
    if (_alsoBlock && ok) await provider.blockUser(uid, widget.reportedUserId);
    setState(() => _loading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Reporte enviado. Gracias por hacer Biux mas seguro'
                : 'Error al enviar el reporte',
          ),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar usuario'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reportando a \${widget.reportedUserName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Por que reportas este usuario?',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...ReportReason.values.map(
              (r) => InkWell(
                onTap: () => setState(() => _selectedReason = r),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Radio<ReportReason>(
                        value: r,
                        groupValue: _selectedReason,
                        onChanged: (v) => setState(() => _selectedReason = v),
                        activeColor: ColorTokens.primary30,
                      ),
                      Expanded(child: Text(r.label)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Descripcion adicional (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _alsoBlock,
              onChanged: (v) => setState(() => _alsoBlock = v ?? true),
              title: const Text('Tambien bloquear a este usuario'),
              activeColor: ColorTokens.primary30,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedReason == null || _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Enviar reporte',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
