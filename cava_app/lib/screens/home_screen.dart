import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/cava_theme.dart';
import '../core/session.dart';
import '../models/producto.dart';
import 'producto_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _cargando = true;
  String? _error;
  String _lema = '';
  List<Producto> _destacados = [];

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final res = await context.read<Session>().api.getHome();
    if (!mounted) return;
    if (res.ok) {
      final identidad = res.data?['identidad'] as Map<String, dynamic>?;
      setState(() {
        _lema = identidad?['lema'] as String? ?? '';
        _destacados = (res.data?['productosDestacados'] as List? ?? [])
            .map((e) => Producto.fromJson(e as Map<String, dynamic>)).toList();
        _cargando = false;
        _error = null;
      });
    } else {
      setState(() { _error = res.mensaje ?? 'No se pudo cargar el inicio.'; _cargando = false; });
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _cargar,
    child: ListView(children: [
      Container(
        height: 470,
        padding: const EdgeInsets.fromLTRB(22, 64, 22, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [CavaColors.cocoa, CavaColors.brown, Color(0xFF786044)],
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CavaEyebrow('Hecho a mano con amor · Bogotá, Colombia', color: Color(0xFFE2BF75)),
          const SizedBox(height: 38),
          Text(
            _lema.isNotEmpty ? _lema : 'Comer chocolate\nno es un capricho,\nes una inversión en\ntu felicidad.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
          ),
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: CavaColors.gold, foregroundColor: CavaColors.cocoa),
            onPressed: widget.onExplore,
            child: const Text('EXPLORAR LA TIENDA'),
          ),
          const SizedBox(height: 11),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {},
            child: const Text('CACAO 100% COLOMBIANO'),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 34, 18, 42),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CavaEyebrow('Selección artesanal'),
          const SizedBox(height: 8),
          Text('Descubre nuestros productos', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Chocolate artesanal elaborado con cacao colombiano y cuidado en cada detalle.'),
          const SizedBox(height: 24),
          if (_cargando)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
          else if (_error != null)
            _MessageCard(message: _error!, onRetry: _cargar)
          else if (_destacados.isEmpty)
            const _MessageCard(message: 'Pronto encontrarás aquí nuestra selección destacada.')
          else
            ..._destacados.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProductoCard(producto: p),
            )),
        ]),
      ),
    ]),
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      Text(message, textAlign: TextAlign.center),
      if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Reintentar')),
    ]),
  ));
}
