import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/session.dart';
import 'screens/home_screen.dart';
import 'screens/productos_screen.dart';
import 'screens/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'core/cava_theme.dart';

void main() {
  runApp(const CavaApp());
}

class CavaApp extends StatelessWidget {
  const CavaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Session(),
      child: MaterialApp(
        title: 'CAVA',
        debugShowCheckedModeBanner: false,
        theme: cavaTheme(),
        home: const RaizApp(),
      ),
    );
  }
}

class RaizApp extends StatefulWidget {
  const RaizApp({super.key});
  @override
  State<RaizApp> createState() => _RaizAppState();
}

class _RaizAppState extends State<RaizApp> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final paginas = [
      HomeScreen(onExplore: () => setState(() => _indice = 1)),
      const ProductosScreen(),
      session.logueado ? const PerfilScreen() : const LoginScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Row(children: [
        Text('✦', style: TextStyle(color: CavaColors.gold, fontSize: 14)),
        SizedBox(width: 8),
        Text('CAVA'),
      ])),
      body: IndexedStack(index: _indice, children: paginas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          const NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Productos'),
          NavigationDestination(
            icon: Icon(session.logueado ? Icons.person : Icons.login),
            label: session.logueado ? 'Perfil' : 'Ingresar',
          ),
        ],
      ),
    );
  }
}
