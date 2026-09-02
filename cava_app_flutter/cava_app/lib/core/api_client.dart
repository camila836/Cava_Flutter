import 'dart:convert';
import 'package:http/http.dart' as http;

/// Resultado uniforme: envuelve el contrato {ok, data} / {ok:false, error:{codigo,mensaje}}
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

/// Cliente para el API móvil de CAVA (MobileServlet, ruta base `/mobile`).
///
/// IMPORTANTE: verifica el contexto real antes de usar la app.
/// Abre en el navegador:
///   `$origin/Cava/mobile/health`  y si da 404 prueba  `$origin/mobile/health`
/// El que responda {"ok":true,...} es el correcto. Ajusta [contextPath] abajo.
class ApiClient {
  static const String origin =
      'https://chocolates-cava-ejgeged5d8gnfkdf.canadacentral-01.azurewebsites.net';

  // Cambia esto a '' si tu despliegue quedó en la raíz en vez de /Cava.
  static const String contextPath = '/Cava';

  static String get baseUrl => '$origin$contextPath/mobile';

  /// Base para armar URLs de imágenes de producto (campo "imagen": "images/...").
  static String get imagesOrigin => '$origin$contextPath';

  String? _cookie;
  String? _csrfToken;

  bool get isLoggedIn => _csrfToken != null && _cookie != null;
  String? get csrfToken => _csrfToken;

  void _guardarCookie(http.Response r) {
    final setCookie = r.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      _cookie = setCookie.split(';').first;
    }
  }

  Map<String, String> _headers({bool json = false, bool csrf = false}) {
    final h = <String, String>{};
    if (_cookie != null) h['cookie'] = _cookie!;
    if (json) h['content-type'] = 'application/json';
    if (csrf && _csrfToken != null) h['x-csrf-token'] = _csrfToken!;
    return h;
  }

  ApiResult _parse(http.Response r) {
    _guardarCookie(r);
    if (r.statusCode == 204 || r.body.isEmpty) {
      return ApiResult.success(const {});
    }
    Map<String, dynamic> body;
    try {
      body = jsonDecode(r.body) as Map<String, dynamic>;
    } catch (_) {
      return ApiResult.failure('ERROR_RED', 'Respuesta inválida del servidor.');
    }
    if (body['ok'] == true) {
      return ApiResult.success(body['data'] as Map<String, dynamic>?);
    }
    final err = body['error'] as Map<String, dynamic>?;
    return ApiResult.failure(
      err?['codigo'] as String? ?? 'ERROR_DESCONOCIDO',
      err?['mensaje'] as String? ?? 'Ocurrió un error.',
    );
  }

  /// Debe llamarse antes de login/registro/checkout/etc. (cualquier mutación).
  Future<ApiResult> obtenerCsrf() async {
    final r = await http.get(Uri.parse('$baseUrl/csrf'), headers: _headers());
    final res = _parse(r);
    if (res.ok) _csrfToken = res.data?['csrfToken'] as String?;
    return res;
  }

  Future<ApiResult> getHome() async {
    final r = await http.get(Uri.parse('$baseUrl/home'), headers: _headers());
    return _parse(r);
  }

  Future<ApiResult> getProductos({
    String? q,
    String? categoria,
    String orden = 'relevancia',
    int pagina = 1,
  }) async {
    final params = <String, String>{
      'orden': orden,
      'pagina': '$pagina',
      if (q != null && q.isNotEmpty) 'q': q,
      if (categoria != null && categoria.isNotEmpty) 'categoria': categoria,
    };
    final uri = Uri.parse('$baseUrl/productos').replace(queryParameters: params);
    final r = await http.get(uri, headers: _headers());
    return _parse(r);
  }

  Future<ApiResult> login(String correo, String password) async {
    if (_csrfToken == null) await obtenerCsrf();
    final r = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers(json: true, csrf: true),
      body: jsonEncode({'correo': correo, 'password': password}),
    );
    final res = _parse(r);
    if (res.ok) _csrfToken = res.data?['csrfToken'] as String? ?? _csrfToken;
    return res;
  }

  Future<ApiResult> registro(Map<String, dynamic> campos) async {
    if (_csrfToken == null) await obtenerCsrf();
    final r = await http.post(
      Uri.parse('$baseUrl/registro'),
      headers: _headers(json: true, csrf: true),
      body: jsonEncode(campos),
    );
    return _parse(r);
  }

  Future<ApiResult> getSesion() async {
    final r = await http.get(Uri.parse('$baseUrl/sesion'), headers: _headers());
    final res = _parse(r);
    if (res.ok) _csrfToken = res.data?['csrfToken'] as String? ?? _csrfToken;
    return res;
  }

  Future<ApiResult> logout() async {
    final r = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _headers(csrf: true),
    );
    final res = _parse(r);
    _cookie = null;
    _csrfToken = null;
    return res;
  }
}
