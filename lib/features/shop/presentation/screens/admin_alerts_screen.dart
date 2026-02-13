import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:intl/intl.dart';

/// Pantalla del dashboard de alertas para administradores
/// Muestra intentos de venta de bicicletas robadas
class AdminAlertsScreen extends StatefulWidget {
  const AdminAlertsScreen({super.key});

  @override
  State<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends State<AdminAlertsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCity = 'Todas';
  final List<String> _cities = [
    'Todas',
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.error50,
        foregroundColor: ColorTokens.neutral100,
        title: const Text('Dashboard de Alertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar reporte',
            onPressed: _exportReport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilterSection(),

          // Estadísticas rápidas
          _buildStatsSection(),

          // Lista de alertas
          Expanded(child: _buildAlertsList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: ColorTokens.neutral99,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: ColorTokens.neutral30,
            ),
          ),
          const SizedBox(height: 12),

          // Filtro por ciudad
          Row(
            children: [
              const Icon(Icons.location_city, size: 20),
              const SizedBox(width: 8),
              Text('Ciudad:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cities.map((city) {
                      final isSelected = _selectedCity == city;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(city),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCity = city);
                          },
                          backgroundColor: ColorTokens.neutral95,
                          selectedColor: ColorTokens.primary80,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Filtro por fecha
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    _startDate == null
                        ? 'Todas las fechas'
                        : '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Hoy'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  onPressed: _selectDateRange,
                ),
              ),
              if (_startDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => setState(() {
                    _startDate = null;
                    _endDate = null;
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAlertsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final alerts = snapshot.data!.docs;
        final totalAlerts = alerts.length;
        final todayAlerts = alerts.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['timestamp'] as Timestamp?;
          if (timestamp == null) return false;
          final date = timestamp.toDate();
          final now = DateTime.now();
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).length;

        final uniqueSellers = alerts
            .map((doc) => (doc.data() as Map<String, dynamic>)['sellerUid'])
            .toSet()
            .length;

        return Container(
          padding: const EdgeInsets.all(16),
          color: ColorTokens.error99,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                icon: Icons.warning,
                label: 'Total Alertas',
                value: totalAlerts.toString(),
                color: ColorTokens.error50,
              ),
              _buildStatCard(
                icon: Icons.today,
                label: 'Hoy',
                value: todayAlerts.toString(),
                color: ColorTokens.primary40,
              ),
              _buildStatCard(
                icon: Icons.people,
                label: 'Vendedores',
                value: uniqueSellers.toString(),
                color: ColorTokens.secondary50,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: ColorTokens.neutral60),
        ),
      ],
    );
  }

  Widget _buildAlertsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAlertsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: ColorTokens.error50),
                const SizedBox(height: 16),
                Text('Error al cargar alertas: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = snapshot.data!.docs;

        if (alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: ColorTokens.success40,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay alertas de robos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: ColorTokens.neutral50,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los intentos de venta de bicicletas robadas aparecerán aquí',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ColorTokens.neutral60),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alertDoc = alerts[index];
              final data = alertDoc.data() as Map<String, dynamic>;
              return _buildAlertCard(alertDoc.id, data);
            },
          ),
        );
      },
    );
  }

  Widget _buildAlertCard(String alertId, Map<String, dynamic> data) {
    final timestamp = data['timestamp'] as Timestamp?;
    final dateStr = timestamp != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate())
        : 'Fecha desconocida';

    final bikeData = data['bikeData'] as Map<String, dynamic>?;
    final sellerName = data['sellerName'] ?? 'Vendedor desconocido';
    final sellerUid = data['sellerUid'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ColorTokens.error50, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con alerta roja
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorTokens.error50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.dangerous,
                  color: ColorTokens.neutral100,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ INTENTO DE VENTA DE BICICLETA ROBADA',
                    style: const TextStyle(
                      color: ColorTokens.neutral100,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha y hora
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Información del vendedor
                Text(
                  'Información del Vendedor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: ColorTokens.neutral30,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person, 'Nombre', sellerName),
                _buildInfoRow(Icons.fingerprint, 'UID', sellerUid),

                const Divider(height: 24),

                // Información de la bicicleta
                Text(
                  'Información de la Bicicleta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: ColorTokens.neutral30,
                  ),
                ),
                const SizedBox(height: 8),
                if (bikeData != null) ...[
                  _buildInfoRow(
                    Icons.badge,
                    'Número de Serie',
                    bikeData['frameSerial'] ?? 'No especificado',
                  ),
                  _buildInfoRow(
                    Icons.branding_watermark,
                    'Marca',
                    bikeData['brand'] ?? 'No especificada',
                  ),
                  _buildInfoRow(
                    Icons.directions_bike,
                    'Modelo',
                    bikeData['model'] ?? 'No especificado',
                  ),
                  _buildInfoRow(
                    Icons.color_lens,
                    'Color',
                    bikeData['color'] ?? 'No especificado',
                  ),
                  if (bikeData['year'] != null)
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Año',
                      bikeData['year'].toString(),
                    ),
                  if (bikeData['city'] != null)
                    _buildInfoRow(
                      Icons.location_city,
                      'Ciudad',
                      bikeData['city'],
                    ),
                ],

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Ver Detalles'),
                        onPressed: () => _showAlertDetails(alertId, data),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Bloquear Vendedor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTokens.error50,
                          foregroundColor: ColorTokens.neutral100,
                        ),
                        onPressed: () => _blockSeller(sellerUid, sellerName),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: ColorTokens.neutral60),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getAlertsStream() {
    Query query = FirebaseFirestore.instance
        .collection('theft_alerts')
        .orderBy('timestamp', descending: true);

    // Filtro por ciudad
    if (_selectedCity != 'Todas') {
      query = query.where('bikeData.city', isEqualTo: _selectedCity);
    }

    // Filtro por fecha
    if (_startDate != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
      );
    }
    if (_endDate != null) {
      final endOfDay = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
      );
    }

    return query.limit(100).snapshots();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorTokens.primary40,
              onPrimary: ColorTokens.neutral100,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showAlertDetails(String alertId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: ColorTokens.primary40),
            const SizedBox(width: 8),
            const Text('Detalles de la Alerta'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID de Alerta: $alertId',
                style: const TextStyle(fontSize: 12),
              ),
              const Divider(),
              Text(
                'Metadata completa:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                data.toString(),
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAlert(alertId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
            ),
            child: const Text('Eliminar Alerta'),
          ),
        ],
      ),
    );
  }

  Future<void> _blockSeller(String sellerUid, String sellerName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar bloqueo'),
        content: Text(
          '¿Deseas bloquear al usuario $sellerName?\n\n'
          'Esta acción impedirá que pueda crear productos en la tienda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTokens.error50,
            ),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerUid)
          .update({
            'canCreateProducts': false,
            'blockedReason': 'Intento de venta de bicicleta robada',
            'blockedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario $sellerName bloqueado correctamente'),
            backgroundColor: ColorTokens.success40,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al bloquear usuario: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }

  Future<void> _deleteAlert(String alertId) async {
    try {
      await FirebaseFirestore.instance
          .collection('theft_alerts')
          .doc(alertId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta eliminada'),
            backgroundColor: ColorTokens.success40,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: ColorTokens.error50,
          ),
        );
      }
    }
  }

  Future<void> _exportReport() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 16),
            Text('Exportando reporte...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // TODO: Implementar exportación a PDF/CSV
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidad de exportación próximamente'),
          backgroundColor: ColorTokens.primary40,
        ),
      );
    }
  }
}
