import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/services/biometric_service.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});
  @override
  State<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  bool _isAvailable = false;
  bool _isEnabled = false;
  List<BiometricType> _biometrics = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isEnabled();
    final biometrics = await BiometricService.getAvailableBiometrics();
    setState(() {
      _isAvailable = available; _isEnabled = enabled;
      _biometrics = biometrics; _loading = false;
    });
  }

  Future<void> _toggle(bool value) async {
    if (value) {
      final auth = await BiometricService.authenticate();
      if (!auth) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Autenticacion fallida')));
        return;
      }
    }
    await BiometricService.setEnabled(value);
    setState(() => _isEnabled = value);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value ? 'Biometria activada' : 'Biometria desactivada'),
      backgroundColor: value ? Colors.green : Colors.grey,
    ));
  }

  String get _biometricLabel {
    if (_biometrics.contains(BiometricType.face)) return 'Face ID';
    if (_biometrics.contains(BiometricType.fingerprint)) return 'Huella digital';
    return 'Biometria';
  }

  IconData get _biometricIcon {
    if (_biometrics.contains(BiometricType.face)) return Icons.face_unlock_rounded;
    if (_biometrics.contains(BiometricType.fingerprint)) return Icons.fingerprint_rounded;
    return Icons.security_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad biometrica'),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ColorTokens.primary30, ColorTokens.primary30.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(children: [
                    Icon(_biometricIcon, size: 64, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(_biometricLabel, style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      _isAvailable ? 'Disponible en tu dispositivo' : 'No disponible',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                if (!_isAvailable)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(child: Text(
                        'Tu dispositivo no soporta autenticacion biometrica.',
                        style: TextStyle(fontSize: 13),
                      )),
                    ]),
                  )
                else ...[
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: SwitchListTile(
                      value: _isEnabled, onChanged: _toggle,
                      title: Text('Activar \$_biometricLabel'),
                      subtitle: const Text('Solicitar autenticacion al abrir Biux'),
                      secondary: Icon(_biometricIcon, color: ColorTokens.primary30),
                      activeThumbColor: ColorTokens.primary30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Como funciona?', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _infoRow(Icons.lock_outline_rounded, 'Cuenta protegida con biometria'),
                      _infoRow(Icons.no_photography_outlined, 'Nadie mas puede acceder sin tu biometria'),
                      _infoRow(Icons.speed_rounded, 'Acceso rapido sin contrasena'),
                    ]),
                  ),
                ],
              ]),
            ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(children: [
      Icon(icon, size: 18, color: ColorTokens.primary30),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
    ]),
  );
}
