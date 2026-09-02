import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  // TODO: confirmar el id real de "Cédula de ciudadanía" en la tabla tipoDocumento
  // (SELECT id, descripcion FROM tipoDocumento) y ajustar el valor por defecto.
  final _idTipoDocumento = TextEditingController(text: '1');
  final _identificacion = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  DateTime? _fechaNacimiento;
  bool _autoriza = false;

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(ahora.year - 18, ahora.month, ahora.day),
      firstDate: DateTime(1900),
      lastDate: ahora,
    );
    if (fecha != null) setState(() => _fechaNacimiento = fecha);
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_autoriza) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes autorizar el tratamiento de datos.')),
      );
      return;
    }
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu fecha de nacimiento.')),
      );
      return;
    }
    final fecha =
        '${_fechaNacimiento!.year.toString().padLeft(4, '0')}-${_fechaNacimiento!.month.toString().padLeft(2, '0')}-${_fechaNacimiento!.day.toString().padLeft(2, '0')}';

    final session = context.read<Session>();
    final ok = await session.registrar({
      'nombres': _nombres.text.trim(),
      'apellidos': _apellidos.text.trim(),
      'correo': _correo.text.trim(),
      'password': _password.text,
      'confirmacionPassword': _confirmar.text,
      'idTipoDocumento': int.tryParse(_idTipoDocumento.text) ?? 1,
      'identificacion': _identificacion.text.trim(),
      'direccion': _direccion.text.trim(),
      'telefono': _telefono.text.trim(),
      'fechaNacimiento': fecha,
      'autorizacionTratamientoDatos': _autoriza,
    });
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro completado. Ya puedes iniciar sesión.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(session.error ?? 'No se pudo completar el registro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombres,
                decoration: const InputDecoration(labelText: 'Nombres', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _apellidos,
                decoration: const InputDecoration(labelText: 'Apellidos', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _correo,
                decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmar,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _idTipoDocumento,
                      decoration: const InputDecoration(
                        labelText: 'ID tipo documento',
                        helperText: 'Verifica el id real en tu BD (tabla tipoDocumento)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _identificacion,
                      decoration: const InputDecoration(labelText: 'N° documento', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telefono,
                decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_fechaNacimiento == null
                    ? 'Fecha de nacimiento'
                    : '${_fechaNacimiento!.year}-${_fechaNacimiento!.month.toString().padLeft(2, '0')}-${_fechaNacimiento!.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _seleccionarFecha,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _autoriza,
                onChanged: (v) => setState(() => _autoriza = v ?? false),
                title: const Text('Autorizo el tratamiento de mis datos personales'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: session.cargando ? null : _registrar,
                child: session.cargando
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Registrarme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
