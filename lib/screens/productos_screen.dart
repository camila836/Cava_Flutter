import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/cava_theme.dart';
import '../core/cava_layout.dart';
import '../core/session.dart';
import '../models/producto.dart';
import 'producto_card.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});
  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final _buscador = TextEditingController();
  String _orden = 'relevancia';
  bool _cargando = true;
  String? _error;
  List<Producto> _items = [];
  int _pagina = 1;
  int _totalPaginas = 1;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  int _requestId = 0;
  Future<void> _buscar({int pagina = 1}) async {
    final requestId = ++_requestId;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await context.read<Session>().api.getProductos(
          q: _buscador.text.trim(), orden: _orden, pagina: pagina);
      if (!mounted || requestId != _requestId) return;
      if (!res.ok) {
        setState(() =>
            _error = res.mensaje ?? 'No se pudieron consultar los productos.');
        return;
      }
      final items = (res.data?['items'] as List? ?? [])
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList();
      final current = res.data?['pagina'] as int? ?? 1;
      final total = res.data?['totalPaginas'] as int? ?? 1;
      setState(() {
        _items = items;
        _pagina = current;
        _totalPaginas = total;
      });
    } on TypeError {
      if (mounted && requestId == _requestId) {
        setState(() =>
            _error = 'El catálogo devolvió datos con un formato inválido.');
      }
    } finally {
      if (mounted && requestId == _requestId) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: () => _buscar(pagina: _pagina),
      child:
          ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [CavaColors.paper, Color(0xFFF1DFC3)])),
          child: Column(children: [
            const CavaEyebrow('CAVA · Placer absoluto'),
            const SizedBox(height: 8),
            Text('Chocolates para disfrutar con calma',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
                'Consulta nuestra selección disponible directamente desde el catálogo.',
                textAlign: TextAlign.center),
          ]),
        ),
        Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                      child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CavaEyebrow('Encuentra tu selección'),
                          const SizedBox(height: 7),
                          Text('Filtrar catálogo',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _buscador,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Ej. chocolate con cacao'),
                            onSubmitted: (_) => _buscar(),
                          ),
                          const SizedBox(height: 11),
                          DropdownButtonFormField<String>(
                            initialValue: _orden,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.sort),
                                labelText: 'Ordenar por'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'relevancia',
                                  child: Text('Selección CAVA')),
                              DropdownMenuItem(
                                  value: 'precio_asc',
                                  child: Text('Precio: menor a mayor')),
                              DropdownMenuItem(
                                  value: 'precio_desc',
                                  child: Text('Precio: mayor a menor')),
                              DropdownMenuItem(
                                  value: 'alfabetico',
                                  child: Text('Nombre: A a Z')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _orden = v);
                            },
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                              onPressed: _cargando ? null : () => _buscar(),
                              icon: const Icon(Icons.tune),
                              label: const Text('APLICAR FILTROS')),
                        ]),
                  )),
                  const SizedBox(height: 26),
                  Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Text('Piezas disponibles',
                            style: Theme.of(context).textTheme.titleLarge),
                        if (!_cargando && _error == null)
                          Text('${_items.length} productos',
                              style: const TextStyle(color: CavaColors.muted)),
                      ]),
                  const SizedBox(height: 14),
                  if (_cargando)
                    const Padding(
                        padding: EdgeInsets.all(42),
                        child: Center(child: CircularProgressIndicator()))
                  else if (_error != null)
                    _StateCard(
                        icon: Icons.cloud_off,
                        text: _error!,
                        action: () => _buscar())
                  else if (_items.isEmpty)
                    const _StateCard(
                        icon: Icons.search_off,
                        text: 'No encontramos productos con esos filtros.')
                  else
                    CavaColumns(children: [
                      for (final p in _items) ProductoCard(producto: p)
                    ]),
                  if (_totalPaginas > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 22),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: !_cargando && _pagina > 1
                                    ? () => _buscar(pagina: _pagina - 1)
                                    : null,
                                icon: const Icon(Icons.chevron_left)),
                            Text('Página $_pagina de $_totalPaginas'),
                            IconButton(
                                onPressed: !_cargando && _pagina < _totalPaginas
                                    ? () => _buscar(pagina: _pagina + 1)
                                    : null,
                                icon: const Icon(Icons.chevron_right)),
                          ]),
                    ),
                ])),
      ]));
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Card(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Icon(icon, size: 36, color: CavaColors.gold),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center),
          if (action != null)
            TextButton(onPressed: action, child: const Text('Reintentar'))
        ]),
      ));
}
