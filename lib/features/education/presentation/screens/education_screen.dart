import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/color_tokens.dart';
import 'package:biux/core/design_system/locale_notifier.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: ColorTokens.neutral99,
      appBar: AppBar(
        title: Text(l.t('learn')),
        backgroundColor: ColorTokens.primary30,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sec(context, l.t('basic_maintenance'), Icons.build, Colors.orange, [
            _Art(l.t('lubricate_chain'), l.t('lubricate_chain_desc')),
            _Art(l.t('brake_inspection'), l.t('brake_inspection_desc')),
            _Art(l.t('tire_pressure'), l.t('tire_pressure_desc')),
            _Art(l.t('gear_adjustment'), l.t('gear_adjustment_desc')),
          ]),
          const SizedBox(height: 16),
          _sec(context, l.t('road_safety'), Icons.security, Colors.red, [
            _Art(l.t('basic_rules'), l.t('basic_rules_desc')),
            _Art(l.t('equipment'), l.t('equipment_desc')),
            _Art(l.t('in_case_of_accident'), l.t('accident_steps_desc')),
            _Art(l.t('night_cycling'), l.t('night_cycling_desc')),
          ]),
          const SizedBox(height: 16),
          _sec(context, l.t('nutrition'), Icons.restaurant, Colors.green, [
            _Art(l.t('hydration'), l.t('hydration_desc')),
            _Art(l.t('pre_ride'), l.t('pre_ride_desc')),
            _Art(l.t('post_ride'), l.t('post_ride_desc')),
          ]),
          const SizedBox(height: 16),
          _sec(context, l.t('beginner_routes'), Icons.map, Colors.blue, [
            _Art(l.t('first_route'), l.t('first_route_desc')),
            _Art(l.t('long_rides'), l.t('long_rides_desc')),
          ]),
        ],
      ),
    );
  }

  Widget _sec(
    BuildContext c,
    String t,
    IconData ic,
    Color col,
    List<_Art> arts,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: col.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(ic, color: col),
                const SizedBox(width: 12),
                Text(
                  t,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: col,
                  ),
                ),
              ],
            ),
          ),
          ...arts.map(
            (a) => ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(
                a.t,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                Text(
                  a.c,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Art {
  final String t, c;
  _Art(this.t, this.c);
}
