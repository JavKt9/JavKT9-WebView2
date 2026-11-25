# Integración del manual y «Acerca de» — JavKT9 0.9.9.1

**Estado:** preparada para validación en Windows. La versión 0.9.9 publicada no se modifica.

## Archivo de manual que conserva el usuario

El manual original ilustrado **`Manual_JavKT9.html`** está integrado en el proyecto, en:

```
app/docs/Manual_JavKT9.html
```

Y debe instalarse en:

```
C:\Program Files\JavKT9\app\docs\Manual_JavKT9.html
```

No se debe reemplazar por un PDF resumido nuevo: conserva imágenes, portada, estructura y capítulos anteriores; la revisión agrega el capítulo 17 de novedades y correcciones 0.9.9.1.

## Acerca de

Código: `app/lib/gcstar/GCDialogs.pm` / `GCAboutDialog`.

El título debe indicar `Acerca de JavKT9 0.9.9.1`, y la etiqueta del programa debe mostrar:

```
JavKT9 0.9.9.1
Revisión de mantenimiento (en pruebas)
```

Se conserva el logo, autoría y créditos de GCstar.

## Menú Ayuda

Código: `app/lib/gcstar/GCMainWindow.pm` / `help`.

`Help → Contents` abre `Manual_JavKT9.html`. Si el HTML falta, mantiene como respaldo histórico `Manual_GCJav.pdf`.

## Preparación del instalador

`JavKT9-Setup-0.9.9.1.iss` es el candidato de empaquetado. Conserva el mismo AppId de 0.9.9 y actualiza AppVersion, nombre y metadatos del ejecutable instalador a 0.9.9.1. La regla recursiva `Source: "{#SourceRoot}\\app\\*"` incluye los tres archivos anteriores.

**Antes de compilar**, copiar al `SourceRoot` de Inno Setup los tres archivos actualizados desde `app/` en la rama 0.9.9.1; la carpeta de origen definida en el candidato puede variar entre equipos.

**Pruebas antes de publicar:**
- Help → About muestra la nueva versión en los tres modos y conserva colores, botones y créditos.
- Help → Contents abre el HTML original actualizado con imágenes; el enlace al capítulo 17 funciona.
- Actualizar desde 0.9.9 conserva colecciones .gcs, carátulas, temas y favoritos.
- El instalador no crea una nueva ubicación y no modifica los datos del perfil.
- Instalar en limpio y restaurar copia de seguridad.

El paquete de actualización local de documentación y versión incluye un script que respalda `GCDialogs.pm`, `GCMainWindow.pm` y `Manual_JavKT9.html`; no instala ninguna release ni modifica .gcs.

**No fusionar ni publicar el instalador hasta completar validación en Windows.**
