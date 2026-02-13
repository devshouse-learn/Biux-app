import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biux/shared/services/notification_service.dart';

/// Widget de debug para probar notificaciones
/// Agrégalo temporalmente en tu app para hacer pruebas
class NotificationDebugWidget extends StatefulWidget {
  const NotificationDebugWidget({Key? key}) : super(key: key);

  @override
  State<NotificationDebugWidget> createState() =>
      _NotificationDebugWidgetState();
}

class _NotificationDebugWidgetState extends State<NotificationDebugWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String _status = 'Listo para probar';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)} - $message',
      );
      if (_logs.length > 20) _logs.removeLast();
    });
    print(message);
  }

  Future<void> _checkConfiguration() async {
    setState(() {
      _isLoading = true;
      _status = 'Verificando configuración...';
      _logs.clear();
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _addLog('❌ No hay usuario autenticado');
        setState(() => _status = 'ERROR: No autenticado');
        return;
      }

      _addLog('👤 Usuario: $userId');

      // 1. Verificar tokens FCM
      final tokens = await _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .get();

      if (tokens.docs.isEmpty) {
        _addLog('❌ NO HAY TOKENS FCM');
        _addLog('→ Ejecutando reinitializeAfterLogin()...');
        await NotificationService().reinitializeAfterLogin();
        _addLog('✅ Tokens guardados');
      } else {
        _addLog('✅ ${tokens.docs.length} token(s) FCM encontrado(s)');
        for (var token in tokens.docs) {
          final data = token.data();
          _addLog(
            '   📱 ${data['platform']}: ${data['token']?.substring(0, 30)}...',
          );
        }
      }

      // 2. Verificar preferencias
      final prefs = await _firestore
          .doc('users/$userId/notificationSettings/preferences')
          .get();

      if (!prefs.exists) {
        _addLog('⚠️ NO HAY PREFERENCIAS');
      } else {
        _addLog('✅ Preferencias configuradas');
        final data = prefs.data() as Map<String, dynamic>;
        _addLog('   likes: ${data['likes']}');
        _addLog('   comments: ${data['comments']}');
        _addLog('   follows: ${data['follows']}');
      }

      setState(() => _status = 'Configuración OK');
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() => _status = 'ERROR');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestNotification(String type) async {
    setState(() {
      _isLoading = true;
      _status = 'Creando notificación...';
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _addLog('❌ No hay usuario autenticado');
        return;
      }

      _addLog('🔔 Creando notificación tipo: $type');

      final notificationData = {
        'type': type,
        'title': '🧪 Test $type',
        'body': 'Esta es una notificación de prueba de tipo $type',
        'senderId': 'test_sender_${DateTime.now().millisecondsSinceEpoch}',
        'relatedId': 'test_${type}_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      final ref = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notificationData);

      _addLog('✅ Notificación creada: ${ref.id}');
      _addLog('📍 Ruta: users/$userId/notifications/${ref.id}');
      _addLog('⏱️ Cloud Function debería ejecutarse ahora...');
      _addLog('💡 Verifica los logs con:');
      _addLog('   firebase functions:log --only onNotificationCreated');

      setState(() => _status = 'Notificación enviada');

      // Mostrar alerta de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Notificación creada. Espera 2-3 segundos...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() => _status = 'ERROR al crear notificación');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reinitializeService() async {
    setState(() {
      _isLoading = true;
      _status = 'Reinicializando servicio...';
    });

    try {
      _addLog('🔄 Ejecutando reinitializeAfterLogin()...');
      await NotificationService().reinitializeAfterLogin();
      _addLog('✅ Servicio reinicializado correctamente');
      setState(() => _status = 'Servicio reinicializado');
    } catch (e) {
      _addLog('❌ Error: $e');
      setState(() => _status = 'ERROR al reinicializar');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🧪 Debug de Notificaciones'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: _isLoading ? Colors.orange : Colors.green,
            child: Row(
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _checkConfiguration,
                  icon: Icon(Icons.check_circle),
                  label: Text('1. Verificar Configuración'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(16),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _reinitializeService,
                  icon: Icon(Icons.refresh),
                  label: Text('2. Reinicializar Servicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(16),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Crear Notificación de Prueba:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeButton('like', Colors.red),
                    _buildTypeButton('comment', Colors.blue),
                    _buildTypeButton('follow', Colors.purple),
                    _buildTypeButton('ride_invitation', Colors.green),
                    _buildTypeButton('group_invitation', Colors.teal),
                    _buildTypeButton('story', Colors.orange),
                  ],
                ),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        'Los logs aparecerán aquí',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color textColor = Colors.white;
                        if (log.contains('❌')) textColor = Colors.red;
                        if (log.contains('✅')) textColor = Colors.green;
                        if (log.contains('⚠️')) textColor = Colors.orange;
                        if (log.contains('💡')) textColor = Colors.blue;

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, Color color) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _createTestNotification(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(type),
    );
  }
}
