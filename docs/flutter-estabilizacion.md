# Estabilización de CAVA Flutter

## Base conservada

Trabajo realizado en /workspaces/Cava_Flutter, rama main, sobre d5cd267.
El árbol inicial estaba limpio y sincronizado con origin/main.
Flutter 3.47.2 y Dart 3.13.2. El análisis inicial no tenía incidencias:
la corrección de cavaTheme() ya estaba en la base.

Se conservan las pantallas y el contenido existente. Nuestro origen es una
sección del inicio, no una pantalla independiente. El botón del hero desplaza
hasta esa sección. El botón de historia no tenía destino ni contenido adicional;
queda deshabilitado hasta definir su destino real.

## Interfaz

- Cabecera con altura natural; contenido limitado a 1200 píxeles en escritorio.
- Inicio con altura de contenido, botones y tarjetas que reorganizan columnas.
- Origen e imagen en dos columnas si hay espacio, apilados en tamaños pequeños.
- Productos en columnas de ancho mínimo 280, hasta tres, con altura natural.
- El escalado de texto participa en la cantidad de columnas; no se corta la
  descripción ni el nombre del producto. Precio y disponibilidad se ajustan.
- El catálogo completo se desplaza, incluido su encabezado, también en horizontal.
- Se mantienen las imágenes externas existentes y sus alternativas de error.
  No hay tipografías personalizadas declaradas en pubspec.yaml; se conserva serif.

## Preparación de API

lib/services/api_service.dart proporciona GET, POST JSON UTF-8, timeout de 15 s,
validación de URL, errores HTTP y cierre del cliente. Permite inyectar http.Client
para pruebas. La dependencia http ya existía; no se duplicó el modelo Producto.

CAVA_API_BASE_URL define la base completa de la API mediante --dart-define.
CAVA_IMAGES_BASE_URL define la base de las imágenes relativas. Ambas están vacías
por defecto. Sin configuración no se envía ninguna petición de catálogo y la
interfaz explica que la conexión está pendiente. Las imágenes absolutas HTTP(S)
se respetan; no se concatenan a otro dominio.

Configurar estas variables sólo después de verificar las URLs reales de Java.
Usar valores distintos en cada entorno y volver a compilar: son variables de
compilación, no secretos ni configuración editable en el navegador.

lib/core/api_client.dart conserva el adaptador y las rutas preexistentes
(home, productos, csrf, login, registro, sesion y logout). Su presencia no certifica
que existan en el backend. No se añadieron rutas ni se probó la URL antigua de Azure.
Se conservó el código de autenticación previo; su funcionamiento, cookies y CORS
en web siguen pendientes y fuera del alcance de esta fase.

No se implementaron reglas Java, SQL, MariaDB, inventario, pedidos, roles,
carrito, checkout ni APK. Los datos de ejemplo están exclusivamente en test/.

## Validación

flutter pub get
flutter analyze
flutter test
flutter build web

Las pruebas cubren transporte HTTP, errores, configuración ausente, formato de
productos inválido y navegación en 320x640, 390x844, 768x1024, 1024x768, 1440x900 y
568x320, con texto normal y al 200 %. Los fixtures no demuestran una conexión real.

## Siguiente paso

Obtener el endpoint real de productos de Java y una respuesta JSON real; verificar
su contrato (envoltorio, campos, tipos, paginación y rutas de imagen), configurar
CAVA_API_BASE_URL y CAVA_IMAGES_BASE_URL, comprobar CORS desde el origen Flutter
y probar MariaDB -> Servlet/API -> JSON -> Flutter. Resolver la estrategia de
sesión por separado antes de avanzar con autenticación.
