# JAVkt9

**JAVkt9** es un gestor de colecciones JAV para Windows, basado en GCstar, con una interfaz personalizada e integración WebView2 para consultar metadatos y portadas.

## Versión actual recomendada: 0.8.1 RC2

**JAVkt9 0.8.1 RC2 — Windows x64**

Esta es la versión de prueba más reciente recomendada para nuevas instalaciones. Incluye mejoras de interfaz, ajustes de funcionamiento y un nuevo instalador gráfico.

**[DESCARGAR JAVkt9 0.8.1 RC2](https://github.com/JavKt9/JavKT9-WebView2/releases/tag/v0.8.1-rc2)**

> **Importante:** RC2 es una versión preliminar (*pre-release*). Puede contener errores y todavía no constituye una versión estable definitiva.

### Novedades de RC2

- Nuevo instalador gráfico para Windows x64.
- Identidad visual renovada con el logo circular de JAVkt9.
- Nuevo sistema de ayuda con diseño editorial.
- Ajustes visuales en ventanas, avisos y cuadros de diálogo.
- Mejoras en la presentación y experiencia de uso.
- Instalación independiente de versiones anteriores.

## Funciones principales

- Administración de colecciones locales de títulos JAV.
- Consulta de metadatos y portadas desde JavLibrary mediante WebView2.
- Campos personales como Visto, Favorito, Puntuación, Soporte, Serie, Fecha añadida, Etiquetas y Comentarios.
- Administración de favoritos.
- Herramientas de copia de seguridad y restauración.
- Personalización de apariencia.
- Ayuda integrada.

## Instalación de RC2

1. Accedé a la [página oficial de la versión 0.8.1 RC2](https://github.com/JavKt9/JavKT9-WebView2/releases/tag/v0.8.1-rc2).
2. Descargá `JAVkt9-0.8.1-RC2-Visual-PRUEBA-Windows-x64.exe`.
3. Ejecutá el instalador en Windows de 64 bits.
4. Seguí las instrucciones del asistente.
5. Abrí JAVkt9 desde el acceso directo creado.

La carpeta de instalación predeterminada de RC2 es:

`C:\Program Files\JavKT9-081-RC2-Prueba`

### Advertencia de Windows

Microsoft Defender SmartScreen puede mostrar una advertencia al ejecutar el instalador porque se trata de una aplicación de distribución reciente sin una firma digital reconocida.

Descargá el programa únicamente desde este repositorio oficial y verificá el archivo con tu antivirus.

### Compatibilidad con RC1

RC2 utiliza una instalación independiente y no reemplaza automáticamente RC1.

Las dos versiones pueden coexistir en Windows.

La [versión RC1](https://github.com/JavKt9/JavKT9-WebView2/releases/tag/v0.8.1-rc1) continúa disponible para quienes necesiten utilizarla.

**Se recomienda realizar una copia de seguridad de las colecciones antes de cambiar de versión.**

## Manual y ayuda

RC2 incluye una nueva ayuda HTML con navegación por capítulos.

Se puede abrir desde el menú **Help → Contents** del programa.

El archivo fuente del manual también está disponible en el repositorio:

[Consultar el manual HTML de RC2](https://github.com/JavKt9/JavKT9-WebView2/blob/desarrollo-0.8.1-rc2/docs/Manual_JavKT9.html)

## Limitaciones conocidas

JAVkt9 depende de páginas y servicios externos que pueden cambiar sin aviso.

La consulta de metadatos mediante WebView2 puede verse afectada por cambios en los sitios, solicitudes de consentimiento o mecanismos de protección automatizada.

Si una ficha no existe en la fuente consultada, JAVkt9 no podrá obtener sus datos automáticamente.

## Desarrollo y código fuente

El desarrollo de RC2 se encuentra en la rama:

[`desarrollo-0.8.1-rc2`](https://github.com/JavKt9/JavKT9-WebView2/tree/desarrollo-0.8.1-rc2)

El proyecto del instalador visual se encuentra en:

[`installer-rc2-visual`](https://github.com/JavKt9/JavKT9-WebView2/tree/desarrollo-0.8.1-rc2/installer-rc2-visual)

**Nota técnica:** el instalador publicado se compiló y probó localmente con Inno Setup 7. La carpeta de archivos de aplicación utilizada en esa compilación (*Payload*) no está incluida íntegramente en el repositorio. Por lo tanto, el instalador RC2 todavía no dispone de una reconstrucción completamente autónoma desde GitHub.

Los flujos de compilación de versiones anteriores se conservan como referencia histórica y no deben confundirse con el proceso de publicación de RC2.

## Licencia y créditos

JAVkt9 deriva de **GCstar**, proyecto de software libre distribuido bajo la GNU General Public License v2.0.

Se conserva la atribución del proyecto original y de sus autores.

Las modificaciones de JAVkt9 © 2026 kt9 se distribuyen bajo los términos aplicables de la misma licencia.

Consultá `LICENSE` para el texto de la GNU GPL v2.0 y `NOTICE.md` para las atribuciones y notas del proyecto.

Proyecto original: http://www.gcstar.org/

## Privacidad

No publiques colecciones personales, perfiles WebView2, cookies, contraseñas, tokens ni otros datos privados al reportar problemas.

Para informar un error, compartí únicamente la información mínima necesaria para reproducirlo.

---

**JAVkt9 — Organizando tus colecciones, a tu manera.**
