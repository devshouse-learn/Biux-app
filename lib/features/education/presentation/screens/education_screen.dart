import 'package:flutter/material.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
import 'package:provider/provider.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  LocaleNotifier get l => Provider.of<LocaleNotifier>(context);

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
        title: Text(l.t('road_education')),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: '🛡️ Seguridad'),
            Tab(text: '🔧 Mecánica'),
            Tab(text: '📜 Normativa'),
            Tab(text: '🏋️ Entrenamiento'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildSafetyTab(),
          _buildMechanicsTab(),
          _buildLawsTab(),
          _buildTrainingTab(),
        ],
      ),
    );
  }

  Widget _buildSafetyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _courseCard(
          emoji: '🪖',
          title: 'Uso correcto del casco',
          description:
              'Aprende cómo ajustar tu casco correctamente para máxima protección.',
          lessons: [
            'Tipos de casco',
            'Ajuste correcto',
            'Cuándo reemplazarlo',
            'Certificaciones',
          ],
          color: Colors.blue,
        ),
        _courseCard(
          emoji: '💡',
          title: 'Visibilidad en la vía',
          description:
              'Luces, reflectivos y colores para ser visible en todo momento.',
          lessons: [
            'Luces delanteras y traseras',
            'Ropa reflectiva',
            'Señalización manual',
            'Rodando de noche',
          ],
          color: Colors.amber,
        ),
        _courseCard(
          emoji: '🚗',
          title: 'Convivencia con vehículos',
          description: 'Técnicas para rodar seguro junto al tráfico vehicular.',
          lessons: [
            'Posición en la vía',
            'Puntos ciegos',
            'Intersecciones',
            'Rotondas',
          ],
          color: Colors.red,
        ),
        _courseCard(
          emoji: '🌧️',
          title: 'Ciclismo en condiciones adversas',
          description:
              'Cómo manejar lluvia, viento y superficies resbaladizas.',
          lessons: [
            'Frenado en mojado',
            'Hidroplaneo',
            'Viento lateral',
            'Visibilidad reducida',
          ],
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMechanicsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _courseCard(
          emoji: '🔧',
          title: 'Mantenimiento básico',
          description:
              'Todo lo que necesitas saber para mantener tu bici en perfecto estado.',
          lessons: [
            'Lubricación de cadena',
            'Ajuste de frenos',
            'Inflado de llantas',
            'Limpieza general',
          ],
          color: Colors.grey,
        ),
        _courseCard(
          emoji: '🛞',
          title: 'Reparación de pinchazos',
          description: 'Aprende a reparar un pinchazo en la vía rápidamente.',
          lessons: [
            'Kit de reparación',
            'Retirar la llanta',
            'Parchar el tubo',
            'Montar de nuevo',
          ],
          color: Colors.brown,
        ),
        _courseCard(
          emoji: '⚙️',
          title: 'Ajuste de cambios',
          description: 'Mantén tus cambios funcionando suavemente.',
          lessons: [
            'Cables y tensión',
            'Desviador trasero',
            'Desviador delantero',
            'Indexación',
          ],
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildLawsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(
          '📋',
          'Código Nacional de Tránsito',
          'Ley 769 de 2002',
          'Artículos relevantes para ciclistas en Colombia.',
          [
            '✅ Las bicicletas deben transitar por ciclorrutas',
            '✅ Obligatorio usar casco en autopistas',
            '✅ Luces obligatorias de noche',
            '✅ No se permite llevar acompañante (excepto menores en silla)',
            '✅ Señalizar con las manos antes de girar',
            '❌ Prohibido circular por andenes',
            '❌ Prohibido agarrarse de vehículos en movimiento',
          ],
        ),
        _infoCard(
          '🚲',
          'Ley Pro-Bicicleta',
          'Ley 1811 de 2016',
          'Incentivos para el uso de la bicicleta.',
          [
            '✅ Día de la bicicleta cada primer viernes del mes',
            '✅ Parqueaderos obligatorios en centros comerciales',
            '✅ Medio día libre por usar bici 30 días al trabajo',
            '✅ Los empleadores deben facilitar parqueo',
          ],
        ),
        _infoCard(
          '🛡️',
          'Derechos del ciclista',
          'Conócelos',
          'Tus derechos como ciclista en la vía.',
          [
            '✅ Derecho a un espacio seguro en la vía',
            '✅ Prioridad en intersecciones sin semáforo',
            '✅ Atención prioritaria en caso de accidente',
            '✅ Derecho a transitar por vías principales',
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _courseCard(
          emoji: '🏃',
          title: 'Plan para principiantes',
          description: 'Tu primer plan de entrenamiento para empezar a rodar.',
          lessons: [
            'Semana 1: 15 km',
            'Semana 2: 25 km',
            'Semana 3: 35 km',
            'Semana 4: 50 km',
          ],
          color: Colors.green,
        ),
        _courseCard(
          emoji: '🥗',
          title: 'Nutrición para ciclistas',
          description: 'Qué comer antes, durante y después de rodar.',
          lessons: [
            'Carbohidratos pre-rodada',
            'Hidratación durante',
            'Recuperación post-rodada',
            'Suplementos',
          ],
          color: Colors.orange,
        ),
        _courseCard(
          emoji: '🏔️',
          title: 'Técnica en montaña',
          description: 'Domina las subidas y bajadas como un pro.',
          lessons: [
            'Cadencia en subida',
            'Posición corporal',
            'Frenado en descenso',
            'Curvas cerradas',
          ],
          color: Colors.purple,
        ),
        _courseCard(
          emoji: '🧘',
          title: 'Prevención de lesiones',
          description: 'Ejercicios y estiramientos esenciales.',
          lessons: [
            'Calentamiento',
            'Postura correcta',
            'Estiramientos post-rodada',
            'Dolor de rodilla',
          ],
          color: Colors.pink,
        ),
      ],
    );
  }

  Widget _courseCard({
    required String emoji,
    required String title,
    required String description,
    required List<String> lessons,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 2,
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📚 Lecciones (${lessons.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...lessons.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 14),
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
      ),
    );
  }

  Widget _infoCard(
    String emoji,
    String title,
    String subtitle,
    String description,
    List<String> items,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(item, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
