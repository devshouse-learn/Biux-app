// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:biux/features/safety/data/datasources/two_factor_service.dart';
import 'package:biux/core/design_system/color_tokens.dart';

enum _TwoFactorMethod { email, sms }

class TwoFactorScreen extends StatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  _TwoFactorMethod _method = _TwoFactorMethod.sms;
  bool _enabled = false;
  bool _loading = false;
  bool _codeSent = false;
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocuses = List.generate(6, (_) => FocusNode());
  final _emailController = TextEditingController();

  @override
  void dispose() {
    for (final c in _codeControllers) c.dispose();
    for (final f in _codeFocuses) f.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() => _loading = true);
    try {
      await TwoFactorService.sendCode(
        method: _method.name,
        contact: _method == _TwoFactorMethod.email
            ? _emailController.text.trim()
            : null,
      );
      setState(() => _codeSent = true);
    } catch (e) {
      _showSnack('Error al enviar el código: \$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showSnack('Introduce los 6 dígitos');
      return;
    }
    setState(() => _loading = true);
    try {
      final ok = await TwoFactorService.verifyCode(code);
      if (ok) {
        setState(() => _enabled = true);
        _showSnack('2FA activado correctamente');
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack('Código incorrecto');
      }
    } catch (e) {
      _showSnack('Error al verificar: \$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1B2A) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Verificación en dos pasos'),
        backgroundColor: const Color(0xFF16242D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(h * 0.025),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(isDark: isDark),
            const SizedBox(height: 24),
            const Text('Método de verificación',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MethodTile(
                    icon: Icons.sms_rounded,
                    label: 'SMS',
                    selected: _method == _TwoFactorMethod.sms,
                    onTap: () =>
                        setState(() => _method = _TwoFactorMethod.sms),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MethodTile(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    selected: _method == _TwoFactorMethod.email,
                    onTap: () =>
                        setState(() => _method = _TwoFactorMethod.email),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            if (_method == _TwoFactorMethod.email) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!_codeSent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Text('Enviar código',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              )
            else ...[
              const Text('Ingresa el código de verificación',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (i) => SizedBox(
                    width: 44,
                    child: TextField(
                      controller: _codeControllers[i],
                      focusNode: _codeFocuses[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) {
                        if (v.length == 1 && i < 5) {
                          _codeFocuses[i + 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Verificar y activar',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              TextButton(
                onPressed: _loading ? null : _sendCode,
                child: const Text('Reenviar código'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  const _InfoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E8BC3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF1E8BC3).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded,
              color: Color(0xFF1E8BC3), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Protege tu cuenta',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                SizedBox(height: 4),
                Text(
                  'La verificación en dos pasos añade una capa extra de seguridad a tu cuenta.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _MethodTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
              color: selected
                  ? ColorTokens.primary30
                  : Colors.grey.shade300,
              width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? ColorTokens.primary30.withValues(alpha: 0.05)
              : (isDark ? const Color(0xFF1A2B3C) : Colors.white),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? ColorTokens.primary30 : Colors.grey),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? ColorTokens.primary30
                        : Colors.black87)),
          ],
        ),
      ),
    );
  }
}
