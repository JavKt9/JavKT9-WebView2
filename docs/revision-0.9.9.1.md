# JavKT9 0.9.9.1 — revisión de mantenimiento (en desarrollo)

Esta rama **no** representa JavKT9 1.0.0 y **no** modifica la versión publicada 0.9.9.

## Alcance acordado

- [x] **Títulos alternativos nuevos**: al importar datos de JavLibrary, si `original` empieza por el mismo ID que aparece en `title`, se elimina únicamente ese prefijo. Ejemplo: `ACHJ-084 A Black Daycare` pasa a `A Black Daycare`.
- [x] Mantener intactos los datos almacenados en colecciones existentes. No realizar migración masiva ni reinterpretar códigos distintos.
- [x] Pruebas unitarias de la regla de limpieza: `perl tests/alternative-title-cleanup.t`.
- [x] **Enlaces de modelos (código preparado)**: conserva cada URL completa visible en la tabla y permite abrirla con un clic mediante el lanzador del navegador de JavKT9. Preserva la edición y el almacenamiento de la lista. Pendiente validar visualmente en Windows.
- [ ] Verificar comportamiento en las interfaces Clásica, Moderna V1 y Moderna V2.
- [ ] Pruebas de instalación limpia y actualización antes de publicar una revisión preliminar.

## Dependencias para el cambio de hipervínculos

Se recibió `GCPanel.pm` desde una instalación existente y se incorporó a esta rama junto con `GCJavModelLinks.pm`. La lista de modelos se detecta por su etiqueta visible y se conecta al lanzador de URL ya usado en JavKT9. **No se reemplazó `GCPictureWidgets.pm`**, puesto que controla imágenes, no las listas de texto. Faltan pruebas de interfaz reales (GTK/Windows), especialmente comprobación de selección para editar o quitar. Para cotejar la definición técnica del campo y el widget completo puede ser útil incorporar `GCGraphicComponents/GCWidgets.pm` y el modelo de colección exacto.

## Límites

No crear instalador, etiqueta, release ni fusionar la rama hasta completar pruebas de uso en Windows y comprobar que los datos `.gcs` existentes se conservan.

## Pruebas

```sh
perl -c app/lib/gcstar/GCJavTitleCleanup.pm
perl tests/alternative-title-cleanup.t
```

## Ajuste visual posterior a prueba de usuario

La primera prueba en Windows confirmó que abrir las URL funcionaba, pero el texto no se reconocía como hipervínculo y un clic abría el navegador incluso cuando se quería seleccionar la fila.

- **Hipervínculos:** URL completa, subrayado azul (tono adaptado al fondo claro/oscuro), doble clic o Enter abre el navegador. Un clic selecciona para editar o usar Remove.
- **Títulos alternativos de fichas antiguas:** mostrar el título sin código duplicado, pero conservar el valor original sin reescribir el archivo .gcs hasta que la persona edite ese campo. Los nuevos metadatos importados se normalizan en GCMainWindow.
- Se generó un segundo ZIP de prueba con `GCPanel.pm`, `GCJavModelLinks.pm` y `GCJavTitleCleanup.pm` (no instalador completo).
- Se ejecutaron pruebas de Perl de ambos módulos y pruebas simuladas del panel para comprobar tanto el orden de actualización de los campos como la conservación de valores originales. **Falta validar los controles en el GTK de Windows**.

## Ajuste de altura de listas (V3)

En la prueba de usuario, las secciones `Cast (5)` y `Enlaces de modelos (5)` mostraban únicamente dos filas y obligaban a usar desplazamiento interno. `GCPanel.pm` ahora ajusta la altura del `Gtk3::ScrolledWindow` de ambas listas según su modelo, con un mínimo de 2 filas y un máximo de 12. Cinco elementos se ven completos; las listas muy largas conservan el desplazamiento. También recalcula al agregar/quitar entradas y al cambiar de ficha, sin modificar el contenido de las colecciones. Se comprobó sintaxis con dependencias GTK simuladas y se ejecutaron 23 pruebas locales de regresión de la revisión, **no equivalentes a una ejecución real en Windows**. ZIP de prueba V3 preparado, sin publicar ni fusionar.

