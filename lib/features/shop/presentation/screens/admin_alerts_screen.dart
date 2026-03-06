import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:intl/intl.dart';
import 'package:biux/features/shop/data/datasources/alert_pdf_export_service.dart';

class AdminAlertsScreen extends StatefulWidget {
  const AdminAlertsScreen({super.key});

  @override
  State<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends State<AdminAlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCity = 'Todas';
  String _selectedStatus = 'Todas';
  String _searchQuery = '';
  String _sortBy = 'Reciente';
  final Set<String> _selectedAlerts = {};
  bool _selectMode = false;

  static const _allCities = [
    'Bogota',
    'Medellin',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Pereira',
    'Manizales',
    'Santa Marta',
    'Ibague',
    'Cucuta',
    'Villavicencio',
    'Pasto',
    'Monteria',
    'Neiva',
    'Armenia',
    'Popayan',
    'Sincelejo',
    'Tunja',
    'Valledupar',
    'Riohacha',
    'Quibdo',
    'Florencia',
    'Yopal',
    'Mocoa',
    'Zipaquira',
    'Chia',
    'Soacha',
    'Envigado',
    'Bello',
    'Itagui',
    'Sabaneta',
    'Rionegro',
    'Palmira',
    'Buenaventura',
  ];
  static const _statuses = ['Todas', 'Pendiente', 'Revisada', 'Bloqueado'];
  static const _sorts = ['Reciente', 'Ciudad', 'Vendedor'];

  String _statusDisplay(String status, LocaleNotifier l) {
    const map = {
      'Todas': 'filter_all',
      'Pendiente': 'status_pending',
      'Revisada': 'status_reviewed',
      'Bloqueado': 'status_blocked',
    };
    return l.t(map[status] ?? status);
  }

  String _sortDisplay(String sort, LocaleNotifier l) {
    const map = {
      'Reciente': 'sort_recent',
      'Ciudad': 'sort_city',
      'Vendedor': 'sort_seller',
    };
    return l.t(map[sort] ?? sort);
  }

