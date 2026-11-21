# JavKT9 0.9.9.1 — revisión de mantenimiento (en desarrollo)

Esta rama **no** representa JavKT9 1.0.0 y **no** modifica la versión publicada 0.9.9.

## Alcance acordado

- [x] **Títulos alternativos nuevos**: al importar datos de JavLibrary, si `original` empieza por el mismo ID que aparece en `title`, se elimina únicamente ese prefijo. Ejemplo: `ACHJ-084 A Black Daycare` pasa a `A Black Daycare`.
- [x] Mantener intactos los datos almacenados en colecciones existentes. No realizar migración masiva ni reinterpretar códigos distintos.
- [x] Pruebas unitarias de la regla de limpieza: `perl tests/alternative-title-cleanup.t`.
- [ ] **Enlaces de modelos**: conservar cada URL completa visible en la tabla y permitir abrirla al hacer clic mediante el navegador predeterminado de Windows; preservar copia, edición y varios enlaces.
- [ ] Verificar comportamiento en las interfaces Clásica, Moderna V1 y Moderna V2.
- [ ] Pruebas de instalación limpia y actualización antes de publicar una revisión preliminar.

## Dependencias para el cambio de hipervínculos

La tabla de enlaces de la ficha se construye en componentes GTK/GCstar que **no están incluidos en el código fuente versionado actual** de este repositorio. Antes de modificarla se necesita revisar la versión exacta incluida en el instalador de los archivos `GCPanel.pm`, los widgets pertinentes de `GCGraphicComponents` y la definición del campo «Enlaces de modelos». No reemplazar estos componentes por versiones genéricas de GCstar sin comparar, ni simular un enlace con cambios cosméticos.

## Límites

No crear instalador, etiqueta, release ni fusionar la rama hasta completar pruebas de uso en Windows y comprobar que los datos `.gcs` existentes se conservan.

## Pruebas

```sh
perl -c app/lib/gcstar/GCJavTitleCleanup.pm
perl tests/alternative-title-cleanup.t
```