## Ajuste de altura y clic sencillo (V4)

Nueva prueba visual del usuario: con dos actrices, la segunda aparecía cortada; con cinco actrices y cinco enlaces, la última fila seguía oculta. El cálculo de alto anterior resultaba insuficiente en esa instalación. Se amplió la reserva por fila a 44 unidades GTK, con cabecera 44 y margen 12, manteniendo el máximo de 12 filas antes del desplazamiento interno. La apariencia final requiere validación en Windows.

Los enlaces ahora se abren con un clic sobre la **URL subrayada**; hacer clic en el espacio vacío del renglón conserva la selección para editar o quitar sin abrir el navegador. Enter sobre la fila enfocada también abre. Prueba sintáctica de Perl realizada con dependencias GTK simuladas; 13 verificaciones locales de la función de altura y helpers superadas. No equivale a la prueba funcional bajo Windows.

## Portada ampliada y cabecera de ficha (V5)

Al abrir la ficha emergente de una película, la miniatura de portada resultaba muy pequeña y la barra de título podía no respetar la paleta del programa. Se agregó a `GCDialogs.pm` una mejora exclusiva de `GCItemWindow`: el botón de portada solicita 245 × 225 píxeles y mantiene la escala proporcional del dibujo original. La cabecera utiliza `GCJavTitleBar`, que ya existe en el CSS de las interfaces, y reutiliza el proveedor de estilos del título principal cuando está disponible. Se conservan los botones de diálogo y todas las acciones de la ficha.

Se preparó un ZIP V5 con un aplicador puntual que crea respaldo de `GCDialogs.pm` antes de modificarlo; verifica tres anclajes de la clase original y se niega a cambiar una versión incompatible. No requiere reemplazar los módulos V4. **No se ha validado todavía en Windows** la apariencia del diálogo, su cabecera o su tamaño de portada; el PR sigue siendo borrador.

## Corrección de objetivo: portada del panel principal (V6)

La captura de usuario confirmó que la portada solicitada era la del **panel derecho de la ventana principal**, no la ventana emergente `GCItemWindow`. En V6 se modificó `GCPanel.pm`, al final de `GCItemPanel::createContent`, después de la lectura del layout, comprobando con `Scalar::Util::refaddr` que se trata de `GCFrame->{panel}` y de un `GCFormPanel`. Solo el `GCImageButton` asociado a `commonFields.cover` se ajusta a 235 × 250. `GCItemImage` utiliza `GCUtils::scaleMaxPixbuf` para preservar proporciones. El parche V6 **no modifica barra de título ni tema** y mantiene las demás correcciones V4.

ZIP V6 preparado con un único archivo reemplazable `GCPanel.pm` y las instrucciones de respaldo/restauración. Sintaxis Perl verificada con dependencias GTK simuladas; 2 pruebas de discriminación de panel principal vs ventana emergente aprobadas. **Pendiente validación en Windows**.

## V7: evitar deformación de los campos laterales

La validación de usuario del V6 mostró que el tamaño fijo **235 × 250** de la portada alteraba las dimensiones de los campos contiguos (fecha, director y duración). Se elimina la llamada `setHeight(250)` y se mantiene la **altura natural definida por el layout**; el ancho de la portada pasa a **180**. De ese modo la fila deja de forzarse verticalmente. V7 conserva las funciones de lista, títulos y enlaces, y no toca la barra de título. Verificada la sintaxis de `GCPanel.pm` con las dependencias GTK simuladas disponibles en el entorno, así como que V7 solo difiere de V6 en ese bloque. Pendiente comprobar el aspecto en Windows.

Parche V7: reemplazo de un archivo `app/lib/gcstar/GCPanel.pm`, copia de seguridad local manual previa e instrucciones de restauración; no instalador.

## V8: ampliar visor View Picture y colorear su cabecera

