import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/features/shop/domain/usecases/stolen_bike_verification_service.dart';
import 'package:biux/features/bikes/data/repositories/bike_repository_impl.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Pantalla pública para consultar bicicletas reportadas como robadas
class StolenBikesScreen extends StatefulWidget {
  const StolenBikesScreen({Key? key}) : super(key: key);

  @override
  State<StolenBikesScreen> createState() => _StolenBikesScreenState();
}

class _StolenBikesScreenState extends State<StolenBikesScreen> {
  late StolenBikeVerificationService _verificationService;
  List<StolenBikeInfo> _stolenBikes = [];
  bool _isLoading = true;
  String _searchQuery = '';
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
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final bikeRepo = BikeRepositoryImpl();
    _verificationService = StolenBikeVerificationService(
      bikeRepository: bikeRepo,
    );
    await _loadStolenBikes();
  }

  Future<void> _loadStolenBikes() async {
    setState(() => _isLoading = true);

    try {
      final bikes = await _verificationService.getAllStolenBikes();
      setState(() {
        _stolenBikes = bikes;
        _isLoading = false;
      });
      print('✅ Cargadas ${bikes.length} bicicletas robadas');
    } catch (e) {
      print('❌ Error cargando bicicletas robadas: $e');
      setState(() => _isLoading = false);
    }
  }

  List<StolenBikeInfo> get _filteredBikes {
    var filtered = _stolenBikes;

    // Filtrar por ciudad
    if (_selectedCity != 'Todas') {
      filtered = filtered
          .where(
            (info) =>
                info.bike.city.toLowerCase() == _selectedCity.toLowerCase(),
          )
          .toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((info) {
        return info.bike.brand.toLowerCase().contains(query) ||
            info.bike.model.toLowerCase().contains(query) ||
            info.bike.color.toLowerCase().contains(query) ||
            info.bike.frameSerial.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bicicletas Reportadas como Robadas'),
        backgroundColor: ColorTokens.error50,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header con información
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorTokens.error50, ColorTokens.error40],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Base de Datos de Bicicletas Robadas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Consulta pública para prevenir la compra de bicicletas robadas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '${_stolenBikes.length} bicicletas reportadas',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para reportar una bicicleta
                  },
                  icon: Icon(Icons.report, color: Colors.white),
                  label: Text('Reportar una bicicleta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda y filtros
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText:
                        'Buscar por marca, modelo, color o número de serie...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: ColorTokens.primary50,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorTokens.neutral30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorTokens.neutral30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ColorTokens.primary50,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: ColorTokens.neutral10,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                SizedBox(height: 12),

                // Filtro por ciudad
                Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      color: ColorTokens.primary50,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ciudad:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColorTokens.neutral80,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _cities.map((city) {
                            final isSelected = city == _selectedCity;
                            return Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(city),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() => _selectedCity = city);
                                },
                                selectedColor: ColorTokens.primary50,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : ColorTokens.neutral80,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de bicicletas robadas
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: ColorTokens.error50),
                        SizedBox(height: 16),
                        Text(
                          'Cargando base de datos...',
                          style: TextStyle(color: ColorTokens.neutral60),
                        ),
                      ],
                    ),
                  )
                : _filteredBikes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: ColorTokens.neutral40,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _selectedCity == 'Todas'
                              ? 'No hay bicicletas reportadas como robadas'
                              : 'No se encontraron resultados',
                          style: TextStyle(
                            color: ColorTokens.neutral60,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadStolenBikes,
                    color: ColorTokens.error50,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _filteredBikes.length,
                      itemBuilder: (context, index) {
                        return _buildStolenBikeCard(_filteredBikes[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),

      // Botón flotante para reportar
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a pantalla de reporte
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Reportar Bicicleta Robada'),
              content: Text(
                'Para reportar una bicicleta como robada, primero debes registrarla en tu perfil de Biux.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Entendido'),
                ),
              ],
            ),
          );
        },
        backgroundColor: ColorTokens.error50,
        icon: Icon(Icons.report),
        label: Text('Reportar Robo'),
      ),
    );
  }

  Widget _buildStolenBikeCard(StolenBikeInfo info) {
    final bike = info.bike;
    final theft = info.theftReport;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorTokens.error50, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de alerta
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: ColorTokens.error50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'BICICLETA REPORTADA COMO ROBADA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de la bicicleta
                  if (bike.mainPhoto.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: bike.mainPhoto,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: ColorTokens.neutral20,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: ColorTokens.neutral20,
                          child: Icon(
                            Icons.pedal_bike,
                            size: 64,
                            color: ColorTokens.neutral60,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 16),

                  // Información de la bicicleta
                  Text(
                    '${bike.brand} ${bike.model}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.neutral90,
                    ),
                  ),

                  SizedBox(height: 12),

                  _buildInfoRow(
                    Icons.fingerprint,
                    'Número de Serie',
                    bike.frameSerial,
                  ),
                  _buildInfoRow(Icons.palette, 'Color', bike.color),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Año',
                    bike.year.toString(),
                  ),
                  _buildInfoRow(Icons.location_on, 'Ciudad', bike.city),

                  Divider(height: 24, thickness: 1),

                  // Información del robo
                  Text(
                    'Detalles del Robo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorTokens.error50,
                    ),
                  ),

                  SizedBox(height: 12),

                  _buildInfoRow(
                    Icons.event,
                    'Fecha del Robo',
                    '${theft.theftDate.day}/${theft.theftDate.month}/${theft.theftDate.year}',
                  ),
                  _buildInfoRow(Icons.place, 'Lugar del Robo', theft.location),
                  if (theft.policeReportNumber != null)
                    _buildInfoRow(
                      Icons.policy,
                      'Denuncia Policial',
                      theft.policeReportNumber!,
                    ),

                  SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorTokens.warning50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorTokens.warning50),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: ColorTokens.warning50,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Descripción del Incidente',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ColorTokens.warning50,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          theft.description,
                          style: TextStyle(color: ColorTokens.neutral80),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Advertencia
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorTokens.error50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorTokens.error50),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.block, color: ColorTokens.error50, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'NO compres esta bicicleta. Contacta a las autoridades si la encuentras.',
                            style: TextStyle(
                              color: ColorTokens.error50,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorTokens.primary50),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorTokens.neutral70,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: ColorTokens.neutral80)),
          ),
        ],
      ),
    );
  }
}
