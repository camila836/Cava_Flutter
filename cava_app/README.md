# CAVA App (Flutter)

Consume el `MobileServlet` ya desplegado en Azure:
`https://chocolates-cava-ejgeged5d8gnfkdf.canadacentral-01.azurewebsites.net`

## 1. Verifica el contexto real antes de correr la app

En el navegador abre:
- `https://chocolates-cava-....azurewebsites.net/Cava/mobile/health`
- si da 404, prueba `https://chocolates-cava-....azurewebsites.net/mobile/health`

El que responda `{"ok":true,...}` es el correcto. Ajusta la constante
`contextPath` en `lib/core/api_client.dart` (ya viene puesta en `/Cava`).

## 2. Instalar en Codespaces

```bash
# dentro del devcontainer de Flutter (o instala el SDK si no está)
flutter create .        # genera android/, ios/, web/, etc. sin tocar lib/ ni pubspec.yaml
flutter pub get
```

Si tu Codespace no trae el SDK de Flutter, agrega esta imagen en
`.devcontainer/devcontainer.json`: `ghcr.io/cirruslabs/flutter:stable`.

## 3. Ejecutar

Codespaces no tiene pantalla para un emulador Android, así que las opciones son:

- **Recomendado**: compilar el APK y probarlo en tu celular/emulador local:
  ```bash
  flutter build apk --debug
  ```
  El archivo queda en `build/app/outputs/flutter-apk/app-debug.apk`; descárgalo del Codespace e instálalo.
- **Alternativa web** (rápida para ver pantallas, pero el login por cookie
  puede fallar por CORS ya que el backend no expone `Access-Control-Allow-Origin`
  con credenciales todavía):
  ```bash
  flutter run -d web-server --web-port 8080
  ```
  y usa el reenvío de puertos de Codespaces.

## Pendiente a confirmar (no lo inventé, lo dejo señalado)

- `idTipoDocumento` en el registro: los ids de `tipoDocumento` no son fijos en
  la semilla SQL. En el formulario de registro dejé el campo editable (default `1`)
  con una nota. Ejecuta `SELECT id, descripcion FROM tipoDocumento;` en tu BD y
  dime el id de "Cédula de ciudadanía" si quieres que lo fije por defecto.
- El API móvil no expone catálogo de tipos de documento; si lo necesitas,
  habría que agregarlo a `MobileServlet` (avísame y lo hago).
