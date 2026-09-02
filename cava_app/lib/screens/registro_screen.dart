import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/cava_theme.dart';
import '../core/session.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  final _identificacion = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  int _idTipoDocumento = 4;
  DateTime? _fechaNacimiento;
  bool _autoriza = false;
  bool _ocultar = true;

  @override
  void dispose() {
    for (final c in [_nombres, _apellidos, _correo, _password, _confirmar, _identificacion, _direccion, _telefono]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(hoy.year - 18, hoy.month, hoy.day),
      firstDate: DateTime(1900),
      lastDate: hoy,
    );
    if (fecha != null) setState(() => _fechaNacimiento = fecha);
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null || !_autoriza) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_fechaNacimiento == null
          ? 'Selecciona tu fecha de nacimiento.'
          : 'Debes autorizar el tratamiento de datos.')));
      return;
    }
    final f = _fechaNacimiento!;
    final fecha = '${f.year.toString().padLeft(4, '0')}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}';
    final session = context.read<Session>();
    final ok = await session.registrar({
      'nombres': _nombres.text.trim(),
      'apellidos': _apellidos.text.trim(),
      'correo': _correo.text.trim(),
      'password': _password.text,
      'confirmacionPassword': _confirmar.text,
      'idTipoDocumento': _idTipoDocumento,
      'identificacion': _identificacion.text.trim(),
      'direccion': _direccion.text.trim(),
      'telefono': _telefono.text.trim(),
      'fechaNacimiento': fecha,
      'autorizacionTratamientoDatos': true,
    });
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta creada. Ya puedes iniciar sesión.')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(session.error ?? 'No se pudo completar el registro.')));
    }
  }

  String? _requerido(String? value) => (value == null || value.trim().isEmpty) ? 'Este campo es obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    return Scaffold(
      appBar: AppBar(title: const Text('CREAR CUENTA')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const CavaEyebrow('Únete a CAVA'),
            const SizedBox(height: 8),
            Text('Crear cuenta', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            const Text('Completa tus datos para disfrutar nuestra selección artesanal.'),
            const SizedBox(height: 25),
            _campo(_nombres, 'Nombres', 'Tu nombre', validator: _requerido),
            _campo(_apellidos, 'Apellidos', 'Tus apellidos', validator: _requerido),
            DropdownButtonFormField<int>(
              value: _idTipoDocumento,
              decoration: const InputDecoration(labelText: 'Tipo de documento'),
              items: const [
                DropdownMenuItem(value: 4, child: Text('Cédula de ciudadanía')),
                DropdownMenuItem(value: 5, child: Text('Cédula de extranjería')),
                DropdownMenuItem(value: 7, child: Text('Pasaporte')),
                DropdownMenuItem(value: 8, child: Text('Permiso por Protección Temporal')),
                DropdownMenuItem(value: 6, child: Text('Tarjeta de identidad')),
              ],
              onChanged: (v) => setState(() => _idTipoDocumento = v ?? 4),
            ),
            const SizedBox(height: 13),
            _campo(_identificacion, 'Identificación', 'Número de documento', keyboard: TextInputType.number, validator: _requerido),
            _campo(_correo, 'Correo electrónico', 'correo@ejemplo.com', keyboard: TextInputType.emailAddress, validator: (v) {
              if (_requerido(v) != null) return _requerido(v);
              return v!.contains('@') ? null : 'Ingresa un correo válido';
            }),
            _campo(_direccion, 'Dirección', 'Dirección de residencia', validator: _requerido),
            _campo(_telefono, 'Teléfono', '+573001234567', keyboard: TextInputType.phone, validator: _requerido),
            InkWell(
              onTap: _seleccionarFecha,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha de nacimiento', prefixIcon: Icon(Icons.calendar_today_outlined)),
                child: Text(_fechaNacimiento == null
                    ? 'Seleccionar fecha'
                    : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}'),
              ),
            ),
            const SizedBox(height: 13),
            _campo(_password, 'Contraseña', 'Mínimo 8 caracteres', obscure: _ocultar, suffix: IconButton(
              onPressed: () => setState(() => _ocultar = !_ocultar),
              icon: Icon(_ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            ), validator: (v) => (v?.length ?? 0) < 8 ? 'Usa al menos 8 caracteres' : null),
            _campo(_confirmar, 'Confirmar contraseña', 'Repite la contraseña', obscure: _ocultar, validator: (v) => v != _password.text ? 'Las contraseñas no coinciden' : null),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _autoriza,
              activeColor: CavaColors.cocoa,
              onChanged: (v) => setState(() => _autoriza = v ?? false),
              title: const Text('Autorizo el tratamiento de mis datos personales.', style: TextStyle(fontSize: 13)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: session.cargando ? null : _registrar,
              child: session.cargando
                  ? const SizedBox(height: 21, width: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('CREAR CUENTA'),
            ),
          ])),
        )),
      ])),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(labelText: label, hintText: hint, suffixIcon: suffix),
      validator: validator,
    ),
  );
}
