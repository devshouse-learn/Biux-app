import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/shop/data/datasources/stolen_bike_verification_datasource.dart';
import 'package:biux/features/bikes/data/repositories/bike_repository_impl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StolenBikesScreen extends StatefulWidget {
  const StolenBikesScreen({Key? key}) : super(key: key);

  @override
  State<StolenBikesScreen> createState() => _StolenBikesScreenState();
}

class _StolenBikesScreenState extends State<StolenBikesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StolenBikeVerificationService _verificationService;
  List<StolenBikeInfo> _stolenBikes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCity = 'Todas';
  String _selectedType = 'Todas';
  String _sortBy = 'Reciente';

  final _serialController = TextEditingController();
  VerificationResult? _verificationResult;
  bool _isVerifying = false;

  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _policeCtrl = TextEditingController();
  String _formCity = '';
  DateTime? _theftDate;
  String _bikeType = 'Ruta';

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
    'Leticia',
    'Puerto Carreno',
    'Inirida',
    'Mitu',
    'San Jose del Guaviare',
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
    'Tulua',
    'Cartago',
    'Sogamoso',
    'Duitama',
    'Girardot',
  ];

  static const _bikeTypes = [
    'Ruta',
    'MTB',
    'Urbana',
    'Electrica',
    'Infantil',
    'Otra',
  ];
  final _sorts = ['Reciente', 'Ciudad', 'Marca'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _serialController.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _colorCtrl.dispose();
    _serialCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _policeCtrl.dispose();
    super.dispose();
  }

  Future<void> _initService() async {
    _verificationService = StolenBikeVerificationService(
      bikeRepository: BikeRepositoryImpl(),
    );
    await _loadBikes();
  }

  Future<void> _loadBikes() async {
    setState(() => _isLoading = true);
    try {
      final bikes = await _verificationService.getAllStolenBikes();
      setState(() {
        _stolenBikes = bikes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<StolenBikeInfo> get _filtered {
    var list = _stolenBikes;
    if (_selectedCity != 'Todas') {
      list = list
          .where(
            (i) => i.bike.city.toLowerCase() == _selectedCity.toLowerCase(),
          )
          .toList();
    }
    if (_selectedType != 'Todas') {
      list = list
          .where(
            (i) => i.bike.type.toString().toLowerCase().contains(
              _selectedType.toLowerCase(),
            ),
          )
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (i) =>
                i.bike.brand.toLowerCase().contains(q) ||
                i.bike.model.toLowerCase().contains(q) ||
                i.bike.color.toLowerCase().contains(q) ||
                i.bike.frameSerial.toLowerCase().contains(q),
          )
          .toList();
    }
    switch (_sortBy) {
      case 'Ciudad':
        list.sort((a, b) => a.bike.city.compareTo(b.bike.city));
        break;
      case 'Marca':
        list.sort((a, b) => a.bike.brand.compareTo(b.bike.brand));
        break;
      default:
        list.sort(
          (a, b) =>
              b.theftReport.reportDate.compareTo(a.theftReport.reportDate),
        );
    }
    return list;
  }

  Future<void> _verifySerial() async {
    if (_serialController.text.trim().isEmpty) return;
    setState(() {
      _isVerifying = true;
      _verificationResult = null;
    });
    try {
      final result = await _verificationService.verifyBikeNotStolen(
        frameSerial: _serialController.text.trim(),
      );
      setState(() {
        _verificationResult = result;
        _isVerifying = false;
      });
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        final l = Provider.of<LocaleNotifier>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.t('error_generic')}: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }

  Future<String?> _showSearchableSelector({
    required String title,
    required List<String> items,
    String? current,
    bool addTodas = false,
  }) async {
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
          final isDarkSheet = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDarkSheet ? const Color(0xFF1E2A32) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                      hintText: 'Buscar...',
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
                      fillColor: isDarkSheet
                          ? const Color(0xFF1E2A32)
                          : const Color(0xFFF8F9FA),
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
                      '${filtered.length} resultado${filtered.length != 1 ? "s" : ""}',
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
                                'Sin resultados',
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
                            final isSelected = item == current;
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                item == 'Todas'
                                    ? Icons.public
                                    : Icons.location_city,
                                size: 20,
                                color: isSelected
                                    ? ColorTokens.primary50
                                    : Colors.grey[400],
                              ),
                              title: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? ColorTokens.primary50
                                      : const Color(0xFF16242D),
                                ),
                              ),
                              trailing: isSelected
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
    ValueChanged<String> onChanged,
  ) {
    final isAll = value == 'Todas';
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final result = await _showSearchableSelector(
            title: label,
            items: items,
            current: value,
            addTodas: addTodas,
          );
          if (result != null) onChanged(result);
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
                  value,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Bicicletas Robadas'),
        backgroundColor: ColorTokens.error50,
        foregroundColor: Colors.white,
        elevation: 0,
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
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt, size: 20), text: 'Listado'),
            Tab(icon: Icon(Icons.search, size: 20), text: 'Verificar'),
            Tab(icon: Icon(Icons.report, size: 20), text: 'Reportar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildListTab(), _buildVerifyTab(), _buildReportTab()],
      ),
    );
  }

  Widget _buildListTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: ColorTokens.error50,
          child: Row(
            children: [
              _statBox(Icons.warning, '${_stolenBikes.length}', 'Reportadas'),
              const SizedBox(width: 10),
              _statBox(
                Icons.location_city,
                _countCities().toString(),
                'Ciudades',
              ),
              const SizedBox(width: 10),
              _statBox(Icons.today, _countThisMonth().toString(), 'Este mes'),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E2A32)
              : Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar marca, modelo, color o serial...',
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
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E2A32)
                      : const Color(0xFFF8F9FA),
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
                    'Ciudad',
                    _selectedCity,
                    Icons.location_city,
                    _allCities,
                    true,
                    (v) => setState(() => _selectedCity = v),
                  ),
                  const SizedBox(width: 8),
                  _searchableChip(
                    'Tipo',
                    _selectedType,
                    Icons.pedal_bike,
                    _bikeTypes,
                    true,
                    (v) => setState(() => _selectedType = v),
                  ),
                  const SizedBox(width: 8),
                  _smallDropdown(
                    'Orden',
                    _sortBy,
                    _sorts,
                    (v) => setState(() => _sortBy = v!),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: ColorTokens.error50),
                      const SizedBox(height: 12),
                      Text(
                        'Cargando...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No se encontraron resultados',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBikes,
                  color: ColorTokens.error50,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (c, i) => _bikeCard(_filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildVerifyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorTokens.primary30,
                  ColorTokens.primary30.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield, color: Colors.white, size: 36),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verificador de Bicicletas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ingresa el numero de serie para saber si esta reportada como robada.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Numero de serie del cuadro',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _serialController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Ej: WTU123H456789',
              prefixIcon: const Icon(Icons.fingerprint),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _serialController.clear();
                  setState(() => _verificationResult = null);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorTokens.primary50, width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E2A32)
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isVerifying ? null : _verifySerial,
              icon: _isVerifying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.verified_user),
              label: Text(
                _isVerifying ? 'Verificando...' : 'Verificar Bicicleta',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary30,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_verificationResult != null) _buildVerificationResult(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.amber.shade900.withValues(alpha: 0.25)
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.amber.shade700
                    : Colors.amber.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Donde encontrar el serial',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _tip('Parte inferior del cuadro (bottom bracket)'),
                _tip('Tubo del asiento'),
                _tip('Vaina inferior cerca del pedal'),
                _tip('Parte trasera del tubo de direccion'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationResult() {
    final r = _verificationResult!;
    final stolen = r.isStolen;
    final c = stolen ? ColorTokens.error50 : Colors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stolen ? Icons.dangerous : Icons.check_circle,
                color: c,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  r.message,
                  style: TextStyle(
                    color: c,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          if (r.details != null) ...[
            const SizedBox(height: 10),
            Text(
              r.details!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          if (stolen) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E2A32)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone, color: ColorTokens.error50, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Contacta a las autoridades si la encuentras',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorTokens.error50.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorTokens.error50.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColorTokens.error50,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Reporta tu bicicleta robada para alertar a la comunidad y evitar su reventa.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionHeader(Icons.pedal_bike, 'Datos de la Bicicleta'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _brandCtrl,
                    'Marca *',
                    'Ej: Specialized',
                    Icons.branding_watermark,
                    true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    _modelCtrl,
                    'Modelo *',
                    'Ej: Allez Sprint',
                    Icons.info_outline,
                    true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _colorCtrl,
                    'Color *',
                    'Ej: Negro/Rojo',
                    Icons.palette,
                    true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _searchableTapField(
                    'Tipo *',
                    _bikeType,
                    Icons.pedal_bike,
                    () async {
                      final r = await _showSearchableSelector(
                        title: 'Tipo de Bicicleta',
                        items: _bikeTypes,
                        current: _bikeType,
                      );
                      if (r != null) setState(() => _bikeType = r);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _field(
              _serialCtrl,
              'Numero de Serie *',
              'Numero del cuadro',
              Icons.fingerprint,
              true,
            ),
            const SizedBox(height: 10),
            _searchableTapField(
              'Ciudad *',
              _formCity.isEmpty ? '' : _formCity,
              Icons.location_city,
              () async {
                final r = await _showSearchableSelector(
                  title: 'Seleccionar Ciudad',
                  items: _allCities,
                  current: _formCity,
                );
                if (r != null) setState(() => _formCity = r);
              },
              isEmpty: _formCity.isEmpty,
            ),
            const SizedBox(height: 20),
            _sectionHeader(Icons.report_problem, 'Detalles del Robo'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  helpText: 'Fecha del robo',
                );
                if (picked != null) setState(() => _theftDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E2A32)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _theftDate != null
                          ? '${_theftDate!.day}/${_theftDate!.month}/${_theftDate!.year}'
                          : 'Fecha del robo *',
                      style: TextStyle(
                        color: _theftDate != null
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87)
                            : Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _field(
              _locationCtrl,
              'Lugar del robo *',
              'Direccion o referencia',
              Icons.place,
              true,
            ),
            const SizedBox(height: 10),
            _field(
              _descCtrl,
              'Descripcion *',
              'Como sucedio el robo...',
              Icons.description,
              true,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            _field(
              _policeCtrl,
              'Numero de denuncia policial',
              'Opcional',
              Icons.policy,
              false,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitReport,
                icon: const Icon(Icons.send),
                label: const Text('Enviar Reporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTokens.error50,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Al enviar confirmas que la informacion es veridica',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate() || _formCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos obligatorios'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_theftDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la fecha del robo'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Reporte Enviado'),
        content: const Text(
          'Tu reporte ha sido registrado. La comunidad sera alertada.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              _clearForm();
              _tabController.animateTo(0);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _brandCtrl.clear();
    _modelCtrl.clear();
    _colorCtrl.clear();
    _serialCtrl.clear();
    _locationCtrl.clear();
    _descCtrl.clear();
    _policeCtrl.clear();
    setState(() {
      _theftDate = null;
      _bikeType = 'Ruta';
      _formCity = '';
    });
  }

  Widget _statBox(IconData icon, String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallDropdown(
    String hint,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E2A32)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: true,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF16242D),
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon,
    bool req, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: req
          ? (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.primary50, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.error50),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E2A32)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }

  Widget _searchableTapField(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap, {
    bool isEmpty = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E2A32)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEmpty ? label : value,
                style: TextStyle(
                  color: isEmpty
                      ? Colors.grey[500]
                      : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87),
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
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

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.amber[900])),
        ],
      ),
    );
  }

  Widget _bikeCard(StolenBikeInfo info) {
    final bike = info.bike;
    final theft = info.theftReport;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: ColorTokens.error50.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: ColorTokens.error50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'ROBADA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '${theft.theftDate.day}/${theft.theftDate.month}/${theft.theftDate.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: bike.mainPhoto.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: bike.mainPhoto,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (c, u, e) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.pedal_bike,
                              size: 36,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.pedal_bike,
                            size: 36,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bike.brand} ${bike.model}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16242D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _infoRow(Icons.palette, bike.color),
                      _infoRow(Icons.fingerprint, bike.frameSerial),
                      _infoRow(
                        Icons.location_on,
                        '${bike.city}${bike.neighborhood != null ? " - ${bike.neighborhood}" : ""}',
                      ),
                      _infoRow(Icons.place, theft.location),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (theft.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  theft.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                if (theft.policeReportNumber != null) ...[
                  Icon(Icons.policy, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Denuncia: ${theft.policeReportNumber}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColorTokens.error50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block, size: 12, color: ColorTokens.error50),
                      const SizedBox(width: 4),
                      Text(
                        'No comprar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ColorTokens.error50,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _countCities() => _stolenBikes.map((e) => e.bike.city).toSet().length;
  int _countThisMonth() {
    final now = DateTime.now();
    return _stolenBikes
        .where(
          (e) =>
              e.theftReport.theftDate.month == now.month &&
              e.theftReport.theftDate.year == now.year,
        )
        .length;
  }
}
