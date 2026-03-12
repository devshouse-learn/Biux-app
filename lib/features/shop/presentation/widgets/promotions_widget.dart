import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

/// Modelo de promoción
class Promotion {
  final String id;
  final String title;
  final String description;
  final String type;
  final String location;
  final String contact;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final String userId;
  final String userName;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.location = '',
    this.contact = '',
    this.expiresAt,
    required this.createdAt,
    required this.userId,
    required this.userName,
  });

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'descuento',
      location: data['location'] ?? '',
      contact: data['contact'] ?? '',
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Ciclista',
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'type': type,
    'location': location,
    'contact': contact,
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
    'userId': userId,
    'userName': userName,
  };

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  String get typeEmoji {
    switch (type) {
      case 'descuento':
        return '🏷️';
      case 'oferta':
        return '🎁';
      case 'evento':
        return '🚴';
      case 'novedad':
        return '✨';
      default:
        return '📢';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'descuento':
        return 'promo_type_discount';
      case 'oferta':
        return 'promo_type_offer';
      case 'evento':
        return 'promo_type_event';
      case 'novedad':
        return 'promo_type_new';
      default:
        return 'promo_type_promo';
    }
  }
}

/// Widget principal de promociones — completamente funcional
class PromotionsWidget extends StatefulWidget {
  const PromotionsWidget({super.key});

  @override
  State<PromotionsWidget> createState() => _PromotionsWidgetState();
}

