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

## Corrección de objetivo: portada del panel principal (V6)

La captura de usuario confirmó que la portada solicitada era la del **panel derecho de la ventana principal**, no la ventana emergente `GCItemWindow`. En V6 se modificó `GCPanel.pm`, al final de `GCItemPanel::createContent`, después de la lectura del layout, comprobando con `Scalar::Util::refaddr` que se trata de `GCFrame->{panel}` y de un `GCFormPanel`. Solo el `GCImageButton` asociado a `commonFields.cover` se ajusta a 235 × 250. `GCItemImage` utiliza `GCUtils::scaleMaxPixbuf` para preservar proporciones. El parche V6 **no modifica barra de título ni tema** y mantiene las demás correcciones V4.

ZIP V6 preparado con un único archivo reemplazable `GCPanel.pm` y las instrucciones de respaldo/restauración. Sintaxis Perl verificada con dependencias GTK simuladas; 2 pruebas de discriminación de panel principal vs ventana emergente aprobadas. **Pendiente validación en Windows**.

## V7: evitar deformación de los campos laterales

La validación de usuario del V6 mostró que el tamaño fijo **235 × 250** de la portada alteraba las dimensiones de los campos contiguos (fecha, director y duración). Se elimina la llamada `setHeight(250)` y se mantiene la **altura natural definida por el layout**; el ancho de la portada pasa a **180**. De ese modo la fila deja de forzarse verticalmente. V7 conserva las funciones de lista, títulos y enlaces, y no toca la barra de título. Verificada la sintaxis de `GCPanel.pm` con las dependencias GTK simuladas disponibles en el entorno, así como que V7 solo difiere de V6 en ese bloque. Pendiente comprobar el aspecto en Windows.

Parche V7: reemplazo de un archivo `app/lib/gcstar/GCPanel.pm`, copia de seguridad local manual previa e instrucciones de restauración; no instalador.

## V8: ampliar visor View Picture y colorear su cabecera

El usuario aprobó el tamaño de la portada en la ficha principal (V7) y pidió mejorar **exclusivamente el diálogo que se abre al hacer clic en la imagen**, titulado `View Picture`. En `GCDialogs.pm`, `GCImageDialog` mantenía un tamaño inicial fijo de 500×500, responsable de mostrar la imagen relativamente pequeña en el visor. La revisión calcula el tamaño inicial a partir de la imagen original y la pantalla, con un máximo de 800 px de ancho y 650 px de alto para la imagen, conservando proporción y sin ampliar imágenes de baja resolución. Además configura `Gtk3::HeaderBar` con nombre `GCJavTitleBar` para reutilizar el estilo visual de la ventana principal, incluyendo su proveedor CSS cuando está disponible.

El ZIP V8 incluye **solo** un aplicador PowerShell/CMD que modifica la clase `GCImageDialog` dentro del `GCDialogs.pm` instalado y guarda una copia fechada antes de escribir. No sustituye otros módulos ni altera las colecciones. El aplicador revisa las estructuras esperadas y cancela si el archivo es distinto. Comprobaciones locales: sintaxis Perl de fragmentos y cuatro escenarios de dimensionamiento con imágenes horizontales/verticales aprobados; verificación de integridad del ZIP aprobada. **Falta prueba visual y funcional real en Windows**, especialmente los colores de cabecera.

## V9: Favoritos de personas con mayor espacio

A pedido del usuario, el diálogo de actores y directores favoritos (`GCJavPersonFavoritesDialog.pm`) pasa de tamaño inicial fijo `740 × 620` a `980 × 740` cuando la pantalla lo permite, con límites de tamaño respecto de la resolución y posibilidad de ajustar las dimensiones manualmente. Se aumenta la altura mínima de la lista de personas a 200 y la de películas relacionadas a 190. Los datos del catálogo, favoritos, previsualizaciones y colores del tema no se modifican. La documentación está incorporada al manual HTML y las notas de la revisión.

ZIP V9: aplicador puntual de un único archivo, que guarda respaldo local y rechaza archivos cuyos anclajes no coincidan. **Pendiente prueba visual bajo Windows** en ambas pestañas de favoritos. No publicar todavía.

## V10: Favoritos de personas adaptados a monitores grandes

Una prueba de usuario en pantalla grande mostró que el tamaño inicial V9 (980 × 740) ocupaba aproximadamente una cuarta parte del ancho visible. En V10, el diálogo ajusta sus dimensiones al **65 % del ancho y 73 % del alto** de la pantalla, con límites de **2000 × 1350 px**, márgenes para Windows y tamaño mínimo prudente en pantallas más pequeñas. Se mantiene la capacidad de redimensionar manualmente y no se modifican datos ni funcionalidad de favoritos. Ejemplos estimados: 1920×1080 → 1248×788; 2560×1440 → 1664×1051; 3840×2160 → 2000×1350.

Se preparó ZIP de prueba V10 que cambia únicamente el bloque de dimensionamiento de `GCJavPersonFavoritesDialog.pm` y guarda un respaldo con fecha. El aplicador rechaza instalaciones que no tengan el bloque V9 esperado; no afecta otros componentes. Comprobado que la sustitución de código V9→V10 reproduce exactamente el módulo guardado en esta rama y que los cálculos respetan límites para las resoluciones ensayadas. **Falta validación real en Windows** antes de fusionar o publicar.
