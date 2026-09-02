import 'package:cava_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CAVA muestra la navegación principal', (tester) async {
    await tester.pumpWidget(const CavaApp());
    await tester.pump();

    expect(find.text('CAVA'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);
  });
}