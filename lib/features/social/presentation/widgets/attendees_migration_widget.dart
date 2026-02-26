import 'package:flutter/material.dart';
import 'package:biux/features/social/data/datasources/attendees_firestore_adapter.dart';

/// Widget para gestionar la migración y sincronización de asistentes
///
/// USO:
/// 1. Agregar en una pantalla de admin o debug
/// 2. Ejecutar migración una sola vez
/// 3. La sincronización se activará automáticamente
class AttendeesMigrationWidget extends StatefulWidget {
  const AttendeesMigrationWidget({Key? key}) : super(key: key);

  @override
  _AttendeesMigrationWidgetState createState() =>
      _AttendeesMigrationWidgetState();
}

class _AttendeesMigrationWidgetState extends State<AttendeesMigrationWidget> {
  final _adapter = AttendeesFirestoreAdapter();
  bool _isMigrating = false;
  String _status = 'Listo para migrar';

  Future<void> _migrateAll() async {
    setState(() {
      _isMigrating = true;
      _status = 'Migrando rodadas...';
    });

    try {
      await _adapter.migrateAllRides();
      setState(() {
        _status = '✅ Migración completada exitosamente';
        _isMigrating = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Migración de Asistentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Migra los asistentes de Firestore a Realtime Database',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                color: _status.startsWith('✅')
                    ? Colors.green
                    : _status.startsWith('❌')
                    ? Colors.red
                    : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isMigrating ? null : _migrateAll,
                child: _isMigrating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Migrando...'),
                        ],
                      )
                    : const Text('Iniciar Migración'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ Solo ejecutar UNA vez',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
