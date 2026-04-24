import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:biux/features/users/presentation/providers/user_provider.dart';
import 'package:biux/features/promotions/data/models/promotion_request_model.dart';
import 'package:biux/features/promotions/presentation/providers/promotions_provider.dart';
import 'package:intl/intl.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({Key? key}) : super(key: key);

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('promotions_businesses_and_events'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              icon: Icon(Icons.storefront),
              text: l.t('promotions_businesses'),
            ),
            Tab(icon: Icon(Icons.event), text: l.t('promotions_events')),
          ],
        ),
        actions: [
          Consumer<UserProvider>(
            builder: (context, up, _) {
              if (!(up.user?.isAdmin ?? false)) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.admin_panel_settings),
                tooltip: l.t('promotions_admin_panel'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _AdminPanelScreen()),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_BusinessTab(), _EventsTab()],
      ),
      floatingActionButton: Consumer<PromotionsProvider>(
        builder: (context, provider, _) {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final isPromoter = provider.isVerifiedPromoter(uid);
          if (!isPromoter) {
            return FloatingActionButton.extended(
              heroTag: 'fab_promoter',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _PromoterRequestForm()),
              ),
              backgroundColor: const Color(0xFF6A1B9A),
              icon: Icon(Icons.verified_user, color: Colors.white),
              label: Text(
                l.t('promotions_become_promoter'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          return FloatingActionButton(
            heroTag: 'fab_create',
            onPressed: () {
              if (_tabController.index == 0) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _BusinessForm()),
                );
              } else {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const _EventForm()));
              }
            },
            backgroundColor: ColorTokens.primary30,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }
}

// =============================================================================
// FORMULARIO: Solicitar ser Promotor con verificacion de negocio
// =============================================================================
class _PromoterRequestForm extends StatefulWidget {
  const _PromoterRequestForm();
  @override
  State<_PromoterRequestForm> createState() => _PromoterRequestFormState();
}

