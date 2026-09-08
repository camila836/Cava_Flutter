import 'package:flutter/material.dart';

/// Columnas con ancho mínimo y altura natural, también con texto ampliado.
class CavaColumns extends StatelessWidget {
  const CavaColumns(
      {super.key,
      required this.children,
      this.minWidth = 280,
      this.maxColumns = 3,
      this.spacing = 16});
  final List<Widget> children;
  final double minWidth;
  final int maxColumns;
  final double spacing;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, size) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns =
            ((size.maxWidth + spacing) / (minWidth * scale + spacing))
                .floor()
                .clamp(1, maxColumns);
        final width = (size.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(spacing: spacing, runSpacing: spacing, children: [
          for (final child in children) SizedBox(width: width, child: child),
        ]);
      });
}
