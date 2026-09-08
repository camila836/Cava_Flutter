import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/cava_theme.dart';
import '../core/session.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _ocultar = true;

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<Session>();
    final ok = await session.login(_correo.text.trim(), _password.text);
    if (!mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(session.error ?? 'No se pudo iniciar sesión.')));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    return SafeArea(
        child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: MediaQuery.sizeOf(context).height - 210),
        child: Card(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 48, 22, 34),
          child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CavaEyebrow('Bienvenido de nuevo'),
                    const SizedBox(height: 10),
                    Text('Iniciar sesión',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 7),
                    Row(children: [
                      const Text('¿No tienes cuenta? '),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const RegistroScreen())),
                        child: const Text('Regístrate aquí',
                            style: TextStyle(
                                color: CavaColors.gold,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _correo,
                      decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          hintText: 'correo@ejemplo.com',
                          prefixIcon: Icon(Icons.mail_outline)),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (v) {
                        final correo = v?.trim() ?? '';
                        if (correo.isEmpty) return 'Ingresa tu correo';
                        if (!correo.contains('@')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _ocultar = !_ocultar),
                            icon: Icon(_ocultar
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined)),
                      ),
                      obscureText: _ocultar,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) =>
                          session.cargando ? null : _entrar(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingresa tu contraseña'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: session.cargando ? null : _entrar,
                      child: session.cargando
                          ? const SizedBox(
                              height: 21,
                              width: 21,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('ENTRAR A MI CUENTA'),
                    ),
                  ])),
        )),
      ),
    ));
  }
}
