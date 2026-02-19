import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Centro de Seguridad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.directions_bike), text: 'Mis Bicis'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Alertas'),
            Tab(icon: Icon(Icons.info_outline), text: 'Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMyBikesTab(), _buildAlertsTab(), _buildInfoTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRegisterBikeDialog,
        backgroundColor: _kPrimaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registrar Bici'),
      ),
    );
  }

  Widget _buildMyBikesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Registra tu Bicicleta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Protege tu bicicleta registrándola con su número de serie, '
              'fotos y código QR único. En caso de robo, la comunidad Biux '
              'te ayudará a recuperarla.',
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
              'Código QR Único',
              'Genera un QR verificable vinculado a tu bici',
            ),
            _buildFeatureCard(
              Icons.camera_alt,
              'Registro Fotográfico',
              'Sube fotos de tu bicicleta como evidencia',
            ),
            _buildFeatureCard(
              Icons.notifications_active,
              'Alertas Comunitarias',
              'La comunidad te avisa si ven tu bici reportada',
            ),
            _buildFeatureCard(
              Icons.shield,
              'Verificación de Propiedad',
              'Demuestra que eres dueño con tu registro digital',
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

  Widget _buildAlertsTab() {
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
              'Sin alertas activas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí aparecerán las alertas de bicis robadas en tu zona. '
              'La comunidad Biux está comprometida con la seguridad.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Primero registra tu bici en "Mis Bicis"'),
                  ),
                );
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.report),
              label: const Text('Reportar Bici Robada'),
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

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            '🔒 ¿Cómo funciona el sistema anti-robo?',
            'Biux te permite registrar tu bicicleta con fotos, número de serie '
                'y un código QR único. Si tu bici es robada, puedes reportarla '
                'y toda la comunidad recibirá una alerta.',
          ),
          _buildInfoSection(
            '📱 Verificación QR',
            'Cualquier persona puede escanear el QR de una bicicleta para verificar '
                'si está registrada y si ha sido reportada como robada.',
          ),
          _buildInfoSection(
            '🤝 Comunidad Segura',
            'Al comprar una bici usada en Biux, puedes verificar que no esté '
                'reportada como robada.',
          ),
          _buildInfoSection(
            '📋 Consejos de Seguridad',
            '• Usa siempre un candado tipo U-lock\n'
                '• Registra el número de serie de tu cuadro\n'
                '• Toma fotos detalladas de tu bicicleta\n'
                '• Guarda tu factura de compra\n'
                '• Usa luces y reflectantes\n'
                '• No dejes tu bici sin supervisión en zonas inseguras\n'
                '• Reporta inmediatamente si tu bici es robada',
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
                const Text(
                  'Registrar Bicicleta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      'Marca *',
                      'Ej: Trek, Specialized...',
                      Icons.branding_watermark,
                      required: true,
                    ),
                    _buildTextField(
                      _modelController,
                      'Modelo *',
                      'Ej: Domane SL 6...',
                      Icons.two_wheeler,
                      required: true,
                    ),
                    _buildTextField(
                      _serialController,
                      'Número de Serie',
                      'Debajo del eje de pedalier',
                      Icons.numbers,
                    ),
                    _buildTextField(
                      _colorController,
                      'Color',
                      'Ej: Negro mate',
                      Icons.color_lens,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Agregar Fotos'),
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
                      label: const Text(
                        'Registrar Bicicleta',
                        style: TextStyle(fontSize: 16),
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
            ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null
            : null,
      ),
    );
  }

  void _saveBike() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Bicicleta registrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
