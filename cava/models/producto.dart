import '../core/api_client.dart';

class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final num precio;
  final int stock;
  final String categoria;
  final String unidad;
  final String imagen; // ej: "images/productos/Nibs.png" o ""

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.categoria,
    required this.unidad,
    required this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> j) => Producto(
        id: j['id'] as int,
        nombre: j['nombre'] as String? ?? '',
        descripcion: j['descripcion'] as String? ?? '',
        precio: j['precio'] as num? ?? 0,
        stock: j['stock'] as int? ?? 0,
        categoria: j['categoria'] as String? ?? '',
        unidad: j['unidad'] as String? ?? '',
        imagen: j['imagen'] as String? ?? '',
      );

  /// URL absoluta de la imagen, o null si no hay imagen de referencia.
  String? get imagenUrl =>
      imagen.isEmpty ? null : '${ApiClient.imagesOrigin}/$imagen';
}
