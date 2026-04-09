import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:biux/core/design_system/color_tokens.dart';

class IdentityVerificationScreen extends StatefulWidget {
  final String userId;
  const IdentityVerificationScreen({super.key, required this.userId});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  File? _docFront;
  File? _docBack;
  bool _uploading = false;
  bool _uploaded = false;
  String _selectedDocType = 'INE / Credencial de elector';

  final List<String> _docTypes = [
    'INE / Credencial de elector',
    'Pasaporte',
    'Cédula profesional',
    'Licencia de conducir',
  ];

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 80, maxWidth: 1200);
    if (picked != null) {
      setState(() {
        if (isFront) _docFront = File(picked.path);
        else _docBack = File(picked.path);
      });
    }
  }

  Future<void> _uploadDocuments() async {
    if (_docFront == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega la parte frontal del documento')));
      return;
    }
    setState(() => _uploading = true);
    try {
      final ref = FirebaseStorage.instance.ref('identity_docs/${widget.userId}');
      final frontRef = ref.child('front.jpg');
      await frontRef.putFile(_docFront!);
      final frontUrl = await frontRef.getDownloadURL();
      String? backUrl;
      if (_docBack != null) {
        final backRef = ref.child('back.jpg');
        await backRef.putFile(_docBack!);
        backUrl = await backRef.getDownloadURL();
      }
      await FirebaseFirestore.instance
          .collection('age_verifications')
          .doc(widget.userId)
          .set({
        'userId': widget.userId,
        'ageGroup': 'adult',
        'docType': _selectedDocType,
        'docFrontUrl': frontUrl,
        'docBackUrl': backUrl,
        'verificationStatus': 'pending_review',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'ageVerification': 'pending_review',
        'isMinor': false,
        'docType': _selectedDocType,
      });
      setState(() { _uploading = false; _uploaded = true; });
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: const Text('Verificación de identidad',
          style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _uploaded ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: ColorTokens.primary30.withValues(alpha: 0.1),
              shape: BoxShape.circle),
            child: Icon(Icons.verified_user_rounded, size: 40, color: ColorTokens.primary30),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text('Verifica tu identidad',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Para mayor seguridad en la comunidad Biux,\n'
            'necesitamos verificar tu identidad.',
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.security_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tus documentos están protegidos con cifrado y solo serán '
                  'usados para verificar tu identidad. No serán compartidos con terceros.',
                  style: TextStyle(fontSize: 12, color: Colors.blue[800], height: 1.5))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Tipo de documento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12)),
          child: DropdownButton<String>(
            value: _selectedDocType,
            isExpanded: true,
            underline: const SizedBox(),
            items: _docTypes.map((t) => DropdownMenuItem(
              value: t, child: Text(t, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _selectedDocType = v!),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Parte frontal del documento *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _docTile(isFront: true, file: _docFront,
          label: 'Toca para agregar la parte frontal', icon: Icons.credit_card_rounded),
        const SizedBox(height: 16),
        const Text('Parte trasera (opcional)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _docTile(isFront: false, file: _docBack,
          label: 'Toca para agregar la parte trasera', icon: Icons.flip_rounded),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton.icon(
            onPressed: _uploading ? null : _uploadDocuments,
            icon: _uploading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.upload_rounded),
            label: Text(_uploading ? 'Subiendo...' : 'Enviar para verificación',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary30,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 48,
          child: TextButton(
            onPressed: () => context.go('/stories'),
            child: const Text('Verificar más tarde (acceso limitado)',
              style: TextStyle(color: Colors.grey, fontSize: 13))),
        ),
      ],
    );
  }

  Widget _docTile({required bool isFront, required File? file,
      required String label, required IconData icon}) {
    if (file == null) {
      return GestureDetector(
        onTap: () => _pickImage(isFront),
        child: Container(
          width: double.infinity, height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[300]!)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(file, width: double.infinity, height: 160, fit: BoxFit.cover)),
        Positioned(
          top: 8, right: 8,
          child: GestureDetector(
            onTap: () => setState(() { if (isFront) _docFront = null; else _docBack = null; }),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16)))),
        Positioned(
          bottom: 8, right: 8,
          child: GestureDetector(
            onTap: () => _pickImage(isFront),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('Cambiar', style: TextStyle(color: Colors.white, fontSize: 11)),
              ])))),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.verified_rounded, size: 48, color: Colors.green)),
        const SizedBox(height: 24),
        const Text('¡Documentos enviados!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14)),
          child: const Text(
            'Revisaremos tus documentos en 24-48 horas. '
            'Mientras tanto puedes usar Biux con acceso básico.',
            style: TextStyle(fontSize: 14, height: 1.6), textAlign: TextAlign.center)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/stories'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.primary30,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Entrar a Biux',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)))),
      ],
    );
  }
}
