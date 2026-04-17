import 'package:firebase_performance/firebase_performance.dart';
import 'package:biux/core/services/app_logger.dart';

/// Servicio de monitoreo de rendimiento con Firebase Performance.
///
/// Uso:
/// ```dart
/// final trace = await PerformanceService.startTrace('load_rides');
/// // ... operación pesada ...
/// await PerformanceService.stopTrace(trace);
/// ```
class PerformanceService {
  PerformanceService._();

  static final FirebasePerformance _performance = FirebasePerformance.instance;
  static Trace? _appLoadTrace;

  /// Inicia una traza de carga de la app (llamar en main.dart)
  static Future<void> startAppLoadTrace() async {
    try {
      _appLoadTrace = _performance.newTrace('app_load');
      await _appLoadTrace?.start();
      AppLogger.debug(
        'Performance trace: app_load started',
        tag: 'Performance',
      );
    } catch (e) {
      AppLogger.error(
        'Error starting app_load trace',
        error: e,
        tag: 'Performance',
      );
    }
  }

  /// Detiene la traza de carga de la app (llamar cuando la primera pantalla esté lista)
  static Future<void> stopAppLoadTrace() async {
    try {
      await _appLoadTrace?.stop();
      _appLoadTrace = null;
      AppLogger.debug(
        'Performance trace: app_load stopped',
        tag: 'Performance',
      );
    } catch (e) {
      AppLogger.error(
        'Error stopping app_load trace',
        error: e,
        tag: 'Performance',
      );
    }
  }

  /// Inicia una traza personalizada
  static Future<Trace?> startTrace(String name) async {
    try {
      final trace = _performance.newTrace(name);
      await trace.start();
      return trace;
    } catch (e) {
      AppLogger.error(
        'Error starting trace: $name',
        error: e,
        tag: 'Performance',
      );
      return null;
    }
  }

  /// Detiene una traza personalizada
  static Future<void> stopTrace(Trace? trace) async {
    try {
      await trace?.stop();
    } catch (e) {
      AppLogger.error('Error stopping trace', error: e, tag: 'Performance');
    }
  }

  /// Agrega un atributo a una traza
  static void setTraceAttribute(Trace? trace, String key, String value) {
    try {
      trace?.putAttribute(key, value);
    } catch (e) {
      AppLogger.error(
        'Error setting trace attribute',
        error: e,
        tag: 'Performance',
      );
    }
  }

  /// Agrega una métrica a una traza
  static void setTraceMetric(Trace? trace, String name, int value) {
    try {
      trace?.setMetric(name, value);
    } catch (e) {
      AppLogger.error(
        'Error setting trace metric',
        error: e,
        tag: 'Performance',
      );
    }
  }

  /// Mide el tiempo de ejecución de una función async
  static Future<T> measureAsync<T>(
    String traceName,
    Future<T> Function() operation,
  ) async {
    final trace = await startTrace(traceName);
    try {
      final result = await operation();
      setTraceAttribute(trace, 'status', 'success');
      return result;
    } catch (e) {
      setTraceAttribute(trace, 'status', 'error');
      setTraceAttribute(trace, 'error', e.toString().substring(0, 100));
      rethrow;
    } finally {
      await stopTrace(trace);
    }
  }

  /// Crea un HttpMetric para monitorear llamadas HTTP
  static Future<HttpMetric?> startHttpMetric(
    String url,
    HttpMethod method,
  ) async {
    try {
      final metric = _performance.newHttpMetric(url, method);
      await metric.start();
      return metric;
    } catch (e) {
      AppLogger.error(
        'Error starting HTTP metric',
        error: e,
        tag: 'Performance',
      );
      return null;
    }
  }

  /// Detiene un HttpMetric
  static Future<void> stopHttpMetric(
    HttpMetric? metric, {
    int? responseCode,
    int? responsePayloadSize,
  }) async {
    try {
      if (metric != null) {
        if (responseCode != null)
          metric.responsePayloadSize = responsePayloadSize;
        if (responseCode != null) metric.httpResponseCode = responseCode;
        await metric.stop();
      }
    } catch (e) {
      AppLogger.error(
        'Error stopping HTTP metric',
        error: e,
        tag: 'Performance',
      );
    }
  }
}
