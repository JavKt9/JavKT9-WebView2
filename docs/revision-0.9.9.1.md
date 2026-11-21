# JavKT9 0.9.9.1 — revisión de mantenimiento (en desarrollo)

Esta rama **no** representa JavKT9 1.0.0 y **no** modifica la versión publicada 0.9.9.

## Alcance acordado

- [x] **Títulos alternativos nuevos**: al importar datos de JavLibrary, si `original` empieza por el mismo ID que aparece en `title`, se elimina únicamente ese prefijo. Ejemplo: `ACHJ-084 A Black Daycare` pasa a `A Black Daycare`.
- [x] Mantener intactos los datos almacenados en colecciones existentes. No realizar migración masiva ni reinterpretar códigos distintos.
- [x] Pruebas unitarias de la regla de limpieza: `perl tests/alternative-title-cleanup.t`.
- [x] **Enlaces de modelos (código preparado)**: conserva cada URL completa visible en la tabla y permite abrirla con un clic mediante el lanzador del navegador de JavKT9. Preserva la edición y el almacenamiento de la lista. Pendiente validar visualmente en Windows.
- [ ] Verificar comportamiento en las interfaces Clásica, Moderna V1 y Moderna V2.
- [ ] Pruebas de instalación limpia y actualización antes de publicar una revisión preliminar.

## Dependencias para el cambio de hipervínculos

Se recibió `GCPanel.pm` desde una instalación existente y se incorporó a esta rama junto con `GCJavModelLinks.pm`. La lista de modelos se detecta por su etiqueta visible y se conecta al lanzador de URL ya usado en JavKT9. **No se reemplazó `GCPictureWidgets.pm`**, puesto que controla imágenes, no las listas de texto. Faltan pruebas de interfaz reales (GTK/Windows), especialmente comprobación de selección para editar o quitar. Para cotejar la definición técnica del campo y el widget completo puede ser útil incorporar `GCGraphicComponents/GCWidgets.pm` y el modelo de colección exacto.

## Límites

No crear instalador, etiqueta, release ni fusionar la rama hasta completar pruebas de uso en Windows y comprobar que los datos `.gcs` existentes se conservan.

## Pruebas

```sh
perl -c app/lib/gcstar/GCJavTitleCleanup.pm
perl tests/alternative-title-cleanup.t
```

## Ajuste visual posterior a prueba de usuario

La primera prueba en Windows confirmó que abrir las URL funcionaba, pero el texto no se reconocía como hipervínculo y un clic abría el navegador incluso cuando se quería seleccionar la fila.

- **Hipervínculos:** URL completa, subrayado azul (tono adaptado al fondo claro/oscuro), doble clic o Enter abre el navegador. Un clic selecciona para editar o usar Remove.
- **Títulos alternativos de fichas antiguas:** mostrar el título sin código duplicado, pero conservar el valor original sin reescribir el archivo .gcs hasta que la persona edite ese campo. Los nuevos metadatos importados se normalizan en GCMainWindow.
- Se generó un segundo ZIP de prueba con `GCPanel.pm`, `GCJavModelLinks.pm` y `GCJavTitleCleanup.pm` (no instalador completo).
- Se ejecutaron pruebas de Perl de ambos módulos y pruebas simuladas del panel para comprobar tanto el orden de actualización de los campos como la conservación de valores originales. **Falta validar los controles en el GTK de Windows**.

## Ajuste de altura de listas (V3)

En la prueba de usuario, las secciones `Cast (5)` y `Enlaces de modelos (5)` mostraban únicamente dos filas y obligaban a usar desplazamiento interno. `GCPanel.pm` ahora ajusta la altura del `Gtk3::ScrolledWindow` de ambas listas según su modelo, con un mínimo de 2 filas y un máximo de 12. Cinco elementos se ven completos; las listas muy largas conservan el desplazamiento. También recalcula al agregar/quitar entradas y al cambiar de ficha, sin modificar el contenido de las colecciones. Se comprobó sintaxis con dependencias GTK simuladas y se ejecutaron 23 pruebas locales de regresión de la revisión, **no equivalentes a una ejecución real en Windows**. ZIP de prueba V3 preparado, sin publicar ni fusionar.

## Ajuste de altura y clic sencillo (V4)

Nueva prueba visual del usuario: con dos actrices, la segunda aparecía cortada; con cinco actrices y cinco enlaces, la última fila seguía oculta. El cálculo de alto anterior resultaba insuficiente en esa instalación. Se amplió la reserva por fila a 44 unidades GTK, con cabecera 44 y margen 12, manteniendo el máximo de 12 filas antes del desplazamiento interno. La apariencia final requiere validación en Windows.

Los enlaces ahora se abren con un clic sobre la **URL subrayada**; hacer clic en el espacio vacío del renglón conserva la selección para editar o quitar sin abrir el navegador. Enter sobre la fila enfocada también abre. Prueba sintáctica de Perl realizada con dependencias GTK simuladas; 13 verificaciones locales de la función de altura y helpers superadas. No equivale a la prueba funcional bajo Windows.

## Portada ampliada y cabecera de ficha (V5)

Al abrir la ficha emergente de una película, la miniatura de portada resultaba muy pequeña y la barra de título podía no respetar la paleta del programa. Se agregó a `GCDialogs.pm` una mejora exclusiva de `GCItemWindow`: el botón de portada solicita 245 × 225 píxeles y mantiene la escala proporcional del dibujo original. La cabecera utiliza `GCJavTitleBar`, que ya existe en el CSS de las interfaces, y reutiliza el proveedor de estilos del título principal cuando está disponible. Se conservan los botones de diálogo y todas las acciones de la ficha.

Se preparó un ZIP V5 con un aplicador puntual que crea respaldo de `GCDialogs.pm` antes de modificarlo; verifica tres anclajes de la clase original y se niega a cambiar una versión incompatible. No requiere reemplazar los módulos V4. **No se ha validado todavía en Windows** la apariencia del diálogo, su cabecera o su tamaño de portada; el PR sigue siendo borrador.
