import 'dart:async';
import 'dart:convert';
import 'package:cava_app/core/api_client.dart';
import 'package:cava_app/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('No configuration never sends a request', () async {
    var calls = 0;
    final service = ApiService(
        baseUrl: '',
        client: MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }));
    addTearDown(service.close);
    final result = await ApiClient(service: service).getProductos();
    expect(result.codigo, 'API_NO_CONFIGURADA');
    expect(calls, 0);
  });
  test('GET preserves base path and encodes query; POST sends UTF-8 JSON',
      () async {
    final requests = <http.Request>[];
    final service = ApiService(
        baseUrl: 'https://example.test/Cava/mobile/',
        client: MockClient((request) async {
          requests.add(request);
          return http.Response.bytes(
              utf8.encode('{"nombre":"Cacao colombiano"}'), 200);
        }));
    addTearDown(service.close);
    final response =
        await service.get('productos', query: {'q': 'café & cacao'});
    expect(requests.single.url.path, '/Cava/mobile/productos');
    expect(requests.single.url.queryParameters['q'], 'café & cacao');
    expect(ApiService.decode(response), {'nombre': 'Cacao colombiano'});
    await service.post('test', body: {'nombre': 'chocolaté'});
    expect(requests.last.method, 'POST');
    expect(jsonDecode(requests.last.body), {'nombre': 'chocolaté'});
    expect(requests.last.headers['content-type'], contains('application/json'));
  });
  test(
      'HTTP errors cannot be interpreted as success, including empty responses',
      () async {
    for (final body in ['', '{"ok":true,"data":{}}']) {
      final api = ApiClient(
          service: ApiService(
              baseUrl: 'https://example.test',
              client: MockClient((_) async => http.Response(body, 500))));
      addTearDown(api.close);
      final result = await api.getHome();
      expect(result.ok, false);
      expect(result.codigo, 'HTTP_500');
    }
  });
  test('Malformed JSON and contract return controlled errors', () async {
    for (final body in ['<html>error</html>', '[]', '{"ok":true,"data":[]}']) {
      final api = ApiClient(
          service: ApiService(
              baseUrl: 'https://example.test',
              client: MockClient((_) async => http.Response(body, 200))));
      addTearDown(api.close);
      expect((await api.getHome()).codigo, 'JSON_INVALIDO');
    }
  });
  test('Network and timeout failures become API results', () async {
    final network = ApiClient(
        service: ApiService(
            baseUrl: 'https://example.test',
            client: MockClient(
                (_) async => throw http.ClientException('offline'))));
    addTearDown(network.close);
    expect((await network.getHome()).codigo, 'ERROR_RED');
    final timeout = ApiClient(
        service: ApiService(
            baseUrl: 'https://example.test',
            timeout: const Duration(milliseconds: 5),
            client: MockClient((_) => Completer<http.Response>().future)));
    addTearDown(timeout.close);
    expect((await timeout.getHome()).codigo, 'TIEMPO_AGOTADO');
  });
  test('204 is accepted and absolute request routes are rejected', () async {
    final service = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient((_) async => http.Response('', 204)));
    addTearDown(service.close);
    expect(ApiService.decode(await service.post('test')), isNull);
    await expectLater(
        service.get('https://other.test'), throwsA(isA<ApiException>()));
  });
}
