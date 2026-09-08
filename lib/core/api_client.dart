import '../services/api_service.dart';

/// Adaptador del contrato que ya existía; pendiente de verificar contra Java.
class ApiResult {
  final bool ok;
  final Map<String, dynamic>? data;
  final String? codigo;
  final String? mensaje;
  ApiResult.success(this.data)
      : ok = true,
        codigo = null,
        mensaje = null;
  ApiResult.failure(this.codigo, this.mensaje)
      : ok = false,
        data = null;
}

class ApiClient {
  ApiClient({ApiService? service}) : _service = service ?? ApiService();
  final ApiService _service;
  static const String baseUrl = String.fromEnvironment('CAVA_API_BASE_URL');
  static const String imagesOrigin =
      String.fromEnvironment('CAVA_IMAGES_BASE_URL');
  String? _csrfToken;
  String? _cookie;
  String? get csrfToken => _csrfToken;
  bool get isLoggedIn => _csrfToken != null && _cookie != null;

  Future<ApiResult> _request(String path,
      {bool post = false,
      Map<String, String>? query,
      Object? body,
      bool csrf = false}) async {
    try {
      final headers = <String, String>{
        if (_cookie != null) 'cookie': _cookie!,
        if (csrf && _csrfToken != null) 'x-csrf-token': _csrfToken!,
      };
      final response = post
          ? await _service.post(path, body: body, headers: headers)
          : await _service.get(path, query: query, headers: headers);
      final cookie = response.headers['set-cookie'];
      if (cookie != null && cookie.isNotEmpty) {
        _cookie = cookie.split(';').first;
      }
      final decoded = ApiService.decode(response);
      if (decoded == null) return ApiResult.success(const {});
      if (decoded is! Map<String, dynamic>) {
        return ApiResult.failure(
            'JSON_INVALIDO', 'Respuesta inválida del servidor.');
      }
      if (decoded['ok'] == true) {
        final data = decoded['data'];
        if (data != null && data is! Map<String, dynamic>) {
          return ApiResult.failure(
              'JSON_INVALIDO', 'Respuesta inválida del servidor.');
        }
        return ApiResult.success(data as Map<String, dynamic>?);
      }
      final error = decoded['error'];
      return ApiResult.failure(
          error is Map && error['codigo'] is String
              ? error['codigo'] as String
              : 'ERROR_API',
          error is Map && error['mensaje'] is String
              ? error['mensaje'] as String
              : 'Ocurrió un error.');
    } on ApiException catch (error) {
      return ApiResult.failure(error.code, error.message);
    }
  }

  // Rutas preexistentes. No se ejecutan peticiones sin configuración explícita.
  Future<ApiResult> getHome() => _request('home');
  Future<ApiResult> getProductos(
          {String? q,
          String? categoria,
          String orden = 'relevancia',
          int pagina = 1}) =>
      _request('productos', query: {
        'orden': orden,
        'pagina': '$pagina',
        if (q != null && q.isNotEmpty) 'q': q,
        if (categoria != null && categoria.isNotEmpty) 'categoria': categoria,
      });
  Future<ApiResult> obtenerCsrf() async {
    final result = await _request('csrf');
    if (result.ok && result.data?['csrfToken'] is String) {
      _csrfToken = result.data!['csrfToken'] as String;
    }
    return result;
  }

  Future<ApiResult> login(String correo, String password) async {
    if (_csrfToken == null) {
      final csrf = await obtenerCsrf();
      if (!csrf.ok) return csrf;
    }
    final result = await _request('login',
        post: true, csrf: true, body: {'correo': correo, 'password': password});
    if (result.ok && result.data?['csrfToken'] is String) {
      _csrfToken = result.data!['csrfToken'] as String;
    }
    return result;
  }

  Future<ApiResult> registro(Map<String, dynamic> campos) async {
    if (_csrfToken == null) {
      final csrf = await obtenerCsrf();
      if (!csrf.ok) return csrf;
    }
    return _request('registro', post: true, csrf: true, body: campos);
  }

  Future<ApiResult> getSesion() async {
    final result = await _request('sesion');
    if (result.ok && result.data?['csrfToken'] is String) {
      _csrfToken = result.data!['csrfToken'] as String;
    }
    return result;
  }

  Future<ApiResult> logout() async {
    final result = await _request('logout', post: true, csrf: true);
    _csrfToken = null;
    _cookie = null;
    return result;
  }

  void close() => _service.close();
}
