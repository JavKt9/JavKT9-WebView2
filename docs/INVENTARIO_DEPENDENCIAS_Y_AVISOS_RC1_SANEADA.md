# Inventario verificado de dependencias y avisos — RC1 saneada

**Fecha:** 11/10/2026. **Origen:** archivo real `JAVkt9_0.8.1_RC1_Setup_SANEADA_PRIVADA_Windows_x64.exe`, no una lista supuesta.

**SHA-256:** `b68f9b8ef5c57645115f01b3dcae1d1e0ac2b6176d4182a163200bc1658ae73c`. El instalador contiene **6.216 entradas**, de las que **6.213** corresponden al payload.

## Inventario de archivos empaquetados

| Grupo | Archivos | Tamaño sin comprimir |
| --- | ---: | ---: |
| Aplicación y código Perl GCstar/JAVkt9 (`lib/gcstar/`) | 1.112 | 5.850.499 bytes |
| Runtime Perl/GTK (`usr/`) | 4.255 | 190.258.540 bytes |
| Host WebView2 y runtime .NET (`bin/WebView2Host/`) | 472 | 169.579.829 bytes |
| Recursos GCstar (`share/gcstar/`) | 348 | 5.103.866 bytes |

El resto incluye ejecutables de arranque, archivos auxiliares y documentación.

## Licencias y atribuciones encontradas en el payload

Se localizaron exactamente **tres** archivos cuyo nombre corresponde a `LICENSE` o `AUTHORS`:

- `share/gcstar/LICENSE`: GNU GPL versión 2 del programa base.
- `share/gcstar/fonts/LICENSE`: SIL Open Font License 1.1 para la tipografía incluida.
- `share/gcstar/fonts/AUTHORS`: autores de la tipografía.

**No se encontraron archivos `LICENSE`, `LICENCE`, `COPYING`, `NOTICE` o `AUTHORS` para el resto de dependencias dentro del payload.** Esto es una falta de avisos identificados en el paquete, **no demuestra que esos componentes carezcan de licencia o sean ilegales**. Se deben obtener y distribuir los avisos exigidos por cada componente.

## Versiones demostradas por el propio archivo .deps.json

En `bin/WebView2Host/JavKT9WebView2.deps.json` figuran:

| Dependencia | Versión |
| --- | --- |
| Microsoft.Web.WebView2, Core, WinForms y Wpf | 1.0.3537.50 |
| Microsoft.NETCore.App.Runtime.win-x64 | 8.0.31 |
| Microsoft.WindowsDesktop.App.Runtime.win-x64 | 8.0.31 |

**Esto identifica las versiones, no certifica el derecho de redistribución.** El payload contiene además `WebView2Loader.dll` y `hostfxr.dll`; verificar avisos de Microsoft y la documentación de distribución antes de la release.

## Resultado sobre cabeceras del código Perl recuperado

Se examinaron los primeros 2.500 bytes de **1.081 archivos `.pm` y `.pl`** dentro del ZIP de fuentes que acompaña a este mismo instalador:

- **1.047** contienen mención de GPL.
- **18** contienen copyright sin mención de GPL en ese tramo: corresponden a traducciones `GCLang/*/GCModels/GCwines.pm`.
- **16** no muestran copyright ni GPL en ese tramo:
  - `lib/gcstar/GCDates.pm`
  - `lib/gcstar/GCExport/GCExportLatex.pm`
  - `lib/gcstar/GCImport/GCImportMyMovies.pm`
  - `lib/gcstar/GCJavDialogSkins.pm`
  - `lib/gcstar/GCJavPersonFavorites.pm`
  - `lib/gcstar/GCJavPersonFavoritesAdapter.pm`
  - `lib/gcstar/GCJavPersonFavoritesDialog.pm`
  - `lib/gcstar/GCJavSkins.pm`
  - `lib/gcstar/GCLang/DE/GCModels/GCwines.pm`
  - `lib/gcstar/GCLang/ID/GCModels/GCwines.pm`
  - `lib/gcstar/GCLang/NL/GCModels/GCwines.pm`
  - `lib/gcstar/GCLang/UK/GCModels/GCwines.pm`
  - `lib/gcstar/GCPlugins/GCbooks/GCSaraiva.pm`
  - `lib/gcstar/GCPlugins/GCfilms/GCJavLibrary.pm`
  - `lib/gcstar/GCPlugins/GCfilms/GCJavLibraryBridge.pl`
  - `lib/gcstar/GCPlugins/GCfilms/GCKinopoisk.pm`

**No se agregaron encabezados inventados ni se borraron créditos.** Una cabecera ausente no determina por sí sola la licencia del archivo.

## Código fuente disponible, paquete separado

Se preparó el archivo privado `JAVkt9_RC1_FUENTES_DISPONIBLES_Y_LICENCIAS_PRIVADAS.zip` (6.692.481 bytes, SHA-256 `fe39814bd0431ea011e77e81813011d6438a4761bf61ffbbf38760e58126ac68`). Contiene el ZIP de fuentes Perl/C# recuperadas, el fuente Go del instalador saneado, la receta local usada, los textos GPL y OFL/AUTHORS presentes en el payload y el inventario JSON. **No es el código fuente completo correspondiente a todos los binarios RC1** y no debe anunciarse como tal.

## Pendientes precisos, sin repetir pruebas anteriores

1. **Dos lanzadores Go antiguos:** obtener proyectos fuente originales o resolver sus obligaciones de redistribución según su naturaleza y licencia. Los lanzadores nuevos de otra rama no son prueba de correspondencia con los binarios RC1.
2. **PAR `gcstar.exe`:** localizar receta de empaquetado y fuentes correspondientes, con las dependencias aplicables.
3. **Terceros:** asociar paquetes/versiones/licencias y avisos a los 4.255 archivos de Perl/GTK, 472 del host .NET/WebView2 y recursos. Evitar atribuir licencias por suposición a archivos individuales.
4. **Instalador saneado:** prueba funcional acotada en Windows; no confundirla con la RC1 original que ya fue probada.
5. **Publicación:** el repositorio y la release siguen privados. La conexión actual no permite cargar el EXE de 167 MB como asset de release desde esta conversación.

**Conclusión:** inventario de dependencias y fuentes recuperadas **completado**; cumplimiento de redistribución pública **todavía no acreditado**. No tocar `main`, Bridge, WebView2 ni la instalación RC1 funcional.
