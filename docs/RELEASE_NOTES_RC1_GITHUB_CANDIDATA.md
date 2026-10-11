# JAVkt9 0.8.1 RC1 — Candidata integrada para GitHub

**Estado 11/10/2026: LISTA PARA REVISIÓN PRIVADA. NO PUBLICADA.**

Se preparó **un único instalador Windows x64** que integra las correcciones de la edición experimental aprobadas por el usuario. No requiere aplicar parches manuales después de instalar. El programa original y la instalación experimental no se sobrescriben.

## Descargas preparadas localmente

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `JAVkt9_0.8.1_RC1_GITHUB_CANDIDATA_Setup_Windows_x64.exe` | **183.284.984 bytes** | `bb45bce1024598abc9688bc20abedc7083ac3ad103bd470ae619a11640f5ff88` |
| `JAVkt9_0.8.1_RC1_GITHUB_CANDIDATA_CODIGO_DISPONIBLE.zip` | **7.074.042 bytes** | `fb67432582f6c0d0ed508550d664038bd4cd5e2c34500b6433a20e6c87597d46` |
| `JAVkt9_0.8.1_RC1_GITHUB_CANDIDATA_PAYLOAD.zip` (intermedio, no distribuir) | **180.186.360 bytes** | `3743d34d005d9aecfbf4535f519619954e09d5d77392a377cfc80a8c11f6bc87` |
| `JAVkt9_0.8.1_RC1_GITHUB_CANDIDATA_FUENTES.zip` (incluido en el EXE) | **7.403.145 bytes** | `53e20b4ef9a9a7be33624527c8123ba47384e3507e119c3d18c339d5d299e104` |

El **fuente Go exacto del instalador** está en `src/instalador-rc1-github/main.go`; su Git blob SHA-1 es `36b18aae8a1669614815e8ac8af0e7427f81d6c8`. El ZIP integrado en el Setup contiene **6.221 entradas**. Se verificaron los CRC y el SHA-256 del payload adjunto.

## Correcciones integradas y ya probadas en la instalación experimental

- Búsqueda e importación WebView2: el usuario importó **dos películas** después del ajuste de rutas de captura.
- Bridge: cierre seguro por token de sesión y recuperación de procesos `wperl.exe` huérfanos de la propia instalación.
- Ícono de JAVkt9 en ventana y barra de tareas; apertura maximizada.
- Ficha compacta con carátula a la izquierda y Fecha/Director/Duración alineados.
- Persistencia de paneles Géneros, Actores y Enlaces de modelos entre aperturas.
- Panel izquierdo con ancho razonable al maximizar.
- Columna de estrella de Actores pequeña, sin activar favoritos desde toda la fila.

**Importante:** las pruebas del usuario fueron con el **instalador experimental más parches**. El **Setup integrado nuevo** se compiló y pasó verificación de contenido, pero **todavía no se instaló en Windows**. No afirmar que ese nuevo instalador pasó una prueba de instalación real.

## Instalación

- Windows x64, preferentemente Windows 10/11.
- Ruta propia: `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-GitHub-Candidata`.
- Acceso directo en **Inicio**, entrada en Aplicaciones instaladas para desinstalar.
- **No importa automáticamente películas ni configuración de otras ediciones.** Una biblioteca nueva aparecerá vacía.
- **No abrir dos ediciones simultáneas:** comparten el puerto local `53118`.
- Requiere Microsoft Edge WebView2 Runtime disponible en el equipo; no confundir el SDK incluido con el runtime Evergreen.
- **EXE sin firma digital:** Windows SmartScreen puede mostrar advertencia. No se ha adquirido certificado de firma.

## Fuentes y licencias — bloqueos de publicación pública

- Los **dos lanzadores Go nuevos** y los Perl modificados tienen código fuente disponible, coincidente por SHA de Git blob con los archivos del instalador.
- El **fuente del instalador** y su receta de compilación están disponibles.
- **Falta cerrar la correspondencia del ejecutable PAR `gcstar.exe`**: la receta exacta de empaquetado y la relación completa con sus dependencias no están verificadas.
- **Falta completar los avisos y licencias exigidos por dependencias de Perl/GTK y .NET/WebView2.** El ZIP de fuentes se denomina «código disponible», **no «fuentes completas»**.
- El repositorio `JavKt9/JavKT9-WebView2` continúa **privado**; la release `v0.8.1-rc1` existente está en **borrador** y conserva el antiguo ZIP portable, no el nuevo instalador.

## Procedimiento de publicación en GitHub

1. **No subir el instalador anterior** que aún contenía cuatro claves antiguas. La candidata integrada parte del ZIP saneado y se verificó que los cuatro módulos TheMovieDB no contienen claves literales.
2. Completar los pendientes de licencia/fuentes y una instalación de humo del Setup integrado nuevo en Windows.
3. Abrir la release borrador: https://github.com/JavKt9/JavKT9-WebView2/releases/tag/v0.8.1-rc1 . Adjuntar **el EXE integrado y el ZIP de código disponible**, actualizar la descripción con estas notas y el SHA-256. Retirar/reemplazar el asset antiguo no saneado para que nadie descargue la versión equivocada.
4. Cuando se confirme cumplimiento y prueba final, publicar la release y cambiar visibilidad del repositorio a **Public** en `Settings → General → Danger Zone → Change repository visibility`. Revisar antes si hay secretos en el historial, ya que cambiar visibilidad expone todo el historial.
5. Verificar desde una ventana anónima que el EXE y los avisos son descargables.

**La conexión de GitHub disponible en este chat permite editar código y PR, pero no subir archivos binarios como assets ni cambiar la visibilidad del repositorio.** El archivo EXE está listo localmente; no afirmar que ya está publicado.

## Trazabilidad

La rama `rc-0.8.1-github-candidata-integrada` contiene los Perl modificados y el Go del instalador con **Git blob SHA idénticos a los archivos empaquetados**, además de los fuentes del nuevo lanzador y BridgeLauncher. Se añadió una CI de compilación de fuentes y comprobaciones XML/Bridge; su ejecución remota debe verificarse antes de declararla aprobada.