El usuario aprobó el tamaño de la portada en la ficha principal (V7) y pidió mejorar **exclusivamente el diálogo que se abre al hacer clic en la imagen**, titulado `View Picture`. En `GCDialogs.pm`, `GCImageDialog` mantenía un tamaño inicial fijo de 500×500, responsable de mostrar la imagen relativamente pequeña en el visor. La revisión calcula el tamaño inicial a partir de la imagen original y la pantalla, con un máximo de 800 px de ancho y 650 px de alto para la imagen, conservando proporción y sin ampliar imágenes de baja resolución. Además configura `Gtk3::HeaderBar` con nombre `GCJavTitleBar` para reutilizar el estilo visual de la ventana principal, incluyendo su proveedor CSS cuando está disponible.

El ZIP V8 incluye **solo** un aplicador PowerShell/CMD que modifica la clase `GCImageDialog` dentro del `GCDialogs.pm` instalado y guarda una copia fechada antes de escribir. No sustituye otros módulos ni altera las colecciones. El aplicador revisa las estructuras esperadas y cancela si el archivo es distinto. Comprobaciones locales: sintaxis Perl de fragmentos y cuatro escenarios de dimensionamiento con imágenes horizontales/verticales aprobados; verificación de integridad del ZIP aprobada. **Falta prueba visual y funcional real en Windows**, especialmente los colores de cabecera.

## V9: Favoritos de personas con mayor espacio

A pedido del usuario, el diálogo de actores y directores favoritos (`GCJavPersonFavoritesDialog.pm`) pasa de tamaño inicial fijo `740 × 620` a `980 × 740` cuando la pantalla lo permite, con límites de tamaño respecto de la resolución y posibilidad de ajustar las dimensiones manualmente. Se aumenta la altura mínima de la lista de personas a 200 y la de películas relacionadas a 190. Los datos del catálogo, favoritos, previsualizaciones y colores del tema no se modifican. La documentación está incorporada al manual HTML y las notas de la revisión.

ZIP V9: aplicador puntual de un único archivo, que guarda respaldo local y rechaza archivos cuyos anclajes no coincidan. **Pendiente prueba visual bajo Windows** en ambas pestañas de favoritos. No publicar todavía.

## V10: Favoritos de personas adaptados a monitores grandes

Una prueba de usuario en pantalla grande mostró que el tamaño inicial V9 (980 × 740) ocupaba aproximadamente una cuarta parte del ancho visible. En V10, el diálogo ajusta sus dimensiones al **65 % del ancho y 73 % del alto** de la pantalla, con límites de **2000 × 1350 px**, márgenes para Windows y tamaño mínimo prudente en pantallas más pequeñas. Se mantiene la capacidad de redimensionar manualmente y no se modifican datos ni funcionalidad de favoritos. Ejemplos estimados: 1920×1080 → 1248×788; 2560×1440 → 1664×1051; 3840×2160 → 2000×1350.

Se preparó ZIP de prueba V10 que cambia únicamente el bloque de dimensionamiento de `GCJavPersonFavoritesDialog.pm` y guarda un respaldo con fecha. El aplicador rechaza instalaciones que no tengan el bloque V9 esperado; no afecta otros componentes. Comprobado que la sustitución de código V9→V10 reproduce exactamente el módulo guardado en esta rama y que los cálculos respetan límites para las resoluciones ensayadas. **Falta validación real en Windows** antes de fusionar o publicar.

## Manual completo revisado (edición de documentación)

Se revisó el manual HTML histórico y actual de 0.9.9.1 para corregir el número de capítulo a **17** (el capítulo 16 original sigue siendo «Instalación, Acerca de y protección de datos»), clarificar qué es histórico 0.9.9 y qué pertenece a 0.9.9.1, y consignar que Favoritos V10 fue validado en monitor grande. Se generó una edición PDF de consulta con 16 páginas y navegación por marcadores. El PDF se entrega por separado y no ha sido incorporado todavía al instalador o a la rama GitHub como archivo binario. **La ayuda HTML es la fuente oficial integrada en el repositorio**.

## Incidencia pendiente: `perl.exe` permanece tras cerrar con X

