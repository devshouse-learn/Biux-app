import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Widget de diagnóstico para Firebase Realtime Database
///
/// Agrega este widget en tu pantalla principal TEMPORALMENTE
/// para diagnosticar el problema de MissingPluginException
class FirebaseDatabaseDiagnostic extends StatefulWidget {
  const FirebaseDatabaseDiagnostic({Key? key}) : super(key: key);

  @override
  _FirebaseDatabaseDiagnosticState createState() =>
      _FirebaseDatabaseDiagnosticState();
}

class _FirebaseDatabaseDiagnosticState
    extends State<FirebaseDatabaseDiagnostic> {
  String _status = 'Sin probar';
  bool _isTesting = false;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _status = 'Probando conexión...';
    });

    try {
      // Test 1: Verificar instancia
      final database = FirebaseDatabase.instance;
      setState(() => _status = '✅ 1/5: Instancia creada');
      await Future.delayed(Duration(milliseconds: 500));

      // Test 2: Crear referencia
      final ref = database.ref('diagnostic_test');
      setState(() => _status = '✅ 2/5: Referencia creada');
      await Future.delayed(Duration(milliseconds: 500));

      // Test 3: Escribir dato
      await ref.set({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': 'Test desde Flutter',
      });
      setState(() => _status = '✅ 3/5: Escritura exitosa');
      await Future.delayed(Duration(milliseconds: 500));

      // Test 4: Leer dato
      final snapshot = await ref.get();
      final value = snapshot.value;
      setState(() => _status = '✅ 4/5: Lectura exitosa: $value');
      await Future.delayed(Duration(milliseconds: 500));

      // Test 5: Eliminar dato de prueba
      await ref.remove();
      setState(() => _status = '✅ 5/5: TODO FUNCIONANDO!');

      // Verificar autenticación
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(
          () => _status =
              '✅ COMPLETO: Firebase DB funciona! Usuario: ${user.uid}',
        );
      } else {
        setState(() => _status = '⚠️ DB funciona pero NO estás autenticado');
      }
    } catch (e) {
      setState(() => _status = '❌ ERROR: $e');

      // Diagnosticar tipo de error
      if (e.toString().contains('MissingPluginException')) {
        setState(() {
          _status = '''
❌ MissingPluginException detectado!

Soluciones:
1. REBUILD COMPLETO:
   flutter clean
   flutter pub get
   cd android && ./gradlew clean
   flutter run

2. NO usar hot reload (r)
3. NO usar hot restart (R)
4. Usar flutter run completo

5. Si sigue fallando:
   - Verifica google-services.json
   - Verifica que compile con JDK 11+
   - Verifica permisos en AndroidManifest
''';
        });
      } else if (e.toString().contains('permission')) {
        setState(() {
          _status = '''
❌ Error de permisos!

Soluciones:
1. Ve a Firebase Console
2. Realtime Database → Reglas
3. Cambia a:
   {
     "rules": {
       ".read": "auth != null",
       ".write": "auth != null"
     }
   }
4. Publica las reglas
''';
        });
      }
    } finally {
      setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Diagnóstico Firebase DB',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                fontSize: 14,
                color: _status.startsWith('❌')
                    ? Colors.red
                    : _status.startsWith('✅')
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isTesting ? 'Probando...' : 'Probar Conexión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '💡 Si aparece MissingPluginException, necesitas rebuild completo',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
