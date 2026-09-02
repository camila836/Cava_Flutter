import 'package:flutter/material.dart';
import '../models/producto.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  const ProductoCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final url = producto.imagenUrl;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: SizedBox(
          width: 56,
          height: 56,
          child: url != null
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                )
              : const Icon(Icons.local_cafe_outlined),
        ),
        title: Text(producto.nombre),
        subtitle: Text(
          producto.descripcion.isNotEmpty ? producto.descripcion : producto.categoria,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${producto.precio}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              producto.stock > 0 ? 'Stock: ${producto.stock}' : 'Agotado',
              style: TextStyle(
                fontSize: 12,
                color: producto.stock > 0 ? Colors.green[700] : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
