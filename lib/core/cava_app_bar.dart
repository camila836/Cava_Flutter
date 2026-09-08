import 'package:flutter/material.dart';
import 'cava_theme.dart';

/// Barra superior de marca compartida por todas las vistas: franja delgada
/// con el lema, logo "CAVA / Placer Absoluto" centrado y el ícono de
/// carrito con contador. Reemplaza el AppBar genérico en las vistas
/// principales para que todas se vean consistentes con el sitio web.
class CavaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CavaAppBar({super.key, this.contadorCarrito = 0, this.onCarritoTap});

  final int contadorCarrito;
  final VoidCallback? onCarritoTap;

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: double.infinity,
          color: CavaColors.divider.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: const Text(
            'CHOCOLATE ARTESANAL COLOMBIANO',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.6,
                color: CavaColors.muted,
                fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          color: CavaColors.cream,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            const SizedBox(
                width: 40), // balancea el ícono de carrito de la derecha
            Expanded(
              child: Column(children: [
                Text('CAVA',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(letterSpacing: 3, fontSize: 22)),
                const Text('Placer Absoluto',
                    style: TextStyle(
                        fontSize: 10,
                        color: CavaColors.muted,
                        letterSpacing: 1)),
              ]),
            ),
            SizedBox(
              width: 40,
              child: Stack(clipBehavior: Clip.none, children: [
                IconButton(
                  onPressed: onCarritoTap,
                  icon: const Icon(Icons.shopping_bag_outlined,
                      color: CavaColors.ink),
                ),
                if (contadorCarrito > 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                          color: CavaColors.wine, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text('$contadorCarrito',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
