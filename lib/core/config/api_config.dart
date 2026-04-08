/// Configuración centralizada de URLs y endpoints de la API.
///
/// Todas las URLs del proyecto deben usar esta clase en lugar de hardcodear strings.
/// Para cambiar de entorno, solo se modifica [_environment].
class ApiConfig {
  ApiConfig._();

  // ─── Entorno activo ───────────────────────────────────────────────────
  static const AppEnvironment _environment = AppEnvironment.production;

  // ─── URLs base por entorno ────────────────────────────────────────────
  static String get baseUrl {
    switch (_environment) {
      case AppEnvironment.production:
        return 'https://biux-prod.ibacrea.com/api/v1';
      case AppEnvironment.staging:
        return 'https://biux-staging.ibacrea.com/api/v1';
      case AppEnvironment.development:
        return 'http://localhost:3000/api/v1';
    }
  }

  static String get authBaseUrl {
    switch (_environment) {
      case AppEnvironment.production:
        return 'https://n8n.oktavia.me/webhook';
      case AppEnvironment.staging:
        return 'https://n8n.oktavia.me/webhook';
      case AppEnvironment.development:
        return 'http://localhost:5678/webhook';
    }
  }

  // ─── Endpoints: Grupos ────────────────────────────────────────────────
  static String get grupos => '$baseUrl/grupos';

  // ─── Endpoints: Usuarios ──────────────────────────────────────────────
  static String get usuarios => '$baseUrl/usuarios';

  // ─── Endpoints: Rodadas ───────────────────────────────────────────────
  static String get rodadas => '$baseUrl/rodadas';
  static String get participantesRodada => '$baseUrl/participantesRodada';

  // ─── Endpoints: Historias ─────────────────────────────────────────────
  static String get historias => '$baseUrl/historias';

  // ─── Endpoints: Sitios ────────────────────────────────────────────────
  static String get sitios => '$baseUrl/sitios';
  static String get sitiosNegocios => '$baseUrl/sitios?tipoSitio.tipo=Negocio';

  // ─── Endpoints: EPS ───────────────────────────────────────────────────
  static String get eps => '$baseUrl/eps';

  // ─── Endpoints: Publicidades ──────────────────────────────────────────
  static String get publicidades => '$baseUrl/publicidades';

  // ─── Endpoints: Miembros ──────────────────────────────────────────────
  static String get miembros => '$baseUrl/miembros';

  // ─── Endpoints: Autenticación ─────────────────────────────────────────
  static String get sendOtp => '$authBaseUrl/send-otp';
  static String get validateOtp => '$authBaseUrl/validate-otp';

  // ─── Helpers ──────────────────────────────────────────────────────────
  static String rodadaById(String id) => '$rodadas/$id';
  static String miembroById(String id) => '$miembros/$id';
  static String publicidadById(String docId) => '$publicidades/$docId';
  static String sitioById(String id) => '$sitios/$id';
  static String miembrosPorGrupo(String grupoId) =>
      '$miembros?grupo.id=$grupoId';
  static String miembrosPorUsuario(String userId) =>
      '$miembros?usuario.id=$userId';
  static String miembrosPorAdmin(String adminId) =>
      '$miembros?grupo.administrador.id=$adminId';
  static String participanteRodada(String rodadaId, String userId) =>
      '$participantesRodada?rodada.id=$rodadaId&usuarioId=$userId';

  static String rodadasPorGrupo(String grupoId, {int? limit, int? offset}) {
    var url = '$rodadas?grupo.id=$grupoId';
    if (limit != null) url += '&limit=$limit';
    if (offset != null) url += '&offset=$offset';
    return url;
  }

  static String rodadasPorCiudad(
    String cityId, {
    required String fechaDesde,
    int? limit,
    int? offset,
  }) {
    var url =
        '$rodadas?ciudadId=$cityId&sort=fechaHora.asc&fechaHora.gt=$fechaDesde,format=yyyy-MM-dd';
    if (limit != null) url += '&limit=$limit';
    if (offset != null) url += '&offset=$offset';
    return url;
  }

  static String get publicidadesAleatorias =>
      '$publicidades?randomValues=true&dinero.gt=0.0';

  static String publicidadesConPaginacion({int limit = 10, int offset = 0}) =>
      '$publicidades?limit=$limit&offset=$offset';

  static String get environmentName => _environment.name;
  static bool get isProduction => _environment == AppEnvironment.production;
}

enum AppEnvironment {
  production,
  staging,
  development,
}
