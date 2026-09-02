import 'package:flutter/material.dart';
import '../core/cava_theme.dart';
import '../models/producto.dart';

class ProductoCard extends StatelessWidget {
  const ProductoCard({super.key, required this.producto});
  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final base = producto.precio.toStringAsFixed(0);
    final precio = '\$${base.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')} COP';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: producto.imagenUrl == null
              ? const _Placeholder()
              : Image.network(
                  producto.imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _Placeholder(),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CavaEyebrow(producto.categoria.isEmpty ? 'Seleccion CAVA' : producto.categoria),
            const SizedBox(height: 8),
            Text(producto.nombre, style: Theme.of(context).textTheme.titleLarge),
            if (producto.descripcion.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(producto.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Text(precio, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CavaColors.cocoa))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: producto.stock > 0 ? const Color(0xFFE7F1E7) : const Color(0xFFF7E5E1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  producto.stock > 0 ? '${producto.stock} disponibles' : 'Agotado',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: producto.stock > 0 ? Colors.green.shade800 : Colors.red.shade800),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE5CFAA), Color(0xFFF8ECDC)])),
    child: const Center(child: Icon(Icons.coffee_outlined, size: 48, color: CavaColors.brown)),
  );
}
