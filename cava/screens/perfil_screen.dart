import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/session.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final usuario = session.usuario;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          Text(usuario?['nombre'] ?? '', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          Text(usuario?['correo'] ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => session.logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
