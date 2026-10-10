# Estado de la edición pública — 10 de octubre de 2026

**En preparación. No publicada.** Esta rama es distinta de la auditoría de la RC1 y no sustituye los binarios originales.

| Componente | Edición pública nueva | Estado |
| --- | --- | --- |
| Lanzador `JavKT9.exe` | Código Go nuevo en `src/public-launcher/` | Pruebas unitarias y compilación cruzada Windows/amd64 superadas localmente; integración Windows pendiente |
| Lanzador `GCJavBridgeLauncher.exe` | Código Go nuevo en `src/public-bridge-launcher/` | Pruebas unitarias y compilación cruzada Windows/amd64 superadas localmente; integración Windows pendiente |
| Host WebView2 | Copia separada en `src/public-webview2/`, con perfil/capturas aisladas | Compilación Windows automatizada configurada; resultado de esta edición por confirmar |
| Motor Perl/GCstar | 1115 fuentes recuperadas en `src/perl/` | Verificadas contra manifiesto; cuatro claves heredadas retiradas |
| PAR `gcstar.exe` | Se conserva **solo en la vista previa privada** | Receta de compilación y obligaciones de fuente pendientes |
| Modo sin PAR | `JavKT9-Fuentes.cmd` invoca `wperl.exe` y el script `bin/gcstar` | Prueba automatizada de arranque sin GUI configurada; compatibilidad funcional pendiente |
| Runtime GTK/Perl, fuentes e imágenes | Copiados del paquete original solo para vista previa privada | Revisar licencias/avisos antes de distribuir públicamente |
| Instalador | No se reutiliza el de Beta 1 ni el de RC1 | Se prepara primero ZIP portátil independiente |

## Proceso preparado

`.github/workflows/compilar-edicion-publica-desarrollo.yml` construye los dos lanzadores Go y el host WebView2 en Windows, ejecuta pruebas, arma un **ZIP portátil privado** desde el ZIP RC1 con SHA-256 verificado y sustituye los binarios antiguos por los nuevos. El workflow guarda artefactos privados durante siete días; **no publica releases ni cambia la visibilidad del repositorio**.

**No afirmar que el ZIP se generó hasta comprobar el resultado del workflow.** Los dos programas Go sí fueron compilados y probados localmente de forma cruzada, sin ejecutar el programa de películas.

## Bloqueos reales para descargar públicamente

1. Validación integrada en Windows del nuevo lanzador, Bridge y host WebView2, incluyendo la primera verificación del navegador y la captura.
2. Decidir si el modo desde Perl fuente permite prescindir de `gcstar.exe` PAR sin perder funcionalidad.
3. Completar licencias y avisos de terceros para dependencias GTK/Perl, .NET/WebView2 y recursos.
4. Comprobar el paquete final, sus fuentes y la instalación portátil sin tocar la RC1.

**Protecciones:** `main` intacta, release RC1 en borrador, repo privado, perfiles de desarrollo separados y rechazo de ejecución paralela con otro Bridge en el puerto 53118.
