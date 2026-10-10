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

El plugin `GCJavLibrary.pm` inicia `GCJavLibraryBridge.pl` directamente con `wperl.exe`. **Pero** una revisión más amplia detectó que `GCMainWindow.pm` también contiene una función heredada que busca `bin/GCJavBridgeLauncher.exe`. Por compatibilidad, incorporamos **`src/public-bridge-launcher/`**, un segundo lanzador Go nuevo y libre, que inicia el mismo script Perl. El paquete privado **sustituye los dos ejecutables Go antiguos**, sin incluir sus binarios originales. La nueva implementación todavía requiere validación funcional en Windows.

## Host WebView2 de la edición pública (copia separada)

`src/public-webview2/` contiene una **copia separada** del proyecto C# del repositorio. Los originales de `src/JavKT9WebView2/` **no fueron modificados**.

Esta variante cambia únicamente la resolución de la carpeta de datos locales para que el host use la misma `LOCALAPPDATA` aislada que el Bridge Perl recibe del lanzador Go. Sin este ajuste, .NET puede consultar la carpeta especial de Windows e ignorar la variable de entorno, provocando que la captura HTML termine en otra carpeta. Si se ejecuta el host por separado, elige igualmente un perfil de desarrollo separado, no el de la RC1.

El host se compila en el mismo workflow privado, en `build/WebView2Host/`. **Todavía falta confirmar la integración completa en Windows.** No copiar este host sobre la RC1 instalada.

## Construcción del lanzador

En Windows con Go 1.23.2:

```powershell
cd src/public-launcher
go test ./...
$env:GOOS='windows'; $env:GOARCH='amd64'; $env:CGO_ENABLED='0'
go build -trimpath -ldflags="-H windowsgui" -o ../../build/JavKT9.exe .
```

En Linux se verificó la compilación cruzada para Windows/amd64 y las pruebas unitarias. Esto **no equivale** a probar la ejecución con el entorno GTK/WebView2 en Windows.

El workflow `.github/workflows/compilar-edicion-publica-desarrollo.yml` compila el lanzador Go y el host WebView2 separado en Windows, ejecuta las pruebas del lanzador y guarda **artefactos privados de desarrollo**, sin publicarlos como release.

## Alternativa para retirar el PAR original

El nuevo lanzador principal también acepta `--source-mode`: en vez de ejecutar `bin/gcstar.exe` (PAR), invoca `bin/wperl.exe bin/gcstar` y usa el script Perl recuperado de la RC1. El ZIP portátil privado incorpora el acceso `JavKT9-Fuentes.cmd` para este modo.

**Este modo está compilado y probado a nivel unitario, pero todavía NO está validado en Windows con GTK y WebView2.** Si la ejecución directa desde fuentes funciona, podríamos preparar la distribución pública sin incluir el PAR antiguo y eliminar así una parte importante del bloqueo de compilación. No se afirma todavía que ambas variantes sean funcionalmente equivalentes.

El workflow privado intenta armar `JAVkt9_Edicion_Publica_Desarrollo_PORTABLE_PRIVADO.zip` con los nuevos ejecutables, conserva el motor GCstar original para comparación y **no publica una release**.

## Pendientes para una descarga pública funcional

1. Comprobar en Windows que el nuevo lanzador y el host WebView2 separado inician el programa y que la captura del Bridge coincide con el perfil aislado. **No usar la RC1 instalada para estas pruebas.**
2. Definir un paquete autónomo con su propio nombre y ruta de instalación, sin reutilizar el instalador Beta 1 ni sobrescribir la RC1.
3. Resolver derechos, licencias y avisos de `payload/usr/`, `payload/share/gcstar/`, .NET/WebView2 y demás componentes que se distribuyan.
4. Documentar y proporcionar los fuentes correspondientes al PAR `gcstar.exe` y la receta de construcción. No declarar que es completamente reproducible hasta verificarlo.
5. Escanear el paquete final, revisar la cadena de compilación y preparar instrucciones para usuarios finales.

**No publicar el ZIP RC1 como si fuera la nueva edición. No fusionar esta rama con `main` ni cambiar la visibilidad del repositorio.**
