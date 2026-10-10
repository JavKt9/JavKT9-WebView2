# Auditoría inicial de licencias y distribución — RC1

**Estado: INCOMPLETO. No autoriza publicar el repositorio ni el instalador.** Revisión estática del ZIP RC1 aportado, el paquete de fuentes recuperadas y la rama privada al 10-10-2026. No es un dictamen jurídico.

## Base y atribuciones comprobadas

- `LICENSE` del repositorio contiene el texto íntegro de **GNU GPL versión 2 (junio de 1991)**.
- `NOTICE.md` reconoce GCstar y «Modificaciones JAVkt9 © 2026 kt9».
- El encabezado de `src/perl/bin/gcstar`, `src/perl/par_embebido/script/gcstar.pl` y otros módulos de GCstar declara **GPL versión 2 o posterior**, con copyright de Christian Jodar y otros autores.
- En una revisión automática de los primeros 2.500 bytes de **1.081** archivos Perl `.pm` y `.pl` recuperados: **1.047** mencionan GPL, **18** contienen copyright sin mencionar GPL en ese tramo y **16** no muestran ninguno de esos avisos en ese tramo. Es una clasificación orientativa, **no** un veredicto sobre la licencia de cada archivo. Revisar individualmente los 34 restantes antes de publicar.
- El paquete RC1 incluye una tipografía Liberation Sans y el archivo `payload/share/gcstar/fonts/LICENSE` que indica **SIL Open Font License 1.1**, junto con `AUTHORS` y `README`. Conservar esa licencia y atribuciones si se redistribuye la tipografía; **no** tratarla como GPL.

## Inventario por componentes de la distribución RC1

| Componente | Hallazgo verificado | Pendiente |
| --- | --- | --- |
| GCstar/Perl | 1.115 archivos en `src/perl/` con cuatro claves heredadas retiradas | Revisar avisos por archivo, fuentes complementarias y cambios realizados |
| Recursos GCstar | **348** archivos en `payload/share/gcstar/` (incluyen imágenes, temas, logos, tipografía, licencia y metadatos) | Revisar derechos de cada recurso; **no** se han incorporado a GitHub |
| Perl/GTK y dependencias | `payload/usr/lib/`: **3.784** archivos; `payload/usr/bin/`: **58**; `payload/usr/share/`: **413** | Identificar paquetes/versiones/licencias y conservar avisos de terceros; verificar fuente correspondiente según cada licencia |
| Host .NET/WebView2 | `payload/bin/WebView2Host/`: **472** archivos (incluye runtime/dependencias .NET) | Confirmar condiciones de redistribución de Microsoft, versiones y avisos; verificar compilación del host |
| WebView2 SDK | `Microsoft.Web.WebView2` versión **1.0.3537.50** en `.csproj` | Comprobar avisos del paquete NuGet y requisitos del WebView2 Runtime |
| Lanzadores `.exe` | `JavKT9.exe` y `GCJavBridgeLauncher.exe` en RC1 | **No están los proyectos fuente originales**; bloquear afirmación de fuente completa |
| PAR `gcstar.exe` | Contiene `script/gcstar.pl` con versión interna **1.7.3**; el `bin/gcstar` plano declara **1.8.1.RC-db9844e3** | Reconstruir receta PAR y explicar cuál script se empaquetó; **no** sustituir uno por el otro |
| Instalador | `installer/JavKT9.iss` corresponde a **0.8.0 Beta 1** y usa `{autopf}\\JavKT9` | **No utilizar para RC1**: podría afectar a la instalación estable |

El ZIP RC1 contiene una imagen de donaciones `JAVkt9-binance-pay.jpg` y logos/imágenes de terceros. La licencia GPL del código no concede automáticamente permiso sobre marcas, imágenes, tipografías u otros activos.

## Condiciones y decisiones antes de hacer público

1. **Código fuente correspondiente:** para los componentes GPL distribuidos como binarios, localizar los fuentes exactos, interfaces y scripts de compilación/instalación. Un ejecutable ya compilado no sustituye su fuente. Véase GPLv2 §3 y las FAQ oficiales de GNU: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html y https://www.gnu.org/licenses/gpl-faq.html
2. **No asumir una compilación idéntica byte a byte:** lo importante es la correspondencia del código y la posibilidad real de construirlo; diferencias de compilador o marcas de tiempo pueden alterar hashes. Esto no excusa fuentes ausentes.
3. **Microsoft WebView2:** el SDK, el Runtime y las bibliotecas .NET son componentes distintos. Revisar documentación y términos de distribución: https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution
4. **Dependencias Perl/GTK:** generar una lista de paquetes/versiones y sus avisos desde el entorno original; el directorio `usr` no incluye por sí solo un inventario completo de licencias.
5. **Recursos:** conservar licencias específicas y verificar logos, capturas, temas y recursos originales. No subir perfiles, cookies, colecciones, imágenes personales ni claves.
6. **Historial:** escanear toda la rama e historial. Gitleaks sin hallazgos **no** equivale a revisión legal ni privacidad completa.
7. **Publicación:** mantener el repositorio privado, `main` intacta y RC1 en borrador hasta resolver los bloqueos.

## Archivos concretos que requieren revisión manual de cabeceras

Entre los **16** archivos sin mención visible a GPL/copyright en los primeros 2.500 bytes están:
`GCDates.pm`, `GCJavSkins.pm`, `GCJavDialogSkins.pm`, `GCJavPersonFavorites.pm`, `GCJavPersonFavoritesAdapter.pm`, `GCJavPersonFavoritesDialog.pm`, `GCPlugins/GCfilms/GCJavLibrary.pm` y `GCPlugins/GCfilms/GCJavLibraryBridge.pl`. La ausencia de cabecera en ese tramo **no prueba** que carezcan de licencia, pero conviene añadir avisos correctos sin borrar créditos previos.

**Resultado:** fuentes Perl y GPL base identificadas; la redistribución completa de la RC1 todavía no está auditada.
