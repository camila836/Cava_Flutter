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
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final res = await context.read<Session>().api.getHome();
    if (!mounted) return;
    if (res.ok) {
      final identidad = res.data?['identidad'] as Map<String, dynamic>?;
      setState(() {
        _lema = identidad?['lema'] as String? ?? '';
        _destacados = (res.data?['productosDestacados'] as List? ?? [])
            .map((e) => Producto.fromJson(e as Map<String, dynamic>))
            .toList();
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
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(children: [
          _Hero(lema: _lema, onExplore: widget.onExplore),
          const _FranjaFeatures(),
          _SeccionDestacados(
            cargando: _cargando,
            error: _error,
            destacados: _destacados,
            onReintentar: _cargar,
            onVerTodos: widget.onExplore,
          ),
          const _SeccionOrigen(),
          const _SeccionAnchetas(),
          const _SeccionContacto(),
        ]),
      );
}

/// Hero con imagen de fondo de cacao/chocolate, degradado oscuro y CTA.
class _Hero extends StatelessWidget {
  const _Hero({required this.lema, required this.onExplore});
  final String lema;
  final VoidCallback onExplore;

  static const _fallbackImg =
      'https://images.unsplash.com/photo-1548907040-4baa419dfae2?w=900&q=80';

  @override
  Widget build(BuildContext context) => Container(
        height: 500,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Stack(fit: StackFit.expand, children: [
          Image.network(
            _fallbackImg,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: CavaColors.cocoa),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CavaColors.cocoa.withValues(alpha: 0.88),
                  CavaColors.cocoa.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CavaEyebrow('Chocolate artesanal colombiano', color: Color(0xFFE2BF75)),
              const SizedBox(height: 30),
              Text(
                lema.isNotEmpty ? lema : 'Comer chocolate es una\ninversión en tu felicidad.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Del cacao colombiano nace una experiencia artesanal\nhecha para compartir.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
              const Spacer(),
              Row(children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: CavaColors.forest, foregroundColor: Colors.white),
                    onPressed: onExplore,
                    child: const Text('VER PRODUCTOS'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    child: const Text('NUESTRO ORIGEN'),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      );
}

/// Franja con los 3 iconos: chocolate artesanal / ingredientes / compra segura.
class _FranjaFeatures extends StatelessWidget {
  const _FranjaFeatures();

  static const _items = [
    (Icons.eco_outlined, 'Chocolate\nartesanal'),
    (Icons.spa_outlined, 'Ingredientes\nseleccionados'),
    (Icons.verified_user_outlined, 'Compra\nsegura'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        color: CavaColors.paper,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        child: Row(
          children: [
            for (final (icon, texto) in _items)
              Expanded(
                child: Column(children: [
                  Icon(icon, color: CavaColors.wine, size: 26),
                  const SizedBox(height: 8),
                  Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: CavaColors.ink, fontWeight: FontWeight.w600, height: 1.3)),
                ]),
              ),
          ],
        ),
      );
}

/// Sección "Hechos para disfrutar despacio" con carrusel horizontal de
/// productos destacados, conectada a los datos reales del API.
class _SeccionDestacados extends StatelessWidget {
  const _SeccionDestacados({
    required this.cargando,
    required this.error,
    required this.destacados,
    required this.onReintentar,
    required this.onVerTodos,
  });
  final bool cargando;
  final String? error;
  final List<Producto> destacados;
  final VoidCallback onReintentar;
  final VoidCallback onVerTodos;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 34, 18, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: CavaTituloAcento('Hechos para disfrutar', 'despacio')),
            TextButton(onPressed: onVerTodos, child: const Text('Ver todos', style: TextStyle(color: CavaColors.wine, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 16),
          if (cargando)
            const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Center(child: CircularProgressIndicator()))
          else if (error != null)
            _MessageCard(message: error!, onRetry: onReintentar)
          else if (destacados.isEmpty)
            const _MessageCard(message: 'Pronto encontrarás aquí nuestra selección destacada.')
          else
            SizedBox(
              height: 268,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: destacados.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => ProductoDestacadoCard(producto: destacados[i], onVerProducto: onVerTodos),
              ),
            ),
        ]),
      );
}

/// Sección "Del origen al chocolate, con respeto y propósito".
class _SeccionOrigen extends StatelessWidget {
  const _SeccionOrigen();

  static const _img = 'https://images.unsplash.com/photo-1511381939415-e44015466834?w=800&q=80';

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 30, 18, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(_img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: CavaColors.forest)),
            ),
          ),
          const SizedBox(height: 18),
          const CavaEyebrow('Nuestro origen', color: CavaColors.wine),
          const SizedBox(height: 8),
          CavaTituloAcento('Del origen al chocolate, con respeto y', 'propósito'),
          const SizedBox(height: 10),
          const Text(
            'Trabajamos directamente con familias cacaoteras en distintas regiones de Colombia para honrar el cacao, su tierra y quienes lo cultivan.',
            style: TextStyle(color: CavaColors.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: CavaColors.ink, side: const BorderSide(color: CavaColors.ink)),
            onPressed: () {},
            child: const Text('CONOCE NUESTRA HISTORIA'),
          ),
        ]),
      );
}

/// Sección "Regala momentos que saben a verdad" (anchetas), decorativa por ahora.
class _SeccionAnchetas extends StatelessWidget {
  const _SeccionAnchetas();

  @override
  Widget build(BuildContext context) => Container(
        color: CavaColors.blush.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
        child: Column(children: [
          CavaTituloAcento('Regala momentos que saben a', 'verdad', textAlign: TextAlign.center),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _TarjetaAncheta(titulo: 'Ancheta sencilla', precio: '\$ 85.000 COP')),
            const SizedBox(width: 12),
            Expanded(child: _TarjetaAncheta(titulo: 'Ancheta especial', precio: '\$ 150.000 COP')),
          ]),
        ]),
      );
}

class _TarjetaAncheta extends StatelessWidget {
  const _TarjetaAncheta({required this.titulo, required this.precio});
  final String titulo;
  final String precio;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: CavaColors.paper, borderRadius: BorderRadius.circular(4), border: Border.all(color: CavaColors.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.card_giftcard_outlined, color: CavaColors.wine, size: 22),
          const SizedBox(height: 10),
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(precio, style: const TextStyle(color: CavaColors.wine, fontWeight: FontWeight.w700)),
        ]),
      );
}

/// Franja de contacto oscura al final del Home.
class _SeccionContacto extends StatelessWidget {
  const _SeccionContacto();
  @override
  Widget build(BuildContext context) => Container(
        color: CavaColors.cocoa,
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 34),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CavaEyebrow('Hablemos', color: Color(0xFFE2BF75)),
          const SizedBox(height: 8),
          Text('Estamos para ti', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 10),
          const Text('¿Dudas, pedidos especiales o alianzas? Escríbenos y con gusto te ayudamos.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          const _FilaContacto(icon: Icons.call_outlined, texto: '+57 321 123 4567'),
          const _FilaContacto(icon: Icons.mail_outline, texto: 'hola@cavachocolate.com'),
          const _FilaContacto(icon: Icons.schedule_outlined, texto: 'Lun a Vie: 8:00 a.m. - 5:00 p.m.'),
        ]),
      );
}

class _FilaContacto extends StatelessWidget {
  const _FilaContacto({required this.icon, required this.texto});
  final IconData icon;
  final String texto;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 10),
          Text(texto, style: const TextStyle(color: Colors.white70)),
        ]),
      );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ]),
        ),
      );
}
