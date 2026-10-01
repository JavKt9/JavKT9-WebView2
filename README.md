# JAVkt9

**JAVkt9** es un gestor de colecciones JAV para Windows, basado en GCstar y adaptado para consultar metadatos y portadas mediante un flujo WebView2 integrado.

> Estado actual: **0.8.0 Beta 1**. Es una versión beta pública: puede contener errores y el acceso a fuentes externas puede verse afectado por cambios del sitio, consentimiento o protecciones anti-bot.

## Funciones principales

- Colección local de títulos JAV.
- Consulta de metadatos y portadas desde JavLibrary mediante WebView2.
- Campos personales como Visto, Favorito, Puntuación, Soporte, Serie, Fecha añadida, Etiquetas y Comentarios.
- Perfil WebView2 independiente en `%LOCALAPPDATA%\JavKT9\WebView2`.
- Instalación experimental independiente de GCJav.

## Instalación

Descargá el instalador de la sección **Releases**. La instalación predeterminada es `C:\Program Files\JavKT9`.

Al actualizar, el instalador no está diseñado para borrar la colección del usuario ni el perfil WebView2 de `%LOCALAPPDATA%\JavKT9`.

## Notas de la beta

JAVkt9 depende de páginas y servicios externos que pueden cambiar sin aviso. En algunos casos WebView2 puede mostrarse temporalmente para resolver consentimiento o comprobaciones del sitio. Si una ficha no existe en la fuente, JAVkt9 no puede obtener sus datos.

## Compilación del instalador

El workflow de GitHub Actions `Build JAVkt9 Windows Setup 0.8.0 Beta 1` descarga el payload de la Release indicada, verifica la configuración WebView2 y compila el instalador con Inno Setup.

Configuración esperada para esta rama beta:

- Bridge local: puerto `53118`.
- `open_browser=0`.
- Sin `BrowserExtension` heredada.

## Licencia y créditos

JAVkt9 deriva de **GCstar**, proyecto de software libre distribuido bajo la GNU General Public License v2.0. Se conserva la atribución del proyecto original y de sus autores. Las modificaciones JAVkt9 © 2026 kt9 se distribuyen bajo los términos aplicables de la misma licencia.

Consultá `LICENSE` para el texto de la GNU GPL v2.0 y `NOTICE.md` para atribuciones y notas del proyecto.

Proyecto original GCstar: http://www.gcstar.org/

## Privacidad

No publiques colecciones personales, perfiles WebView2, cookies, datos bancarios, tokens ni otros datos privados al reportar problemas. Para un informe de error, compartí solo la información mínima necesaria para reproducirlo.
