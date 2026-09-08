import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => message;
}

/// Transporte HTTP/JSON sin endpoints ni reglas de negocio.
class ApiService {
  ApiService(
      {String? baseUrl,
      http.Client? client,
      this.timeout = const Duration(seconds: 15)})
      : baseUrl = baseUrl ?? const String.fromEnvironment('CAVA_API_BASE_URL'),
        _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;
  Uri _uri(String path, Map<String, String>? query) {
    final base = Uri.tryParse(baseUrl);
    if (base == null ||
        !['http', 'https'].contains(base.scheme) ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment) {
      throw const ApiException('API_NO_CONFIGURADA',
          'La conexión con el catálogo aún no está configurada.');
    }
    final relative = Uri.parse(path);
    if (relative.hasScheme ||
        relative.hasAuthority ||
        relative.pathSegments.contains('..') ||
        relative.hasQuery ||
        relative.hasFragment) {
      throw const ApiException('RUTA_INVALIDA', 'Ruta de API inválida.');
    }
    final root = base.path.replaceFirst(RegExp(r'/+$'), '');
    final route = relative.path.replaceFirst(RegExp(r'^/+'), '');
    return base.replace(path: '$root/$route', queryParameters: query);
  }

  Future<http.Response> get(String path,
          {Map<String, String>? query, Map<String, String>? headers}) =>
      _send('GET', path, query: query, headers: headers);
  Future<http.Response> post(String path,
          {Object? body, Map<String, String>? headers}) =>
      _send('POST', path, body: body, headers: headers);
  Future<http.Response> _send(String method, String path,
      {Map<String, String>? query,
      Map<String, String>? headers,
      Object? body}) async {
    final uri = _uri(path, query);
    final requestHeaders = {'accept': 'application/json', ...?headers};
    try {
      final response = await (method == 'GET'
              ? _client.get(uri, headers: requestHeaders)
              : _client.post(uri,
                  headers: {
                    ...requestHeaders,
                    'content-type': 'application/json; charset=utf-8'
                  },
                  body: body == null ? null : jsonEncode(body)))
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('HTTP_${response.statusCode}',
            'No se pudo completar la solicitud (${response.statusCode}).');
      }
      return response;
    } on TimeoutException {
      throw const ApiException(
          'TIEMPO_AGOTADO', 'El servidor tardó demasiado en responder.');
    } on http.ClientException {
      throw const ApiException(
          'ERROR_RED', 'No se pudo conectar con el servidor.');
    }
  }

  static Object? decode(http.Response response) {
    if (response.statusCode == 204 || response.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException(
          'JSON_INVALIDO', 'Respuesta inválida del servidor.');
    }
  }

  void close() => _client.close();
}
