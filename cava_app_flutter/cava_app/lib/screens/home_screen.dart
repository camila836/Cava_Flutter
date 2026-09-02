import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/session.dart';
import '../models/producto.dart';
import 'producto_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _cargando = true;
  String? _error;
  String _lema = '';
  List<Producto> _destacados = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final session = context.read<Session>();
    final res = await session.api.getHome();
    if (!mounted) return;
    if (res.ok) {
      final identidad = res.data?['identidad'] as Map<String, dynamic>?;
      final items = (res.data?['productosDestacados'] as List? ?? [])
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _lema = identidad?['lema'] as String? ?? '';
        _destacados = items;
        _cargando = false;
        _error = null;
      });
    } else {
      setState(() {
        _error = res.mensaje ?? 'No se pudo cargar el inicio.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargar,
      child: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('CAVA', style: Theme.of(context).textTheme.headlineMedium),
                    if (_lema.isNotEmpty)
                      Text(_lema, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Text('Destacados', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    if (_destacados.isEmpty) const Text('Sin productos destacados por ahora.'),
                    ..._destacados.map((p) => ProductoCard(producto: p)),
                  ],
                ),
    );
  }
}