El usuario confirmó que, al cerrar JavKT9 con el botón X de Windows, una instancia de `perl.exe` continúa visible en el Administrador de tareas. Por ahora no se sabe si se trata del proceso principal, de un proceso auxiliar del Bridge de JAVLibrary o de un Perl ajeno al proyecto. No se debe terminar indiscriminadamente por nombre.

**Pistas de código revisadas:** `GCMainWindow.pm` conecta `delete_event` con `beforeDestroy`, que ejecuta `leave`; una salida correcta debe llegar al `destroy` y a `Gtk3->main_quit`. Asimismo, `gcjavEnsureBridge` puede iniciar `GCJavLibraryBridge.pl` mediante Perl y `gcjavStartBridgeAsync` puede lanzar el Bridge de forma independiente; el flujo de cierre no evidencia una parada explícita de estos servicios. Se requiere identificar el PID, la línea de comandos y el estado del puerto 53118 **después del cierre** para determinar la causa real.

Se preparó un ZIP diagnóstico **solo de lectura** que lista los procesos `perl.exe`/`perlw.exe`/`gcstar.exe`/`JavKT9.exe` y el propietario del puerto 53118. No elimina ni detiene procesos, y guarda un reporte `JavKT9_diagnostico_procesos.txt` en el Escritorio. Esperar ese reporte antes de diseñar la corrección de cierre para 0.9.9.1. Mientras tanto, el parche de manual y Acerca de cancela la instalación si detecta la aplicación aún activa, evitando actualizar archivos en uso.

## V11: primera prueba de cierre cooperativo del Bridge

**Diagnóstico confirmado por el usuario (22-11-2026, 15:11 -03):** tras cerrar JavKT9 con X seguía activo un `perl.exe` PID 24360, ejecutando `C:\\Program Files\\JavKT9\\app\\lib\\gcstar\\GCPlugins\\GCfilms\\GCJavLibraryBridge.pl`, con el puerto `127.0.0.1:53118` asociado a ese PID. No es un Perl genérico: es el servicio auxiliar de metadatos del programa.

En `GCMainWindow.pm`, `leave` no solicitaba apagar ese servicio. La prueba V11 añade una petición de apagado **después** de guardar preferencias/datos y antes de destruir la ventana; solo cuando el servicio en puerto 53118 identifica `bridge_version` en `/version`, envía `/shutdown`. La lectura del socket tiene tiempo acotado y no se utiliza `taskkill` ni se finalizan procesos por nombre. El proceso principal puede cerrar incluso si el Bridge no responde.

**Advertencia:** la fuente instalada `GCJavLibraryBridge.pl` no está versionada en este repositorio. Se desconoce si su `/shutdown` está implementado. La V11 es una prueba conservadora, **no una corrección validada**. Si tras probar sigue existiendo el proceso Perl, solicitar la copia de ese `.pl` y reparar el cierre desde el propio servicio, sin matar PID arbitrarios.

ZIP V11 con aplicador PowerShell/CMD que afecta solo `GCMainWindow.pm` y crea copia local con fecha antes de escribir. Sintaxis de las rutinas Perl del parche verificada en entorno local; falta prueba funcional en Windows. No publicar ni fusionar antes de verificar cierre y reabrir la aplicación.

## V12: apagado autenticado del Bridge con el protocolo real

El usuario aportó `GCJavLibraryBridge.pl` 2.3.1-webview2-lifecycle (160 líneas aprox.). La causa del fallo V11 fue **doble**: (1) `/shutdown` exige `?key=...` y rechaza la solicitud sin clave con HTTP 403; (2) `/version` devuelve `2.3.1-webview2-lifecycle` y la validación V11 no aceptaba el sufijo. El Bridge acepta la orden solo con `JAVKT9_BRIDGE_SESSION` heredado y mínimo 32 caracteres; al recibirla marca `shutdown_requested`, responde 200 y finaliza su bucle principal.

