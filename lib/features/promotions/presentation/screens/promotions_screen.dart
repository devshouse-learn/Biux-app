import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import '../../data/models/promotion_request_model.dart';
import '../providers/promotions_provider.dart';
import 'package:intl/intl.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({Key? key}) : super(key: key);

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Negocios y Eventos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorTokens.primary30,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'Negocios'),
            Tab(icon: Icon(Icons.event), text: 'Eventos'),
          ],
        ),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final isAdmin = userProvider.user?.isAdmin ?? false;
              if (!isAdmin) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                tooltip: 'Panel Admin',
                onPressed: () => _showAdminPanel(context),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BusinessTab(),
          _EventsTab(),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final provider = context.read<PromotionsProvider>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isPromoter = provider.isVerifiedPromoter(uid);

    return FloatingActionButton.extended(
      onPressed: () {
        if (isPromoter) {
          _showCreateDialog(context);
        } else {
          _showPromoterRequestDialog(context);
        }
      },
      backgroundColor: ColorTokens.primary30,
      icon: Icon(isPromoter ? Icons.add : Icons.verified_user, color: Colors.white),
      label: Text(
        isPromoter ? 'Publicar' : 'Ser Promotor',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showPromoterRequestDialog(BuildContext context) {
    final businessNameCtrl = TextEditingController();
    final businessDescCtrl = TextEditingController();
    final userProvider = context.read<UserProvider>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = userProvider.user?.name ?? 'Usuario';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.verified_user, color: ColorTokens.primary30),
            const SizedBox(width: 8),
            const Expanded(child: Text('Solicitar ser Promotor')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Solo usuarios verificados como promotores pueden publicar anuncios de negocios y crear eventos.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: businessNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre del negocio',
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: businessDescCtrl,
                decoration: InputDecoration(
                  labelText: 'Describe tu negocio',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final bName = businessNameCtrl.text.trim();
              final bDesc = businessDescCtrl.text.trim();
              if (bName.isEmpty || bDesc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos')),
                );
                return;
              }
              final provider = context.read<PromotionsProvider>();
              final ok = await provider.requestPromoterStatus(uid, name, bName, bDesc);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Solicitud enviada. Un administrador la revisara.'
                      : 'Error al enviar solicitud'),
                  backgroundColor: ok ? ColorTokens.success40 : ColorTokens.error50,
                ),
              );
            },
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('Enviar solicitud', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: ColorTokens.primary30),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final maxAttendeesCtrl = TextEditingController();
    String type = 'negocio';
    DateTime? eventDate;
    TimeOfDay? eventTime;
    final userProvider = context.read<UserProvider>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = userProvider.user?.name ?? 'Usuario';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                type == 'negocio' ? Icons.storefront : Icons.event,
                color: ColorTokens.primary30,
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Nueva publicacion')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tipo selector
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'negocio', label: Text('Negocio'), icon: Icon(Icons.storefront)),
                    ButtonSegment(value: 'evento', label: Text('Evento'), icon: Icon(Icons.event)),
                  ],
                  selected: {type},
                  onSelectionChanged: (v) => setDialogState(() => type = v.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Titulo',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Descripcion',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactCtrl,
                  decoration: InputDecoration(
                    labelText: 'Contacto (telefono/email)',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  decoration: InputDecoration(
                    labelText: 'Ubicacion',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (type == 'evento') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: maxAttendeesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cupos maximos (opcional)',
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (d != null) setDialogState(() => eventDate = d);
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            eventDate != null
                                ? DateFormat('dd/MM/yyyy').format(eventDate!)
                                : 'Fecha',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (t != null) setDialogState(() => eventTime = t);
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            eventTime != null
                                ? eventTime!.format(ctx)
                                : 'Hora',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final desc = descCtrl.text.trim();
                if (title.isEmpty || desc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Titulo y descripcion son obligatorios')),
                  );
                  return;
                }

                int? maxAtt;
                if (maxAttendeesCtrl.text.trim().isNotEmpty) {
                  maxAtt = int.tryParse(maxAttendeesCtrl.text.trim());
                }

                final req = PromotionRequestModel(
                  title: title,
                  description: desc,
                  type: type,
                  contact: contactCtrl.text.trim().isNotEmpty ? contactCtrl.text.trim() : null,
                  location: locationCtrl.text.trim().isNotEmpty ? locationCtrl.text.trim() : null,
                  eventDate: eventDate,
                  eventTime: eventTime != null ? eventTime!.format(ctx) : null,
                  maxAttendees: maxAtt,
                  ownerUid: uid,
                  ownerName: name,
                );
                context.read<PromotionsProvider>().addRequest(req);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Publicacion creada exitosamente'),
                    backgroundColor: ColorTokens.success40,
                  ),
                );
              },
              icon: const Icon(Icons.publish, color: Colors.white),
              label: const Text('Publicar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: ColorTokens.primary30),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => _AdminPanelContent(scrollController: scrollController),
      ),
    );
  }
}

