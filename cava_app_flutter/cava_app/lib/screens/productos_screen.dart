import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  Future<void> _buscar({int pagina = 1}) async {
    setState(() => _cargando = true);
    final session = context.read<Session>();
    final res = await session.api.getProductos(
      q: _buscador.text.trim(),
      orden: _orden,
      pagina: pagina,
    );
    if (!mounted) return;
    if (res.ok) {
      final items = (res.data?['items'] as List? ?? [])
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _items = items;
        _pagina = res.data?['pagina'] as int? ?? 1;
        _totalPaginas = res.data?['totalPaginas'] as int? ?? 1;
        _cargando = false;
        _error = null;
      });
    } else {
      setState(() {
        _error = res.mensaje ?? 'No se pudieron cargar los productos.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _buscador,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar productos...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _buscar(),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (v) {
                  setState(() => _orden = v);
                  _buscar();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'relevancia', child: Text('Relevancia')),
                  PopupMenuItem(value: 'precio_asc', child: Text('Precio: menor a mayor')),
                  PopupMenuItem(value: 'precio_desc', child: Text('Precio: mayor a menor')),
                  PopupMenuItem(value: 'alfabetico', child: Text('Alfabético')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _items.isEmpty
                      ? const Center(child: Text('Sin resultados.'))
                      : RefreshIndicator(
                          onRefresh: () => _buscar(pagina: _pagina),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _items.length,
                            itemBuilder: (_, i) => ProductoCard(producto: _items[i]),
                          ),
                        ),
        ),
        if (_totalPaginas > 1)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _pagina > 1 ? () => _buscar(pagina: _pagina - 1) : null,
                ),
                Text('Página $_pagina de $_totalPaginas'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _pagina < _totalPaginas ? () => _buscar(pagina: _pagina + 1) : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
