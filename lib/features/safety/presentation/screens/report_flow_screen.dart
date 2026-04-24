// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

/// Pantalla de reporte multi-paso con flujo completo.
/// Paso 0: Introducción ("¿Qué quieres reportar?")
/// Paso 1a: Selección de publicación → Paso 2a: Motivo de publicación
/// Paso 1b: Motivo sobre la cuenta → Enviar
class ReportFlowScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;

  const ReportFlowScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  @override
  State<ReportFlowScreen> createState() => _ReportFlowScreenState();
}

enum _ReportStep { intro, selectPost, postReason, accountReason, sending, done }

class _ReportFlowScreenState extends State<ReportFlowScreen> {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  _ReportStep _step = _ReportStep.intro;

  // Publicaciones del usuario
  List<Map<String, dynamic>> _posts = [];
  bool _loadingPosts = false;

  // Selección
  Map<String, dynamic>? _selectedPost;
  String? _selectedReason;
  String? _reportType; // 'post' o 'account'

  bool _sending = false;

  // ── Motivos para reportar una publicación ───────────────────────────
  static const List<String> _postReasons = [
    'Contenido sexual o de desnudos',
    'Violencia o amenazas',
    'Acoso o bullying',
    'Información falsa o engañosa',
    'Spam o estafa',
    'Discurso de odio o símbolos',
    'Venta de artículos ilegales o regulados',
    'Propiedad intelectual o derechos de autor',
    'Contenido perturbador o gráfico',
    'Otro motivo',
  ];

  // ── Motivos para reportar la cuenta ─────────────────────────────────
  static const List<String> _accountReasons = [
    'Se hace pasar por otra persona',
    'Cuenta que no le pertenece (hackeada)',
    'Cuenta falsa o engañosa',
    'Nombre de usuario inapropiado',
    'Spam o cuenta automatizada',
    'Posible menor de edad',
    'Promueve autolesiones o trastornos alimenticios',
    'Venta de productos ilegales',
    'Otro motivo',
  ];

  // ── Cargar publicaciones del usuario reportado ──────────────────────
  Future<void> _loadUserPosts() async {
    setState(() => _loadingPosts = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('experiences')
          .where('user.id', isEqualTo: widget.reportedUserId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final posts = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final media = data['media'] as List<dynamic>? ?? [];
        String? imageUrl;
        for (final m in media) {
          if (m is Map<String, dynamic>) {
            final url = m['url'] as String? ?? '';
            if (url.startsWith('http')) {
              imageUrl = url;
              break;
            }
          }
        }
        if (imageUrl != null) {
          posts.add({
            'id': doc.id,
            'imageUrl': imageUrl,
            'description': data['description'] ?? '',
          });
        }
      }
      if (mounted) setState(() => _posts = posts);
    } catch (_) {}
    if (mounted) setState(() => _loadingPosts = false);
  }

  // ── Enviar reporte ──────────────────────────────────────────────────
  Future<void> _submitReport() async {
    setState(() => _sending = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reporterId': uid,
        'reportedId': widget.reportedUserId,
        'type': _reportType,
        'postId': _selectedPost?['id'],
        'reason': _selectedReason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.reportedUserId)
          .update({'reportCount': FieldValue.increment(1)});
    } catch (_) {}