// =====================================================
// TAB: Negocios
// =====================================================
class _BusinessTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionsProvider>(
      builder: (context, provider, _) {
        final businesses = provider.approvedBusinesses;

        if (businesses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No hay negocios publicados',
                  style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los promotores verificados pueden\npublicar sus negocios aqui',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: businesses.length,
            itemBuilder: (context, index) => _BusinessCard(business: businesses[index]),
          ),
        );
      },
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final PromotionRequestModel business;
  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con gradiente
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorTokens.primary30, ColorTokens.primary30.withValues(alpha: 0.8)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.title,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            business.ownerName,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business.description, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[700])),
                const SizedBox(height: 12),
                if (business.location != null && business.location!.isNotEmpty)
                  _infoRow(Icons.location_on, business.location!, Colors.red),
                if (business.contact != null && business.contact!.isNotEmpty)
                  _infoRow(Icons.phone, business.contact!, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// =====================================================
// TAB: Eventos
// =====================================================
class _EventsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionsProvider>(
      builder: (context, provider, _) {
        final events = provider.approvedEvents;

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No hay eventos programados',
                  style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los promotores verificados pueden\ncrear eventos con registro de asistencia',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) => _EventCard(event: events[index]),
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final PromotionRequestModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isRegistered = event.attendees.contains(uid);
    final isFull = event.isFull;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con fecha
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                if (event.eventDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd').format(event.eventDate!),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM', 'es').format(event.eventDate!).toUpperCase(),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(event.ownerName, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[700])),
                const SizedBox(height: 12),
                if (event.eventTime != null)
                  _infoRow(Icons.access_time, event.eventTime!, Colors.blue),
                if (event.location != null && event.location!.isNotEmpty)
                  _infoRow(Icons.location_on, event.location!, Colors.red),
                if (event.contact != null && event.contact!.isNotEmpty)
                  _infoRow(Icons.phone, event.contact!, Colors.green),
                const SizedBox(height: 8),
                // Asistentes
                Row(
                  children: [
                    Icon(Icons.people, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      '${event.attendees.length} registrados',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    if (event.maxAttendees != null) ...[
                      Text(
                        ' / ${event.maxAttendees} cupos',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                    const Spacer(),
                    if (isFull && !isRegistered)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('LLENO', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                if (event.maxAttendees != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: event.attendees.length / event.maxAttendees!,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFull ? Colors.red : ColorTokens.success40,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                const SizedBox(height: 16),
                // Boton de registro
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (isFull && !isRegistered)
                        ? null
                        : () async {
                            final provider = context.read<PromotionsProvider>();
                            bool ok;
                            if (isRegistered) {
                              ok = await provider.unregisterFromEvent(event.id, uid);
                            } else {
                              ok = await provider.registerToEvent(event.id, uid);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isRegistered
                                        ? (ok ? 'Registro cancelado' : 'Error al cancelar')
                                        : (ok ? 'Registrado exitosamente!' : 'Error al registrar'),
                                  ),
                                  backgroundColor: ok ? ColorTokens.success40 : ColorTokens.error50,
                                ),
                              );
                            }
                          },
                    icon: Icon(
                      isRegistered ? Icons.cancel : Icons.how_to_reg,
                      color: Colors.white,
                    ),
                    label: Text(
                      isRegistered ? 'Cancelar registro' : 'Registrarse al evento',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered ? ColorTokens.error50 : const Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// =====================================================
// Admin Panel
// =====================================================
class _AdminPanelContent extends StatelessWidget {
  final ScrollController scrollController;
  const _AdminPanelContent({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionsProvider>(
      builder: (context, provider, _) {
        final pending = provider.pendingRequests;

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: ColorTokens.primary30),
                  const SizedBox(width: 8),
                  const Text(
                    'Panel de Administracion',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pending.isEmpty ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pending.length} pendientes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: pending.isEmpty ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: pending.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
                          const SizedBox(height: 12),
                          Text('No hay solicitudes pendientes', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pending.length,
                      itemBuilder: (context, index) {
                        final req = pending[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      req.type == 'evento' ? Icons.event : Icons.storefront,
                                      color: ColorTokens.primary30,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(req.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(req.type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(req.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Por: ${req.ownerName}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        await provider.reject(req.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Solicitud rechazada'), backgroundColor: ColorTokens.error50),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('Rechazar'),
                                      style: OutlinedButton.styleFrom(foregroundColor: ColorTokens.error50, side: const BorderSide(color: ColorTokens.error50)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        await provider.approve(req.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Solicitud aprobada'), backgroundColor: ColorTokens.success40),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.check, size: 18, color: Colors.white),
                                      label: const Text('Aprobar', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(backgroundColor: ColorTokens.success40),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
