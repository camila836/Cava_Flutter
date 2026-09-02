import 'package:flutter/foundation.dart';
import 'api_client.dart';

class Session extends ChangeNotifier {
  final ApiClient api = ApiClient();

  Map<String, dynamic>? usuario;
  bool cargando = false;
  String? error;

  bool get logueado => usuario != null;

  Future<bool> login(String correo, String password) async {
    cargando = true;
    error = null;
    notifyListeners();
    final res = await api.login(correo, password);
    cargando = false;
    if (res.ok) {
      usuario = res.data?['usuario'] as Map<String, dynamic>?;
    } else {
      error = res.mensaje;
    }
    notifyListeners();
    return res.ok;
  }

  Future<bool> registrar(Map<String, dynamic> campos) async {
    cargando = true;
    error = null;
    notifyListeners();
    final res = await api.registro(campos);
    cargando = false;
    if (!res.ok) error = res.mensaje;
    notifyListeners();
    return res.ok;
  }

  Future<void> logout() async {
    await api.logout();
    usuario = null;
    notifyListeners();
  }
}