class _PromotionsWidgetState extends State<PromotionsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _translatePromoType(LocaleNotifier l, String type) {
    return l.t('promo_type_$type');
  }

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'descuento';
  DateTime? _selectedDate;
  bool _isPublishing = false;

  // Firestore
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference get _promotionsRef =>
      _firestore.collection('shop_promotions');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Column(
      children: [
        const SizedBox(height: 8),
        // Tabs: Activas / Crear
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFF16242D),
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF16242D),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: '📋 ${l.t('promo_tab_active')}'),
              Tab(text: '➕ ${l.t('promo_tab_create')}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildPromotionsList(), _buildCreateForm()],
          ),
        ),
      ],
    );
  }

  /// ===== TAB 1: Lista de promociones activas =====
  Widget _buildPromotionsList() {
    final l = Provider.of<LocaleNotifier>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _promotionsRef
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF16242D)),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            title: l.t('promo_error_loading'),
            subtitle: l.t('promo_error_loading_desc'),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final promotions = docs
            .map((doc) => Promotion.fromFirestore(doc))
            .toList();

        // Filtrar expiradas
        final active = promotions.where((p) => !p.isExpired).toList();
        final expired = promotions.where((p) => p.isExpired).toList();

        if (active.isEmpty && expired.isEmpty) {
          return _buildEmptyState(
            icon: Icons.campaign_outlined,
            title: l.t('promo_no_promotions'),
            subtitle: l.t('promo_no_promotions_desc'),
            showButton: true,
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          children: [
            if (active.isNotEmpty) ...[
              _buildSectionHeader(
                '🔥 ${l.t('promo_active_count')} (${active.length})',
                color: const Color(0xFF16242D),
              ),
              const SizedBox(height: 12),
              ...active.map((p) => _buildPromotionCard(p)),
            ],
            if (expired.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader(
                '⏰ ${l.t('promo_expired_count')} (${expired.length})',
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              ...expired.map((p) => _buildPromotionCard(p, isExpired: true)),
            ],
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color ?? const Color(0xFF16242D),
        ),
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promo, {bool isExpired = false}) {
    final l = Provider.of<LocaleNotifier>(context);
    final currentUserId = _auth.currentUser?.uid;
    final isOwner = promo.userId == currentUserId;
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return Opacity(
      opacity: isExpired ? 0.55 : 1.0,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isExpired
                ? Colors.grey.withValues(alpha: 0.2)
                : const Color(0xFF16242D).withValues(alpha: 0.1),
          ),
        ),
        color: isExpired ? Colors.grey[50] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: tipo + título + menú
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji tipo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      promo.typeEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Título y tipo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16242D),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF16242D,
                                ).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _translatePromoType(l, promo.type),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5A7A8A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${l.t('promo_by')} ${promo.userName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5A7A8A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Menú de opciones (solo dueño)
                  if (isOwner && !isExpired)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(promo);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l.t('promo_delete'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Descripción
              Text(
                promo.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3A5A6A),
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),

              // Ubicación
              if (promo.location.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        promo.location,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Contacto
              if (promo.contact.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.link, size: 15, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        promo.contact,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              // Footer: fechas
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(promo.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  if (promo.expiresAt != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      isExpired ? Icons.timer_off : Icons.timer_outlined,
                      size: 13,
                      color: isExpired ? Colors.red[300] : Colors.orange[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExpired
                          ? '${l.t('promo_expired_prefix')} ${dateFormat.format(promo.expiresAt!)}'
                          : '${l.t('promo_expires_prefix')} ${dateFormat.format(promo.expiresAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isExpired ? Colors.red[300] : Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
  }) {
    final l = Provider.of<LocaleNotifier>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF16242D)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16242D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5A7A8A),
                height: 1.4,
              ),
            ),
            if (showButton) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(l.t('promo_create_promotion')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16242D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ===== TAB 2: Formulario de creación =====
  Widget _buildCreateForm() {
    final l = Provider.of<LocaleNotifier>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF16242D).withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF16242D),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.t('promo_new_promotion'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16242D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.t('promo_share_with_cyclists'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A7A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Campo: Título
            _buildLabel(l.t('promo_title_label')),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.t('promo_title_required')
                  : null,
              decoration: _inputDecoration(
                hint: l.t('promo_title_hint'),
                icon: Icons.title,
              ),
              style: const TextStyle(color: Color(0xFF16242D), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Campo: Descripción
            _buildLabel(l.t('promo_description_label')),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.t('promo_description_required')
                  : null,
              decoration: _inputDecoration(
                hint: l.t('promo_description_hint'),
                icon: Icons.description_outlined,
                alignTop: true,
              ),
              style: const TextStyle(color: Color(0xFF16242D), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Fila: Tipo + Fecha
            Row(
              children: [
                // Tipo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l.t('promo_type_label')),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(
                              0xFF16242D,
                            ).withValues(alpha: 0.12),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: const Color(
                                0xFF16242D,
                              ).withValues(alpha: 0.5),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF16242D),
                              fontSize: 14,
                            ),
                            dropdownColor: Colors.white,
                            items: [
                              DropdownMenuItem(
                                value: 'descuento',
                                child: Row(
                                  children: [
                                    const Text(
                                      '🏷️',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l.t('promo_type_descuento')),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'oferta',
                                child: Row(
                                  children: [
                                    const Text(
                                      '🎁',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l.t('promo_type_oferta')),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'evento',
                                child: Row(
                                  children: [
                                    const Text(
                                      '🚴',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l.t('promo_type_evento')),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'novedad',
                                child: Row(
                                  children: [
                                    const Text(
                                      '✨',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l.t('promo_type_novedad')),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedType = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Fecha expiración
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l.t('promo_expires_label')),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFF16242D,
                              ).withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: const Color(
                                  0xFF16242D,
                                ).withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedDate != null
                                      ? DateFormat(
                                          'dd/MM/yy',
                                        ).format(_selectedDate!)
                                      : l.t('promo_select_date'),
                                  style: TextStyle(
                                    color: _selectedDate != null
                                        ? const Color(0xFF16242D)
                                        : const Color(
                                            0xFF16242D,
                                          ).withValues(alpha: 0.5),
                                    fontSize: 14,
                                    fontWeight: _selectedDate != null
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedDate != null)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedDate = null),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo: Ubicación
            _buildLabel(l.t('promo_location_label')),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: _inputDecoration(
                hint: l.t('promo_location_hint'),
                icon: Icons.location_on_outlined,
              ),
              style: const TextStyle(color: Color(0xFF16242D), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Campo: Enlace o contacto
            _buildLabel(l.t('promo_contact_label')),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contactController,
              decoration: _inputDecoration(
                hint: l.t('promo_contact_hint'),
                icon: Icons.link,
              ),
              style: const TextStyle(color: Color(0xFF16242D), fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Nota informativa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16242D).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF16242D).withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Color(0xFF5A7A8A)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.t('promo_info_visibility'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A7A8A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones: Cancelar + Publicar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _titleController.clear();
                      _descriptionController.clear();
                      _locationController.clear();
                      _contactController.clear();
                      setState(() {
                        _selectedType = 'descuento';
                        _selectedDate = null;
                      });
                      _tabController.animateTo(0);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF16242D)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l.t('promo_cancel'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isPublishing ? null : _publishPromotion,
                    icon: _isPublishing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _isPublishing
                          ? l.t('promo_publishing')
                          : l.t('promo_publish_promotion'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16242D),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF16242D,
                      ).withValues(alpha: 0.6),
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ===== Helpers UI =====

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C4A5A),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool alignTop = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF16242D).withValues(alpha: 0.35),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: const Color(0xFF16242D).withValues(alpha: 0.12),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: const Color(0xFF16242D).withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF16242D), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      prefixIcon: alignTop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(
                icon,
                color: const Color(0xFF16242D).withValues(alpha: 0.4),
                size: 20,
              ),
            )
          : Icon(
              icon,
              color: const Color(0xFF16242D).withValues(alpha: 0.4),
              size: 20,
            ),
    );
  }

  // ===== Acciones =====

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF16242D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF16242D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _publishPromotion() async {
    if (!_formKey.currentState!.validate()) return;
    final l = Provider.of<LocaleNotifier>(context, listen: false);

    final user = _auth.currentUser;
    if (user == null) {
      _showSnackBar(l.t('promo_login_required'), isError: true);
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final promotion = Promotion(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        location: _locationController.text.trim(),
        contact: _contactController.text.trim(),
        expiresAt: _selectedDate,
        createdAt: DateTime.now(),
        userId: user.uid,
        userName: user.displayName ?? l.t('promo_default_username'),
      );

      await _promotionsRef.add(promotion.toMap());

      // Limpiar formulario
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _contactController.clear();
      setState(() {
        _selectedType = 'descuento';
        _selectedDate = null;
      });

      _showSnackBar(l.t('promo_published_success'));

      // Ir a pestaña de activas
      _tabController.animateTo(0);
    } catch (e) {
      _showSnackBar('${l.t('promo_error_publishing')}: $e', isError: true);
    } finally {
      setState(() => _isPublishing = false);
    }
  }

  void _confirmDelete(Promotion promo) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l.t('promo_delete_title'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF16242D),
          ),
        ),
        content: Text(
          '${l.t('promo_confirm_delete')} "${promo.title}"?\n${l.t('promo_action_irreversible')}',
          style: const TextStyle(color: Color(0xFF5A7A8A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _promotionsRef.doc(promo.id).delete();
                _showSnackBar(l.t('promo_deleted_success'));
              } catch (e) {
                _showSnackBar(
                  '${l.t('promo_error_deleting')}: $e',
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l.t('promo_delete_button')),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFF16242D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
