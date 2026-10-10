# Edición pública de JAVkt9 — desarrollo aislado

**Estado: preparación técnica privada. No hay instalador ni release pública todavía.**

Esta rama `edicion-publica-desarrollo` se creó desde `fuentes-rc1-auditoria` para preparar una versión distribuible **sin alterar la RC1 funcional**.

## Primer componente recuperado con código nuevo

`src/public-launcher/` contiene un **lanzador Go nuevo, escrito desde cero**, bajo GPL-2.0-or-later. **No** se presenta como el código original del `JavKT9.exe` de la RC1. Compila con Go 1.23.2 y usa solo la biblioteca estándar.

El lanzador:

- Busca `bin/gcstar.exe`, `bin/wperl.exe`, los directorios GTK y el host WebView2 en un paquete con estructura de `payload/`.
- Ajusta PATH, GI_TYPELIB_PATH, GSETTINGS_SCHEMA_DIR y LANG **solo para el proceso hijo**.
- Aísla APPDATA y LOCALAPPDATA de la edición de desarrollo bajo `JavKT9-Publica-Desarrollo/Runtime` para no compartir perfiles de la RC1.
- Rechaza iniciar si el puerto 53118 ya está ocupado: el Bridge Perl existente usa ese puerto y **no se ha modificado**. Esta protección impide usar las dos ediciones simultáneamente.
- Registra errores en `%LOCALAPPDATA%\\JavKT9-Publica-Desarrollo\\Launcher\\errores.log`; en Windows muestra un mensaje.
- No modifica ni reemplaza instalaciones y no ejecuta instaladores.

El plugin `GCJavLibrary.pm` ya inicia `GCJavLibraryBridge.pl` con `wperl.exe`. Por ello **no se necesita incluir el antiguo `GCJavBridgeLauncher.exe`** en la futura edición pública, siempre que las pruebas de integración lo confirmen.

## Construcción del lanzador

En Windows con Go 1.23.2:

```powershell
cd src/public-launcher
go test ./...
$env:GOOS='windows'; $env:GOARCH='amd64'; $env:CGO_ENABLED='0'
go build -trimpath -ldflags="-H windowsgui" -o ../../build/JavKT9.exe .
```

En Linux se verificó la compilación cruzada para Windows/amd64 y las pruebas unitarias. Esto **no equivale** a probar la ejecución con el entorno GTK/WebView2 en Windows.

El workflow `.github/workflows/compilar-edicion-publica-desarrollo.yml` compila el lanzador en Windows, ejecuta sus pruebas y genera un artefacto **privado de desarrollo**, sin publicarlo como release.

## Pendientes para una descarga pública funcional

1. Comprobar en Windows que el nuevo lanzador inicia el programa y que el Bridge/WebView2 funciona con el perfil aislado. **No usar la RC1 instalada para estas pruebas.**
2. Definir un paquete autónomo con su propio nombre y ruta de instalación, sin reutilizar el instalador Beta 1 ni sobrescribir la RC1.
3. Resolver derechos, licencias y avisos de `payload/usr/`, `payload/share/gcstar/`, .NET/WebView2 y demás componentes que se distribuyan.
4. Documentar y proporcionar los fuentes correspondientes al PAR `gcstar.exe` y la receta de construcción. No declarar que es completamente reproducible hasta verificarlo.
5. Escanear el paquete final, revisar la cadena de compilación y preparar instrucciones para usuarios finales.

**No publicar el ZIP RC1 como si fuera la nueva edición. No fusionar esta rama con `main` ni cambiar la visibilidad del repositorio.**
