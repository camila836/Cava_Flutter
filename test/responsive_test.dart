import 'package:cava_app/core/api_client.dart';
import 'package:cava_app/core/cava_theme.dart';
import 'package:cava_app/core/session.dart';
import 'package:cava_app/main.dart';
import 'package:cava_app/screens/producto_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Fixtures used only in tests, never in the application catalog.
final product = <String, dynamic>{
  'id': 1,
  'nombre': 'Chocolate artesanal colombiano con cacao de origen',
  'descripcion':
      'Descripción extensa para comprobar que el texto conserva su contenido al cambiar el ancho de la pantalla.',
  'precio': 25000,
  'stock': 123,
  'categoria': 'Chocolate artesanal',
  'unidad': 'unidad',
  'imagen': '',
};

class FixtureApi extends ApiClient {
  FixtureApi({this.malformed = false});
  final bool malformed;
  @override
  Future<ApiResult> getHome() async => ApiResult.success({
        'identidad': {'lema': ''},
        'productosDestacados': [
          product,
          {...product, 'id': 2},
          {...product, 'id': 3}
        ],
      });
  @override
  Future<ApiResult> getProductos(
          {String? q,
          String? categoria,
          String orden = 'relevancia',
          int pagina = 1}) async =>
      ApiResult.success({
        'items': malformed
            ? ['invalid']
            : [
                product,
                {...product, 'id': 2},
                {...product, 'id': 3}
              ],
        'pagina': 1,
        'totalPaginas': 1,
      });
}

Future<void> mount(WidgetTester tester, Size size, double scale,
    {ApiClient? api}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ChangeNotifierProvider(
    create: (_) => Session(api: api ?? FixtureApi()),
    child: MaterialApp(
        theme: cavaTheme(),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!),
        home: const RaizApp()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1024, 768),
    const Size(1440, 900),
    const Size(568, 320)
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Inicio, origen y productos at $size, text $scale',
          (tester) async {
        await mount(tester, size, scale);
        expect(tester.takeException(), isNull);
        final originButton =
            find.widgetWithText(OutlinedButton, 'NUESTRO ORIGEN');
        await tester.ensureVisible(originButton);
        await tester.tap(originButton);
        await tester.pumpAndSettle();
        expect(find.text('NUESTRO ORIGEN'), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
            find.text('hola@cavachocolate.com'), 300,
            scrollable: find.byType(Scrollable).first);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Productos'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
            find.byWidgetPredicate(
                (w) => w is ProductoCard && w.producto.id == 1),
            250,
            scrollable: find.byType(Scrollable).first);
        expect(find.byType(ProductoCard), findsNWidgets(3));
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Inicio'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Unconfigured API renders a stable catalog message',
      (tester) async {
    await mount(tester, const Size(390, 844), 1, api: ApiClient());
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('La conexión con el catálogo aún no está configurada.'), 250,
        scrollable: find.byType(Scrollable).first);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Malformed products stop loading and show an error',
      (tester) async {
    await mount(tester, const Size(390, 844), 1,
        api: FixtureApi(malformed: true));
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