    if (mounted) {
      setState(() {
        _sending = false;
        _step = _ReportStep.done;
      });
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────

  void _onBack() {
    switch (_step) {
      case _ReportStep.intro:
        Navigator.of(context).pop();
        break;
      case _ReportStep.selectPost:
        setState(() {
          _step = _ReportStep.intro;
          _selectedPost = null;
        });
        break;
      case _ReportStep.postReason:
        setState(() {
          _step = _ReportStep.selectPost;
          _selectedReason = null;
        });
        break;
      case _ReportStep.accountReason:
        setState(() {
          _step = _ReportStep.intro;
          _selectedReason = null;
        });
        break;
      case _ReportStep.sending:
      case _ReportStep.done:
        Navigator.of(context).pop();
        break;
    }
  }

  Widget _buildStep(bool isDark) {
    switch (_step) {
      case _ReportStep.intro:
        return _buildIntro(isDark);
      case _ReportStep.selectPost:
        return _buildPostSelection(isDark);
      case _ReportStep.postReason:
        return _buildReasonList(_postReasons, 'post', isDark);
      case _ReportStep.accountReason:
        return _buildReasonList(_accountReasons, 'account', isDark);
      case _ReportStep.sending:
        return const Center(child: CircularProgressIndicator());
      case _ReportStep.done:
        return _buildDone(isDark);
    }
  }

  // ── Paso 0: Introducción ────────────────────────────────────────────
  Widget _buildIntro(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('intro'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué quieres reportar?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: isDark ? 0.15 : 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.withValues(alpha: isDark ? 0.3 : 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        color: isDark ? Colors.blue.shade300 : Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tu reporte es anónimo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'La persona a la que reportes no sabrá quién realizó '
                  'el reporte. Nuestro equipo revisará tu caso.',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: isDark ? 0.15 : 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: isDark ? 0.3 : 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.emergency_outlined,
                    color: isDark ? Colors.red.shade300 : Colors.red.shade700, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Si alguien se encuentra en peligro inmediato, '
                    'llama a los servicios de emergencia locales.',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildOptionCard(
            icon: Icons.photo_library_outlined,
            title: 'Una publicación concreta',
            subtitle: 'Selecciona una publicación de este usuario para reportar',
            isDark: isDark,
            onTap: () {
              _reportType = 'post';
              _loadUserPosts();
              setState(() => _step = _ReportStep.selectPost);
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            icon: Icons.person_off_outlined,
            title: 'Algo sobre esta cuenta',
            subtitle: 'Reporta la cuenta por suplantación, hackeo u otros motivos',
            isDark: isDark,
            onTap: () {
              _reportType = 'account';
              setState(() => _step = _ReportStep.accountReason);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark ? ColorTokens.primary20 : null,
          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? ColorTokens.primary30 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isDark ? Colors.white70 : ColorTokens.primary30, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : null)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ── Paso 1a: Selección de publicación ───────────────────────────────
  Widget _buildPostSelection(bool isDark) {
    return Column(
      key: const ValueKey('selectPost'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Text(
            'Selecciona la publicación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Toca la publicación que quieres reportar',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          ),
        ),
        const SizedBox(height: 16),
        if (_loadingPosts)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_posts.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Este usuario no tiene publicaciones',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _posts.length,
              itemBuilder: (ctx, i) {
                final post = _posts[i];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPost = post;
                      _step = _ReportStep.postReason;
                    });
                  },
                  child: CachedNetworkImage(
                    imageUrl: post['imageUrl'] as String,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ── Paso 2: Lista de motivos ────────────────────────────────────────
  Widget _buildReasonList(List<String> reasons, String type, bool isDark) {
    return SingleChildScrollView(
      key: ValueKey('reasons_$type'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type == 'post'
                ? '¿Por qué reportas esta publicación?'
                : '¿Por qué reportas esta cuenta?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null),
          ),
          const SizedBox(height: 6),
          Text(
            'Selecciona el motivo que mejor se ajuste',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          ),
          if (_selectedPost != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 64,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark ? ColorTokens.primary20 : Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: _selectedPost!['imageUrl'] as String,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      (_selectedPost!['description'] as String).isNotEmpty
                          ? _selectedPost!['description'] as String
                          : 'Publicación seleccionada',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...reasons.map((reason) => _buildReasonTile(reason, isDark)),
        ],
      ),
    );
  }

  Widget _buildReasonTile(String reason, bool isDark) {
    final selected = _selectedReason == reason;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedReason = reason),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? (isDark ? Colors.blue.shade300 : ColorTokens.primary30)
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: selected ? 2 : 1,
            ),
            color: selected
                ? (isDark ? Colors.blue.withValues(alpha: 0.15) : ColorTokens.primary30.withValues(alpha: 0.06))
                : (isDark ? ColorTokens.primary20 : null),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  reason,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: isDark ? Colors.white : null,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle,
                    color: isDark ? Colors.blue.shade300 : ColorTokens.primary30, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Paso final: Botón de reportar (se muestra abajo) ────────────────
  // Se muestra solo cuando hay un motivo seleccionado
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showSubmit = _selectedReason != null &&
        (_step == _ReportStep.postReason || _step == _ReportStep.accountReason);

    return Scaffold(
      backgroundColor: isDark ? ColorTokens.primary10 : Colors.white,
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: Text(l.t('report_action')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBack,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildStep(isDark),
      ),
      bottomNavigationBar: showSubmit
          ? SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(l.t('report_action'),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ── Paso completado ────────────────────────────────────────────────
  Widget _buildDone(bool isDark) {
    return Center(
      key: const ValueKey('done'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.green, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Reporte enviado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null),
            ),
            const SizedBox(height: 8),
            Text(
              'Gracias por ayudar a mantener BIUX seguro.\n'
              'Nuestro equipo revisará tu reporte.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.white54 : ColorTokens.primary30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Listo',
                    style: TextStyle(
                        color: isDark ? Colors.white : ColorTokens.primary30,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
