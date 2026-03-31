import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

const _kPrimaryColor = Color(0xFF16242D);

/// Centro de seguridad - registro de bicis y alertas anti-robo
class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l.t('security_center'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
              icon: const Icon(Icons.directions_bike),
              text: l.t('my_bikes_tab'),
            ),
            Tab(icon: const Icon(Icons.warning_amber), text: l.t('alerts_tab')),
            Tab(icon: const Icon(Icons.info_outline), text: l.t('info_tab')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMyBikesTab(l), _buildAlertsTab(l), _buildInfoTab(l)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRegisterBikeDialog,
        backgroundColor: _kPrimaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l.t('register_bike')),
      ),
    );
  }

  Widget _buildMyBikesTab(LocaleNotifier l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l.t('register_your_bike'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('register_your_bike_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildFeatureCard(
              Icons.qr_code,
              l.t('unique_qr_code'),
              l.t('unique_qr_desc'),
            ),
            _buildFeatureCard(
              Icons.camera_alt,
              l.t('photo_record'),
              l.t('photo_record_desc'),
            ),
            _buildFeatureCard(
              Icons.notifications_active,
              l.t('community_alerts'),
              l.t('community_alerts_desc'),
            ),
            _buildFeatureCard(
              Icons.shield,
              l.t('ownership_verification'),
              l.t('ownership_verification_desc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kPrimaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(LocaleNotifier l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              l.t('no_active_alerts'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('no_active_alerts_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.t('register_bike_first'))),
                );
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.report),
              label: Text(l.t('report_stolen_bike_btn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(LocaleNotifier l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            '🔒 ${l.t('anti_theft_info_title')}',
            l.t('anti_theft_info_desc'),
          ),
          _buildInfoSection(
            '📱 ${l.t('qr_verification_title')}',
            l.t('qr_verification_desc'),
          ),
          _buildInfoSection(
            '🤝 ${l.t('safe_community_title')}',
            l.t('safe_community_desc'),
          ),
          _buildInfoSection(
            '📋 ${l.t('safety_tips_title')}',
            l.t('safety_tips_content'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterBikeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _RegisterBikeForm(),
    );
  }
}

class _RegisterBikeForm extends StatefulWidget {
  const _RegisterBikeForm();

  @override
  State<_RegisterBikeForm> createState() => _RegisterBikeFormState();
}

class _RegisterBikeFormState extends State<_RegisterBikeForm> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.directions_bike, color: _kPrimaryColor),
                const SizedBox(width: 8),
                Text(
                  l.t('register_bike_form'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      _brandController,
                      '${l.t('brand_label')} *',
                      l.t('brand_required_hint'),
                      Icons.branding_watermark,
                      required: true,
                      l: l,
                    ),
                    _buildTextField(
                      _modelController,
                      '${l.t('model_label')} *',
                      l.t('model_required_hint'),
                      Icons.two_wheeler,
                      required: true,
                      l: l,
                    ),
                    _buildTextField(
                      _serialController,
                      l.t('serial_number_label'),
                      l.t('serial_number_hint'),
                      Icons.numbers,
                      l: l,
                    ),
                    _buildTextField(
                      _colorController,
                      l.t('color_label'),
                      l.t('color_hint'),
                      Icons.color_lens,
                      l: l,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt),
                      label: Text(l.t('add_photos_btn')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: _kPrimaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveBike,
                      icon: const Icon(Icons.save),
                      label: Text(
                        l.t('register_bike_form'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool required = false,
    LocaleNotifier? l,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: required
            ? (v) => (v == null || v.isEmpty)
                  ? (l?.t('field_required') ?? 'Campo requerido')
                  : null
            : null,
      ),
    );
  }

  void _saveBike() {
    if (_formKey.currentState?.validate() ?? false) {
      final l = Provider.of<LocaleNotifier>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${l.t('bike_registered_success')}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