  String _filterAllDisplay(String val, LocaleNotifier l) {
    if (val == 'Todas') return l.t('filter_all');
    return val;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============ SEARCHABLE SELECTOR ============
  Future<String?> _showSearchableSelector({
    required String title,
    required List<String> items,
    String? current,
    bool addTodas = false,
    IconData itemIcon = Icons.location_city,
    String Function(String)? displayMapper,
  }) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final allItems = addTodas ? ['Todas', ...items] : items;
    String filter = '';
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = filter.isEmpty
              ? allItems
              : allItems
                    .where(
                      (e) => e.toLowerCase().contains(filter.toLowerCase()),
                    )
                    .toList();
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: ColorTokens.primary50),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l.t('search_hint'),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ColorTokens.primary50,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    onChanged: (v) => setModalState(() => filter = v),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filtered.length} ${filtered.length != 1 ? l.t('results_plural') : l.t('result_singular')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(height: 1),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l.t('no_results'),
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Colors.grey.shade200,
                          ),
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            final isSel = item == current;
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                item == 'Todas' ? Icons.public : itemIcon,
                                size: 20,
                                color: isSel
                                    ? ColorTokens.primary50
                                    : Colors.grey[400],
                              ),
                              title: Text(
                                displayMapper?.call(item) ?? item,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSel
                                      ? ColorTokens.primary50
                                      : const Color(0xFF16242D),
                                ),
                              ),
                              trailing: isSel
                                  ? Icon(
                                      Icons.check_circle,
                                      color: ColorTokens.primary50,
                                      size: 20,
                                    )
                                  : null,
                              onTap: () => Navigator.pop(ctx, item),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _searchableChip(
    String label,
    String value,
    IconData icon,
    List<String> items,
    bool addTodas,
    ValueChanged<String> onChanged, {
    IconData itemIcon = Icons.location_city,
    String Function(String)? displayMapper,
  }) {
    final isAll = value == 'Todas';
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final r = await _showSearchableSelector(
            title: label,
            items: items,
            current: value,
            addTodas: addTodas,
            itemIcon: itemIcon,
            displayMapper: displayMapper,
          );
          if (r != null) onChanged(r);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isAll
                ? const Color(0xFFF8F9FA)
                : ColorTokens.primary50.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAll
                  ? Colors.grey.shade300
                  : ColorTokens.primary50.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isAll ? Colors.grey[500] : ColorTokens.primary50,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  displayMapper?.call(value) ?? value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isAll ? FontWeight.w400 : FontWeight.w600,
                    color: isAll ? Colors.grey[600] : ColorTokens.primary50,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    String Function(String)? displayMapper,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            style: const TextStyle(fontSize: 12, color: Color(0xFF16242D)),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(displayMapper?.call(e) ?? e),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(l.t('alerts_dashboard')),
        backgroundColor: const Color(0xFF2D2D3A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectMode && _selectedAlerts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, size: 22),
              tooltip: l.t('delete_selected'),
              onPressed: _deleteSelectedAlerts,
            ),
          IconButton(
            icon: Icon(_selectMode ? Icons.close : Icons.checklist, size: 22),
            tooltip: _selectMode ? l.t('cancel') : l.t('select'),
            onPressed: () => setState(() {
              _selectMode = !_selectMode;
              _selectedAlerts.clear();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.file_download, size: 22),
            tooltip: l.t('export'),
            onPressed: _exportReport,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              icon: const Icon(Icons.warning_amber, size: 20),
              text: l.t('alerts'),
            ),
            Tab(
              icon: const Icon(Icons.analytics, size: 20),
              text: l.t('statistics'),
            ),
            Tab(
              icon: const Icon(Icons.block, size: 20),
              text: l.t('blocked_users_tab'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAlertsTab(), _buildStatsTab(), _buildBlockedTab()],
      ),
    );
  }

  // ===================== TAB 1: ALERTAS =====================
  Widget _buildAlertsTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: l.t('search_seller_serial_brand'),
                  prefixIcon: Icon(Icons.search, color: ColorTokens.primary50),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: ColorTokens.primary50,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _searchableChip(
                    l.t('city'),
                    _selectedCity,
                    Icons.location_city,
                    _allCities,
                    true,
                    (v) => setState(() => _selectedCity = v),
                    displayMapper: (v) => _filterAllDisplay(v, l),
                  ),
                  const SizedBox(width: 8),
                  _searchableChip(
                    l.t('status'),
                    _selectedStatus,
                    Icons.flag,
                    _statuses.sublist(1),
                    true,
                    (v) => setState(() => _selectedStatus = v),
                    itemIcon: Icons.flag,
                    displayMapper: (v) => _statusDisplay(v, l),
                  ),
                  const SizedBox(width: 8),
                  _smallDropdown(
                    _sortBy,
                    _sorts,
                    (v) => setState(() => _sortBy = v!),
                    displayMapper: (v) => _sortDisplay(v, l),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date filter
              GestureDetector(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _startDate != null
                        ? ColorTokens.primary50.withValues(alpha: 0.08)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _startDate != null
                          ? ColorTokens.primary50.withValues(alpha: 0.3)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 16,
                        color: _startDate != null
                            ? ColorTokens.primary50
                            : Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _startDate == null
                            ? l.t('all_dates')
                            : '${DateFormat('dd/MM/yy').format(_startDate!)} - ${_endDate != null ? DateFormat('dd/MM/yy').format(_endDate!) : l.t('today')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _startDate != null
                              ? ColorTokens.primary50
                              : Colors.grey[600],
                          fontWeight: _startDate != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      if (_startDate != null)
                        GestureDetector(
                          onTap: () => setState(() {
                            _startDate = null;
                            _endDate = null;
                          }),
                          child: Icon(
                            Icons.clear,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Select mode bar
        if (_selectMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: ColorTokens.primary50.withValues(alpha: 0.08),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: ColorTokens.primary50,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedAlerts.length} ${l.t('selected_count_suffix')}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.primary50,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _selectedAlerts.clear()),
                  child: Text(
                    l.t('clear'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        // List
        Expanded(child: _buildAlertsList()),
      ],
    );
  }

  Widget _buildAlertsList() {
    final l = Provider.of<LocaleNotifier>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _getAlertsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, size: 48, color: ColorTokens.error50),
                const SizedBox(height: 12),
                Text(
                  '${l.t('error')}: ${snapshot.error}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: ColorTokens.error50),
                const SizedBox(height: 12),
                Text(
                  l.t('loading_alerts'),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        var alerts = snapshot.data!.docs;

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          alerts = alerts.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final bike = d['bikeData'] as Map<String, dynamic>? ?? {};
            final seller = (d['sellerName'] ?? '').toString().toLowerCase();
            final serial = (bike['frameSerial'] ?? '').toString().toLowerCase();
            final brand = (bike['brand'] ?? '').toString().toLowerCase();
            final model = (bike['model'] ?? '').toString().toLowerCase();
            return seller.contains(q) ||
                serial.contains(q) ||
                brand.contains(q) ||
                model.contains(q);
          }).toList();
        }

        // Sort
        if (_sortBy == 'Ciudad') {
          alerts.sort((a, b) {
            final ca =
                ((a.data() as Map<String, dynamic>)['bikeData']
                    as Map<String, dynamic>?)?['city'] ??
                '';
            final cb =
                ((b.data() as Map<String, dynamic>)['bikeData']
                    as Map<String, dynamic>?)?['city'] ??
                '';
            return ca.toString().compareTo(cb.toString());
          });
        } else if (_sortBy == 'Vendedor') {
          alerts.sort((a, b) {
            final sa = (a.data() as Map<String, dynamic>)['sellerName'] ?? '';
            final sb = (b.data() as Map<String, dynamic>)['sellerName'] ?? '';
            return sa.toString().compareTo(sb.toString());
          });
        }

        if (alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 12),
                Text(
                  l.t('no_alerts'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.t('no_sale_attempts_detected'),
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: ColorTokens.error50,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alerts.length,
            itemBuilder: (c, i) => _alertCard(alerts[i]),
          ),
        );
      },
    );
  }

  Widget _alertCard(QueryDocumentSnapshot doc) {
    final l = Provider.of<LocaleNotifier>(context);
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final ts = data['timestamp'] as Timestamp?;
    final date = ts != null
        ? DateFormat('dd/MM/yy HH:mm').format(ts.toDate())
        : '—';
    final bike = data['bikeData'] as Map<String, dynamic>? ?? {};
    final seller = data['sellerName'] ?? l.t('unknown_person');
    final sellerUid = data['sellerUid'] ?? '';
    final serial = bike['frameSerial'] ?? '—';
    final brand = bike['brand'] ?? '—';
    final model = bike['model'] ?? '—';
    final color = bike['color'] ?? '—';
    final city = bike['city'] ?? '—';
    final isSel = _selectedAlerts.contains(id);

    return Card(
      elevation: isSel ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSel
              ? ColorTokens.primary50
              : ColorTokens.error50.withValues(alpha: 0.3),
          width: isSel ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: ColorTokens.error50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                if (_selectMode)
                  GestureDetector(
                    onTap: () => setState(() {
                      isSel
                          ? _selectedAlerts.remove(id)
                          : _selectedAlerts.add(id);
                    }),
                    child: Icon(
                      isSel ? Icons.check_box : Icons.check_box_outline_blank,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                if (_selectMode) const SizedBox(width: 8),
                const Icon(Icons.dangerous, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.t('stolen_sale_attempt'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seller
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorTokens.error50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person,
                        color: ColorTokens.error50,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16242D),
                            ),
                          ),
                          Text(
                            'UID: ${sellerUid.toString().length > 16 ? '${sellerUid.toString().substring(0, 16)}...' : sellerUid}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Bike info grid
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _miniInfo(
                              Icons.fingerprint,
                              l.t('serial_label'),
                              serial.toString(),
                            ),
                          ),
                          Expanded(
                            child: _miniInfo(
                              Icons.branding_watermark,
                              l.t('brand_label'),
                              brand.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _miniInfo(
                              Icons.directions_bike,
                              l.t('model_label'),
                              model.toString(),
                            ),
                          ),
                          Expanded(
                            child: _miniInfo(
                              Icons.palette,
                              l.t('color_label'),
                              color.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _miniInfo(
                              Icons.location_on,
                              l.t('city'),
                              city.toString(),
                            ),
                          ),
                          if (bike['year'] != null)
                            Expanded(
                              child: _miniInfo(
                                Icons.calendar_today,
                                l.t('year_label'),
                                bike['year'].toString(),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility, size: 16),
                        label: Text(
                          l.t('detail'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _showAlertDetails(id, data),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.block, size: 16),
                        label: Text(
                          l.t('block'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTokens.error50,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _blockSeller(
                          sellerUid.toString(),
                          seller.toString(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.grey[500],
                        ),
                        onPressed: () => _deleteAlert(id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 9, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16242D),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================== TAB 2: ESTADISTICAS =====================
  Widget _buildStatsTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('theft_alerts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final alerts = snapshot.data!.docs;
        final now = DateTime.now();

        final today = alerts.where((d) {
          final ts =
              (d.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          if (ts == null) return false;
          final dt = ts.toDate();
          return dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day;
        }).length;

        final thisWeek = alerts.where((d) {
          final ts =
              (d.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          if (ts == null) return false;
          return now.difference(ts.toDate()).inDays <= 7;
        }).length;

        final thisMonth = alerts.where((d) {
          final ts =
              (d.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          if (ts == null) return false;
          final dt = ts.toDate();
          return dt.year == now.year && dt.month == now.month;
        }).length;

        final sellers = alerts
            .map((d) => (d.data() as Map<String, dynamic>)['sellerUid'])
            .toSet()
            .length;

        // City stats
        final cityCount = <String, int>{};
        for (final doc in alerts) {
          final bike =
              (doc.data() as Map<String, dynamic>)['bikeData']
                  as Map<String, dynamic>?;
          final c = bike?['city']?.toString() ?? l.t('unknown_city');
          cityCount[c] = (cityCount[c] ?? 0) + 1;
        }
        final sortedCities = cityCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Brand stats
        final brandCount = <String, int>{};
        for (final doc in alerts) {
          final bike =
              (doc.data() as Map<String, dynamic>)['bikeData']
                  as Map<String, dynamic>?;
          final b = bike?['brand']?.toString() ?? l.t('unknown_city');
          brandCount[b] = (brandCount[b] ?? 0) + 1;
        }
        final sortedBrands = brandCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  _statCard(
                    Icons.warning,
                    l.t('total'),
                    alerts.length.toString(),
                    ColorTokens.error50,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    Icons.today,
                    l.t('today'),
                    today.toString(),
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statCard(
                    Icons.date_range,
                    l.t('week'),
                    thisWeek.toString(),
                    ColorTokens.primary50,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    Icons.calendar_month,
                    l.t('month_label'),
                    thisMonth.toString(),
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statCard(
                    Icons.people,
                    l.t('sellers'),
                    sellers.toString(),
                    ColorTokens.secondary50,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    Icons.location_city,
                    l.t('cities'),
                    cityCount.length.toString(),
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // City ranking
              _sectionTitle(Icons.location_on, l.t('alerts_by_city')),
              const SizedBox(height: 10),
              ...sortedCities
                  .take(10)
                  .map(
                    (e) => _rankingBar(
                      e.key,
                      e.value,
                      alerts.length,
                      ColorTokens.error50,
                    ),
                  ),
              const SizedBox(height: 20),
              // Brand ranking
              _sectionTitle(
                Icons.branding_watermark,
                l.t('most_affected_brands'),
              ),
              const SizedBox(height: 10),
              ...sortedBrands
                  .take(10)
                  .map(
                    (e) => _rankingBar(
                      e.key,
                      e.value,
                      alerts.length,
                      ColorTokens.primary50,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ColorTokens.error50.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ColorTokens.error50, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF16242D),
          ),
        ),
      ],
    );
  }

  Widget _rankingBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  ' (${(pct * 100).toStringAsFixed(0)}%)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== TAB 3: BLOQUEADOS =====================
  Widget _buildBlockedTab() {
    final l = Provider.of<LocaleNotifier>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('canCreateProducts', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final blocked = snapshot.data!.docs;

        if (blocked.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 56, color: Colors.green[400]),
                const SizedBox(height: 12),
                Text(
                  l.t('no_blocked_users'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: blocked.length,
          itemBuilder: (c, i) {
            final d = blocked[i].data() as Map<String, dynamic>;
            final uid = blocked[i].id;
            final name = d['name'] ?? d['displayName'] ?? l.t('no_name');
            final reason = d['blockedReason'] ?? l.t('no_reason');
            final blockedAt = d['blockedAt'] as Timestamp?;
            final dateStr = blockedAt != null
                ? DateFormat('dd/MM/yy HH:mm').format(blockedAt.toDate())
                : '—';

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorTokens.error50.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_off,
                        color: ColorTokens.error50,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'UID: ${uid.length > 20 ? '${uid.substring(0, 20)}...' : uid}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reason.toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l.t('blocked_date_prefix')}: $dateStr',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.lock_open,
                        color: Colors.green[600],
                        size: 22,
                      ),
                      tooltip: l.t('unblock'),
                      onPressed: () => _unblockUser(uid, name.toString()),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================== ACTIONS =====================
  Stream<QuerySnapshot> _getAlertsStream() {
    Query query = FirebaseFirestore.instance
        .collection('theft_alerts')
        .orderBy('timestamp', descending: true);
    if (_selectedCity != 'Todas')
      query = query.where('bikeData.city', isEqualTo: _selectedCity);
    if (_startDate != null)
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
      );
    if (_endDate != null) {
      final end = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(end),
      );
    }
    return query.limit(200).snapshots();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null)
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
  }

  void _showAlertDetails(String alertId, Map<String, dynamic> data) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final bike = data['bikeData'] as Map<String, dynamic>? ?? {};
    final ts = data['timestamp'] as Timestamp?;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.dangerous, color: ColorTokens.error50),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.t('alert_detail'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailSection(l.t('alert_section'), [
                      _detailRow(l.t('id_label'), alertId),
                      _detailRow(
                        l.t('date_label'),
                        ts != null
                            ? DateFormat(
                                'dd/MM/yyyy HH:mm:ss',
                              ).format(ts.toDate())
                            : '—',
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _detailSection(l.t('seller_label'), [
                      _detailRow(
                        l.t('name_label'),
                        data['sellerName']?.toString() ?? '—',
                      ),
                      _detailRow('UID', data['sellerUid']?.toString() ?? '—'),
                    ]),
                    const SizedBox(height: 16),
                    _detailSection(l.t('bicycle'), [
                      _detailRow(
                        l.t('serial_label'),
                        bike['frameSerial']?.toString() ?? '—',
                      ),
                      _detailRow(
                        l.t('brand_label'),
                        bike['brand']?.toString() ?? '—',
                      ),
                      _detailRow(
                        l.t('model_label'),
                        bike['model']?.toString() ?? '—',
                      ),
                      _detailRow(
                        l.t('color_label'),
                        bike['color']?.toString() ?? '—',
                      ),
                      _detailRow(l.t('city'), bike['city']?.toString() ?? '—'),
                      if (bike['year'] != null)
                        _detailRow(l.t('year_label'), bike['year'].toString()),
                    ]),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.block, size: 18),
                            label: Text(l.t('block_seller')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorTokens.error50,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _blockSeller(
                                data['sellerUid']?.toString() ?? '',
                                data['sellerName']?.toString() ?? '',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            label: Text(
                              l.t('delete'),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteAlert(alertId);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF16242D),
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _blockSeller(String uid, String name) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.block, color: ColorTokens.error50, size: 40),
        title: Text(l.t('block_seller')),
        content: Text(
          '${l.t('block_question')} $name?\n${l.t('cannot_create_store_products')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l.t('block')),
          ),
        ],
      ),
    );
    if (confirm != true || uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'canCreateProducts': false,
        'blockedReason': l.t('stolen_bike_reason'),
        'blockedAt': FieldValue.serverTimestamp(),
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name ${l.t('user_blocked_msg')}'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error')}: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
    }
  }

  Future<void> _unblockUser(String uid, String name) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.lock_open, color: Colors.green, size: 40),
        title: Text(l.t('unblock_user')),
        content: Text(
          '${l.t('unblock_question')} $name?\n${l.t('can_create_products_again')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l.t('unblock')),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'canCreateProducts': true,
        'blockedReason': FieldValue.delete(),
        'blockedAt': FieldValue.delete(),
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name ${l.t('user_unblocked_msg')}'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error')}: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
    }
  }

  Future<void> _deleteAlert(String id) async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    try {
      await FirebaseFirestore.instance
          .collection('theft_alerts')
          .doc(id)
          .delete();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('alert_deleted')),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error')}: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
    }
  }

  Future<void> _deleteSelectedAlerts() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.delete_sweep, color: ColorTokens.error50, size: 40),
        title: Text(l.t('delete_selected_title')),
        content: Text(
          '${l.t('delete')} ${_selectedAlerts.length} ${l.t('alerts')}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l.t('delete')),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in _selectedAlerts) {
        batch.delete(
          FirebaseFirestore.instance.collection('theft_alerts').doc(id),
        );
      }
      await batch.commit();
      setState(() {
        _selectedAlerts.clear();
        _selectMode = false;
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('alerts_deleted')),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error')}: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
    }
  }

  Future<void> _exportReport() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Text(l.t('generating_pdf')),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final snapshot = await _getAlertsQuery().get();
      final alerts = snapshot.docs;

      if (alerts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.t('no_alerts_to_export')),
              backgroundColor: ColorTokens.error50,
            ),
          );
        }
        return;
      }

      String? dateRange;
      if (_startDate != null) {
        final start = DateFormat('dd/MM/yyyy').format(_startDate!);
        final end = _endDate != null
            ? DateFormat('dd/MM/yyyy').format(_endDate!)
            : l.t('today');
        dateRange = '$start - $end';
      }

      await AlertPdfExportService.exportAlerts(
        alerts: alerts,
        cityFilter: _selectedCity,
        dateRange: dateRange,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error_generating_pdf')}: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }

  Query _getAlertsQuery() {
    Query query = FirebaseFirestore.instance
        .collection('theft_alerts')
        .orderBy('timestamp', descending: true);
    if (_selectedCity != 'Todas')
      query = query.where('bikeData.city', isEqualTo: _selectedCity);
    if (_startDate != null)
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
      );
    if (_endDate != null) {
      final end = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(end),
      );
    }
    return query.limit(200);
  }
}
