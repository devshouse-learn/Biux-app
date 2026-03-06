import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:biux/core/design_system/locale_notifier.dart';
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
  String _statusKey = 'ready_to_migrate';
  String? _errorDetail;

  Future<void> _migrateAll() async {
    setState(() {
      _isMigrating = true;
      _statusKey = 'migrating_rides';
      _errorDetail = null;
    });

    try {
      await _adapter.migrateAllRides();
      setState(() {
        _statusKey = 'migration_success';
        _isMigrating = false;
      });
    } catch (e) {
      setState(() {
        _statusKey = 'migration_error';
        _errorDetail = e.toString();
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LocaleNotifier>(context, listen: false);
    final statusText = _errorDetail != null
        ? '${l.t(_statusKey)}: $_errorDetail'
        : l.t(_statusKey);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.t('migration_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('migration_description'),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              statusText,
              style: TextStyle(
                color: _statusKey == 'migration_success'
                    ? Colors.green
                    : _statusKey == 'migration_error'
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
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(l.t('migrating')),
                        ],
                      )
                    : Text(l.t('start_migration')),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('run_once_warning'),
              style: const TextStyle(
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
