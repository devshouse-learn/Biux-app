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
          tabs: [
            Tab(text: '🛡️ ${l.t('safety')}'),
            Tab(text: '🔧 ${l.t('mechanics')}'),
            Tab(text: '📜 ${l.t('regulations')}'),
            Tab(text: '🏋️ ${l.t('training')}'),
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
          title: l.t('edu_helmet_use'),
          description: l.t('edu_helmet_desc'),
          lessons: [
            l.t('edu_helmet_types'),
            l.t('edu_correct_fit'),
            l.t('when_to_replace'),
            l.t('edu_certifications'),
          ],
          color: Colors.blue,
        ),
        _courseCard(
          emoji: '💡',
          title: l.t('edu_visibility'),
          description: l.t('edu_visibility_desc'),
          lessons: [
            l.t('edu_front_rear_lights'),
            l.t('edu_reflective_clothing'),
            l.t('hand_signals'),
            l.t('edu_night_riding'),
          ],
          color: Colors.amber,
        ),
        _courseCard(
          emoji: '🚗',
          title: l.t('edu_coexistence_vehicles'),
          description: l.t('ride_safe_traffic'),
          lessons: [
            l.t('road_position'),
            l.t('edu_blind_spots'),
            l.t('edu_intersections'),
            l.t('edu_roundabouts'),
          ],
          color: Colors.red,
        ),
        _courseCard(
          emoji: '🌧️',
          title: l.t('edu_adverse_conditions'),
          description: l.t('rain_wind_surfaces'),
          lessons: [
            l.t('edu_wet_braking'),
            l.t('edu_hydroplaning'),
            l.t('edu_crosswind'),
            l.t('edu_reduced_visibility'),
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
          title: l.t('edu_basic_maintenance'),
          description: l.t('edu_maintenance_desc'),
          lessons: [
            l.t('chain_lubrication'),
            l.t('edu_brake_adjustment'),
            l.t('edu_tire_inflation'),
            l.t('edu_general_cleaning'),
          ],
          color: Colors.grey,
        ),
        _courseCard(
          emoji: '🛞',
          title: l.t('flat_repair'),
          description: l.t('edu_flat_desc'),
          lessons: [
            l.t('edu_repair_kit'),
            l.t('edu_remove_tire'),
            l.t('edu_patch_tube'),
            l.t('edu_remount'),
          ],
          color: Colors.brown,
        ),
        _courseCard(
          emoji: '⚙️',
          title: l.t('edu_gear_adjustment'),
          description: l.t('keep_gears_smooth'),
          lessons: [
            l.t('edu_cables_tension'),
            l.t('edu_rear_derailleur'),
            l.t('edu_front_derailleur'),
            l.t('indexing'),
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
          l.t('national_traffic_code'),
          l.t('edu_law_769'),
          l.t('cyclist_articles'),
          [
            '✅ ${l.t('edu_law_bike_lanes')}',
            '✅ ${l.t('edu_law_helmet_highways')}',
            '✅ ${l.t('edu_law_lights_night')}',
            '✅ ${l.t('edu_law_no_passenger')}',
            '✅ ${l.t('edu_law_hand_signals')}',
            '❌ ${l.t('edu_law_no_sidewalks')}',
            '❌ ${l.t('edu_law_no_holding_vehicles')}',
          ],
        ),
        _infoCard(
          '🚲',
          l.t('edu_pro_bike_law'),
          l.t('edu_law_1811'),
          l.t('edu_bike_incentives'),
          [
            '✅ ${l.t('edu_bike_day')}',
            '✅ ${l.t('edu_mandatory_parking')}',
            '✅ ${l.t('edu_half_day_off')}',
            '✅ ${l.t('edu_employer_parking')}',
          ],
        ),
        _infoCard(
          '🛡️',
          l.t('edu_cyclist_rights'),
          l.t('edu_know_them'),
          l.t('edu_your_rights_road'),
          [
            '✅ ${l.t('edu_right_safe_space')}',
            '✅ ${l.t('edu_right_priority')}',
            '✅ ${l.t('edu_right_accident_care')}',
            '✅ ${l.t('edu_right_main_roads')}',
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
          title: l.t('edu_beginner_plan'),
          description: l.t('edu_beginner_desc'),
          lessons: [
            '${l.t('edu_week')} 1: 15 km',
            '${l.t('edu_week')} 2: 25 km',
            '${l.t('edu_week')} 3: 35 km',
            '${l.t('edu_week')} 4: 50 km',
          ],
          color: Colors.green,
        ),
        _courseCard(
          emoji: '🥗',
          title: l.t('edu_nutrition'),
          description: l.t('edu_nutrition_desc'),
          lessons: [
            l.t('edu_pre_ride_carbs'),
            l.t('edu_hydration_during'),
            l.t('edu_post_ride_recovery'),
            l.t('edu_supplements'),
          ],
          color: Colors.orange,
        ),
        _courseCard(
          emoji: '🏔️',
          title: l.t('edu_mountain_technique'),
          description: l.t('edu_mountain_desc'),
          lessons: [
            l.t('edu_climbing_cadence'),
            l.t('edu_body_position'),
            l.t('edu_descent_braking'),
            l.t('edu_tight_curves'),
          ],
          color: Colors.purple,
        ),
        _courseCard(
          emoji: '🧘',
          title: l.t('edu_injury_prevention'),
          description: l.t('edu_injury_desc'),
          lessons: [
            l.t('edu_warmup'),
            l.t('edu_correct_posture'),
            l.t('edu_post_ride_stretching'),
            l.t('edu_knee_pain'),
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