class _PromoterRequestFormState extends State<_PromoterRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _businessDescCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _webCtrl = TextEditingController();
  String _businessType = 'tienda_bicicletas';
  bool _hasPhysicalStore = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  int _currentStep = 0;

  Map<String, String> _getTypes(LocaleNotifier l) => {
    'tienda_bicicletas': l.t('promotions_type_bike_shop'),
    'taller_reparacion': l.t('promotions_type_repair_shop'),
    'accesorios': l.t('promotions_type_accessories'),
    'ropa_ciclismo': l.t('promotions_type_cycling_clothing'),
    'eventos': l.t('promotions_type_event_organizer'),
    'cafe_ciclista': l.t('promotions_type_cafe'),
    'turismo': l.t('promotions_type_bike_tourism'),
    'otro': l.t('promotions_type_other'),
  };

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _businessDescCtrl.dispose();
    _nitCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final types = _getTypes(l);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('promotions_verify_business'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.vertical,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentStep < 2)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6A1B9A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l.t('promotions_next'),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  if (_currentStep == 2)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_isLoading || !_acceptTerms)
                            ? null
                            : _submit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 18,
                              ),
                        label: Text(
                          _isLoading
                              ? l.t('promotions_sending')
                              : l.t('promotions_send_request'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6A1B9A),
                          disabledBackgroundColor: Colors.grey[400],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) ...[
                    SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text(l.t('promotions_back')),
                    ),
                  ],
                ],
              ),
            );
          },
          onStepContinue: () {
            if (_currentStep == 0) {
              if (_businessNameCtrl.text.trim().isEmpty ||
                  _businessDescCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l.t('promotions_complete_name_and_description'),
                    ),
                    backgroundColor: ColorTokens.error50,
                  ),
                );
                return;
              }
            }
            if (_currentStep == 1) {
              if (_addressCtrl.text.trim().isEmpty ||
                  _phoneCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.t('promotions_complete_address_and_phone')),
                    backgroundColor: ColorTokens.error50,
                  ),
                );
                return;
              }
            }
            if (_currentStep < 2) setState(() => _currentStep++);
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          onStepTapped: (step) => setState(() => _currentStep = step),
          steps: [
            // PASO 1: Datos del negocio
            Step(
              title: Text(
                l.t('promotions_business_data'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l.t('promotions_basic_info')),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  _field(
                    _businessNameCtrl,
                    l.t('promotions_business_name_required'),
                    Icons.storefront,
                  ),
                  SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _businessType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l.t('promotions_business_type'),
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: types.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _businessType = v ?? 'otro'),
                  ),
                  SizedBox(height: 14),
                  _field(
                    _businessDescCtrl,
                    l.t('promotions_business_description_required'),
                    Icons.description,
                    maxLines: 3,
                    hint: l.t('promotions_products_services_hint'),
                  ),
                ],
              ),
            ),
            // PASO 2: Verificacion y contacto
            Step(
              title: Text(
                l.t('promotions_verification'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l.t('promotions_verification_data')),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  // Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.t('promotions_verification_info_text'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  _field(
                    _nitCtrl,
                    l.t('promotions_nit_optional'),
                    Icons.badge,
                    hint: l.t('promotions_nit_hint'),
                  ),
                  SizedBox(height: 14),
                  SwitchListTile(
                    value: _hasPhysicalStore,
                    onChanged: (v) => setState(() => _hasPhysicalStore = v),
                    title: Text(
                      l.t('promotions_has_physical_store'),
                      style: TextStyle(fontSize: 14),
                    ),
                    secondary: Icon(
                      Icons.store,
                      color: _hasPhysicalStore
                          ? const Color(0xFF6A1B9A)
                          : Colors.grey,
                    ),

                    contentPadding: EdgeInsets.zero,
                  ),
                  _field(
                    _addressCtrl,
                    l.t('promotions_address_required'),
                    Icons.location_on,
                  ),
                  SizedBox(height: 14),
                  _field(
                    _cityCtrl,
                    l.t('promotions_city'),
                    Icons.location_city,
                    hint: l.t('promotions_city_hint'),
                  ),
                  SizedBox(height: 14),
                  _field(
                    _phoneCtrl,
                    l.t('promotions_phone_required'),
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 14),
                  _field(
                    _emailCtrl,
                    l.t('promotions_email_optional'),
                    Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 14),
                  _field(
                    _webCtrl,
                    l.t('promotions_social_web_optional'),
                    Icons.language,
                    hint: l.t('promotions_social_web_hint'),
                  ),
                ],
              ),
            ),
            // PASO 3: Confirmacion
            Step(
              title: Text(
                l.t('promotions_confirmation'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l.t('promotions_review_and_send')),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  // Resumen
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.t('promotions_request_summary'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Divider(),
                        _summaryRow(
                          l.t('promotions_business'),
                          _businessNameCtrl.text,
                        ),
                        _summaryRow(
                          l.t('promotions_type'),
                          types[_businessType] ?? _businessType,
                        ),
                        _summaryRow(
                          l.t('promotions_address'),
                          _addressCtrl.text,
                        ),
                        if (_cityCtrl.text.isNotEmpty)
                          _summaryRow(l.t('promotions_city'), _cityCtrl.text),
                        _summaryRow(l.t('promotions_phone'), _phoneCtrl.text),
                        if (_nitCtrl.text.isNotEmpty)
                          _summaryRow(l.t('promotions_nit'), _nitCtrl.text),
                        if (_emailCtrl.text.isNotEmpty)
                          _summaryRow(l.t('promotions_email'), _emailCtrl.text),
                        if (_webCtrl.text.isNotEmpty)
                          _summaryRow(
                            l.t('promotions_web_social'),
                            _webCtrl.text,
                          ),
                        _summaryRow(
                          l.t('promotions_physical_store'),
                          _hasPhysicalStore
                              ? l.t('promotions_yes')
                              : l.t('promotions_no'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Beneficios
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF6A1B9A).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.t('promotions_once_approved'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        _BenefitRow(
                          icon: Icons.campaign,
                          text: l.t('promotions_benefit_publish_ads'),
                        ),
                        _BenefitRow(
                          icon: Icons.event,
                          text: l.t('promotions_benefit_create_events'),
                        ),
                        _BenefitRow(
                          icon: Icons.verified,
                          text: l.t('promotions_benefit_verified_badge'),
                        ),
                        _BenefitRow(
                          icon: Icons.auto_awesome,
                          text: l.t('promotions_benefit_auto_approved'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Terminos
                  CheckboxListTile(
                    value: _acceptTerms,
                    onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,

                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l.t('promotions_terms_confirmation'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final types = _getTypes(l);
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = context.read<UserProvider>().user?.name ?? l.t('user_default');
    final provider = context.read<PromotionsProvider>();

    final info =
        '${types[_businessType]} | Dir: ${_addressCtrl.text.trim()}'
        '${_cityCtrl.text.trim().isNotEmpty ? ", ${_cityCtrl.text.trim()}" : ""}'
        ' | Tel: ${_phoneCtrl.text.trim()}'
        ' | Local fisico: ${_hasPhysicalStore ? "Si" : "No"}'
        '${_nitCtrl.text.trim().isNotEmpty ? " | NIT: ${_nitCtrl.text.trim()}" : ""}'
        '${_emailCtrl.text.trim().isNotEmpty ? " | Email: ${_emailCtrl.text.trim()}" : ""}'
        '${_webCtrl.text.trim().isNotEmpty ? " | Web: ${_webCtrl.text.trim()}" : ""}'
        '\n\n${_businessDescCtrl.text.trim()}';

    final ok = await provider.requestPromoterStatus(
      uid,
      name,
      _businessNameCtrl.text.trim(),
      info,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 56,
                ),
              ),
              SizedBox(height: 16),
              Text(
                l.t('promotions_request_sent'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                l.t('promotions_admin_will_verify'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l.t('promotions_understood'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('promotions_send_error')),
          backgroundColor: ColorTokens.error50,
        ),
      );
    }
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6A1B9A)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

// =============================================================================
// FORMULARIO: Crear Negocio
// =============================================================================
class _BusinessForm extends StatefulWidget {
  const _BusinessForm();
  @override
  State<_BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends State<_BusinessForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l.t('promotions_publish_business'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ColorTokens.primary30,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorTokens.primary30,
                      ColorTokens.primary30.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.storefront, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text(
                      l.t('promotions_new_business'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      l.t('promotions_publish_for_community'),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Seccion datos
              _sectionTitle(
                l.t('promotions_business_info'),
                Icons.info_outline,
              ),
              SizedBox(height: 12),
              _buildField(
                _titleCtrl,
                l.t('promotions_business_name_required'),
                Icons.storefront,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.t('promotions_name_required_error')
                    : null,
              ),
              SizedBox(height: 14),
              _buildField(
                _descCtrl,
                l.t('promotions_description_required'),
                Icons.description,
                maxLines: 4,
                hint: l.t('promotions_describe_hint'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.t('promotions_description_required_error')
                    : null,
              ),
              SizedBox(height: 24),

              _sectionTitle(
                l.t('promotions_location_and_contact'),
                Icons.contact_phone,
              ),
              SizedBox(height: 12),
              _buildField(
                _locationCtrl,
                l.t('promotions_address_location_required'),
                Icons.location_on,
                hint: l.t('promotions_address_hint'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.t('promotions_address_required_error')
                    : null,
              ),
              SizedBox(height: 14),
              _buildField(
                _contactCtrl,
                l.t('promotions_contact_phone_email'),
                Icons.phone,
                hint: l.t('promotions_phone_hint'),
              ),
              SizedBox(height: 32),

              // Boton
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.publish, color: Colors.white),
                  label: Text(
                    _isLoading
                        ? l.t('promotions_publishing')
                        : l.t('promotions_publish_business'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.primary30,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: ColorTokens.primary30, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = context.read<UserProvider>().user?.name ?? l.t('user_default');
    final provider = context.read<PromotionsProvider>();

    final req = PromotionRequestModel(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: 'negocio',
      contact: _contactCtrl.text.trim().isNotEmpty
          ? _contactCtrl.text.trim()
          : null,
      location: _locationCtrl.text.trim().isNotEmpty
          ? _locationCtrl.text.trim()
          : null,
      ownerUid: uid,
      ownerName: name,
    );
    provider.addRequest(req);

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.t('promotions_business_published')),
        backgroundColor: ColorTokens.success40,
      ),
    );
    Navigator.pop(context);
  }
}

// =============================================================================
// FORMULARIO: Crear Evento
// =============================================================================
class _EventForm extends StatefulWidget {
  const _EventForm();
  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          l.t('promotions_create_event'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text(
                      l.t('promotions_new_event'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      l.t('promotions_create_event_subtitle'),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Info del evento
              _sectionTitle(l.t('promotions_event_info'), Icons.info_outline),
              SizedBox(height: 12),
              _field(
                _titleCtrl,
                l.t('promotions_event_name_required'),
                Icons.title,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.t('promotions_required')
                    : null,
              ),
              SizedBox(height: 14),
              _field(
                _descCtrl,
                l.t('promotions_event_description_required'),
                Icons.description,
                maxLines: 4,
                hint: l.t('promotions_event_describe_hint'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.t('promotions_required')
                    : null,
              ),
              SizedBox(height: 24),

              // Fecha y hora
              _sectionTitle(l.t('promotions_date_and_time'), Icons.schedule),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _datePicker(isDark)),
                  SizedBox(width: 12),
                  Expanded(child: _timePicker(isDark)),
                ],
              ),
              SizedBox(height: 24),

              // Ubicacion y cupos
              _sectionTitle(l.t('promotions_location_and_spots'), Icons.place),
              SizedBox(height: 12),
              _field(
                _locationCtrl,
                l.t('promotions_event_location_required'),
                Icons.location_on,
                hint: l.t('promotions_event_location_hint'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.t('promotions_required')
                    : null,
              ),
              SizedBox(height: 14),
              _field(
                _maxCtrl,
                l.t('promotions_max_spots_optional'),
                Icons.people,
                hint: l.t('promotions_unlimited_spots_hint'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 14),
              _field(_contactCtrl, l.t('promotions_contact_info'), Icons.phone),
              SizedBox(height: 32),

              // Boton
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.event_available, color: Colors.white),
                  label: Text(
                    _isLoading
                        ? l.t('promotions_creating')
                        : l.t('promotions_create_event'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6A1B9A), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
    );
  }

  Widget _datePicker(bool isDark) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (d != null) setState(() => _eventDate = d);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _eventDate != null
                ? const Color(0xFF6A1B9A)
                : Colors.grey.withValues(alpha: 0.4),
            width: _eventDate != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: _eventDate != null ? const Color(0xFF6A1B9A) : Colors.grey,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _eventDate != null
                    ? DateFormat('dd MMM yyyy', 'es').format(_eventDate!)
                    : l.t('promotions_date_required'),
                style: TextStyle(
                  color: _eventDate != null ? null : Colors.grey[600],
                  fontWeight: _eventDate != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePicker(bool isDark) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
        );
        if (t != null) setState(() => _eventTime = t);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _eventTime != null
                ? const Color(0xFF6A1B9A)
                : Colors.grey.withValues(alpha: 0.4),
            width: _eventTime != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: _eventTime != null ? const Color(0xFF6A1B9A) : Colors.grey,
            ),
            SizedBox(width: 8),
            Text(
              _eventTime != null
                  ? _eventTime!.format(context)
                  : l.t('promotions_time_required'),
              style: TextStyle(
                color: _eventTime != null ? null : Colors.grey[600],
                fontWeight: _eventTime != null
                    ? FontWeight.w500
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    if (_eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('promotions_select_event_date')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }
    if (_eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.t('promotions_select_event_time')),
          backgroundColor: ColorTokens.error50,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = context.read<UserProvider>().user?.name ?? l.t('user_default');
    final provider = context.read<PromotionsProvider>();

    int? maxAtt;
    if (_maxCtrl.text.trim().isNotEmpty)
      maxAtt = int.tryParse(_maxCtrl.text.trim());

    final req = PromotionRequestModel(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: 'evento',
      contact: _contactCtrl.text.trim().isNotEmpty
          ? _contactCtrl.text.trim()
          : null,
      location: _locationCtrl.text.trim().isNotEmpty
          ? _locationCtrl.text.trim()
          : null,
      eventDate: _eventDate,
      eventTime: _eventTime!.format(context),
      maxAttendees: maxAtt,
      ownerUid: uid,
      ownerName: name,
    );
    provider.addRequest(req);

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.t('promotions_event_created')),
        backgroundColor: ColorTokens.success40,
      ),
    );
    Navigator.pop(context);
  }
}

// =============================================================================
// TAB: Negocios
// =============================================================================
class _BusinessTab extends StatelessWidget {
  const _BusinessTab();

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Consumer<PromotionsProvider>(
      builder: (context, provider, _) {
        final items = provider.approvedBusinesses;
        if (items.isEmpty) {
          return _EmptyState(
            icon: Icons.storefront,
            title: l.t('promotions_no_businesses'),
            subtitle: l.t('promotions_no_businesses_subtitle'),
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) => _BusinessCard(business: items[i]),
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
          // Header gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorTokens.primary30,
                  ColorTokens.primary30.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            business.ownerName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
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

// =============================================================================
// TAB: Eventos
// =============================================================================
class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Consumer<PromotionsProvider>(
      builder: (context, provider, _) {
        final items = provider.approvedEvents;
        if (items.isEmpty) {
          return _EmptyState(
            icon: Icons.event,
            title: l.t('promotions_no_events'),
            subtitle: l.t('promotions_no_events_subtitle'),
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) => _EventCard(event: items[i]),
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
    final l = Provider.of<LocaleNotifier>(context, listen: false);
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
          // Header gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                if (event.eventDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd').format(event.eventDate!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMM',
                            'es',
                          ).format(event.eventDate!).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.ownerName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                if (event.eventTime != null)
                  _infoRow(Icons.access_time, event.eventTime!, Colors.blue),
                if (event.location != null && event.location!.isNotEmpty)
                  _infoRow(Icons.location_on, event.location!, Colors.red),
                if (event.contact != null && event.contact!.isNotEmpty)
                  _infoRow(Icons.phone, event.contact!, Colors.green),
                SizedBox(height: 12),
                // Asistentes
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 20, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        '${event.attendees.length} ${l.t('promotions_registered_count')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.maxAttendees != null)
                        Text(
                          ' / ${event.maxAttendees} ${l.t('promotions_spots')}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      Spacer(),
                      if (isFull && !isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l.t('promotions_full'),
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                l.t('promotions_enrolled'),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (event.maxAttendees != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (event.attendees.length / event.maxAttendees!)
                          .clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFull ? Colors.red : const Color(0xFF6A1B9A),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Boton registro
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (isFull && !isRegistered)
                        ? null
                        : () async {
                            final prov = context.read<PromotionsProvider>();
                            bool ok;
                            if (isRegistered) {
                              ok = await prov.unregisterFromEvent(
                                event.id,
                                uid,
                              );
                            } else {
                              ok = await prov.registerToEvent(event.id, uid);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isRegistered
                                        ? (ok
                                              ? l.t(
                                                  'promotions_registration_cancelled',
                                                )
                                              : l.t('promotions_cancel_error'))
                                        : (ok
                                              ? l.t(
                                                  'promotions_registered_successfully',
                                                )
                                              : l.t(
                                                  'promotions_register_error',
                                                )),
                                  ),
                                  backgroundColor: ok
                                      ? ColorTokens.success40
                                      : ColorTokens.error50,
                                ),
                              );
                            }
                          },
                    icon: Icon(
                      isRegistered ? Icons.cancel : Icons.how_to_reg,
                      color: Colors.white,
                    ),
                    label: Text(
                      isRegistered
                          ? l.t('promotions_cancel_registration')
                          : l.t('promotions_register_to_event'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered
                          ? ColorTokens.error50
                          : const Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 1,
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

// =============================================================================
// Empty State
// =============================================================================
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.grey[350]),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Panel Admin (pantalla completa)
// =============================================================================
class _AdminPanelScreen extends StatelessWidget {
  const _AdminPanelScreen();

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('promotions_admin_panel_title'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ColorTokens.primary30,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<PromotionsProvider>(
        builder: (context, provider, _) {
          final pending = provider.pendingRequests;
          return Column(
            children: [
              // Stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: ColorTokens.primary30.withValues(alpha: 0.04),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat(
                      l.t('promotions_pending'),
                      '${pending.length}',
                      Colors.orange,
                    ),
                    _stat(
                      l.t('promotions_businesses'),
                      '${provider.approvedBusinesses.length}',
                      Colors.green,
                    ),
                    _stat(
                      l.t('promotions_events'),
                      '${provider.approvedEvents.length}',
                      Color(0xFF6A1B9A),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: pending.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green[300],
                            ),
                            SizedBox(height: 12),
                            Text(
                              l.t('promotions_all_up_to_date'),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              l.t('promotions_no_pending_requests'),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pending.length,
                        itemBuilder: (_, i) => _AdminCard(req: pending[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  final PromotionRequestModel req;
  const _AdminCard({required this.req});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
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
                  child: Text(
                    req.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    req.type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              req.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${l.t('promotions_by')}: ${req.ownerName}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            if (req.location != null && req.location!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      req.location!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final provider = context.read<PromotionsProvider>();
                    await provider.reject(req.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.t('promotions_request_rejected')),
                          backgroundColor: ColorTokens.error50,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.close, size: 18),
                  label: Text(l.t('promotions_reject')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorTokens.error50,
                    side: const BorderSide(color: ColorTokens.error50),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final provider = context.read<PromotionsProvider>();
                    await provider.approve(req.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.t('promotions_request_approved')),
                          backgroundColor: ColorTokens.success40,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.check, size: 18, color: Colors.white),
                  label: Text(
                    l.t('promotions_approve'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTokens.success40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