V12 modifica `GCMainWindow.pm` para detectar ese formato de versión, leer la clave **solo de su variable de entorno**, codificarla para URL y enviar `/shutdown?key=...`. La rutina verifica HTTP 200/403 y registra mensajes sin imprimir ni almacenar la clave. Si el proceso principal no hereda `JAVKT9_BRIDGE_SESSION`, cancela la orden sin reducir la protección del Bridge y deja un aviso en `gcstar.log`. No usa `taskkill` ni terminación de procesos por PID.

Se incorporó al repositorio el `GCJavLibraryBridge.pl` original que faltaba en `app/lib/gcstar/GCPlugins/GCfilms/`. Se verificó **un test funcional real en entorno aislado**: `/version` 200; `/shutdown` sin clave 403; con clave incorrecta 403; con clave válida 200 y el Bridge termina con código 0. El cliente Perl V12 también completó el apagado de ese Bridge real en el entorno de pruebas. El aplicador Windows de V12 respalda `GCMainWindow.pm`, altera solo la rutina V11 y el control de URL, no cambia el Bridge ya instalado ni los archivos `.gcs`.

**Pendiente en Windows:** instalar V12, cerrar una instancia heredada/orfandad de Bridge anterior solo después de verificar su línea de comandos, iniciar JavKT9 normalmente, cerrar con X y repetir diagnóstico. Si persiste: leer el mensaje `JavKT9 V12` en `gcstar.log` para distinguir token ausente de sesión rechazada. En ese caso falta el origen del token (`Iniciar-JavKT9.cmd` o launcher), no modificar el contrato autenticado del Bridge.

## Recuperación del ejecutable tras detección de Defender (24/11/2026)

Microsoft Defender puso `C:\\Program Files\\JavKT9\\JavKT9.exe` en cuarentena bajo `Trojan:Win32/Bearfoos.A!ml`. Incluso una copia anterior a V11/V12 quedó bloqueada. El código del ejecutable original no está en el repositorio; **no es posible afirmar que se haya reconstruido el original**. Tampoco restaurar ni excluir la versión detectada sin un dictamen de seguridad.

Se creó un **lanzador nuevo, verificable y de alcance limitado**, en `src/JavKT9Launcher/Program.cs` y `JavKT9Launcher.csproj`. Es un programa .NET 8 WinExe autónomo que ejecuta el Perl empaquetado `app/bin/perl.exe` con `app/bin/gcstar`, hereda el entorno del llamador, establece rutas al runtime y transmite una clave aleatoria de sesión `JAVKT9_BRIDGE_SESSION` a Perl y Bridge para su cierre autenticado. No incluye el ejecutable antiguo, no modifica Perl ni el registro, no usa PowerShell y no toca las colecciones.

El workflow `.github/workflows/build-launcher-recovery-0991.yml` compiló con éxito en GitHub Actions Windows:
- Run: `https://github.com/JavKt9/JavKT9-WebView2/actions/runs/45366244135`.
- Artifact de PRUEBA: `JavKT9-launcher-0.9.9.1-RECUPERACION-PRUEBA`, ID 14906847987.
- SHA-256 del `JavKT9.exe` compilado: `24648D928A0F5DFFDA8E11E093171F85FE6E8E2C322E697715462D07D28843A8`.
- EXE de ~67,5 MB, .NET8 self-contained single-file, sin firma digital.
- El ZIP descargado contiene únicamente `JavKT9.exe`, `SHA256.txt` y `LEEME.txt`. Su integridad se verificó releyendo el ZIP y recalculando SHA-256 en el entorno de trabajo.

**No certificado:** no hubo prueba funcional dentro de la instalación real de Windows ni dictamen de Microsoft sobre el nuevo EXE. Indicaciones: respaldar toda la carpeta del programa y datos .gcs; extraer el ZIP y analizar `JavKT9.exe` con Defender; si no genera alertas y coincide el hash, copiar solo EXE a la instalación (sin sobrescribir `app`, `lib`, `share`, `bin`), y probar. Ante cualquier nueva alerta, detener y no restaurar/excluir. Si la aplicación falla, revisar `%LOCALAPPDATA%\\JavKT9\\JavKT9-launcher-recovery.log`. Mantener PR en borrador, sin publicar actualización.
