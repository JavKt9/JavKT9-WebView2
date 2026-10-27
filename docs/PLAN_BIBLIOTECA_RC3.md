# RC3 — Rediseño de la vista Biblioteca (Imagen)

## Objetivo
Mejorar la presentación del catálogo de películas manteniendo la vista Texto (clásica), la vista Detallada y todas las funciones verificadas de RC2.

## Referencias y decisión visual
Comparación visual de RC2 realizada con los estilos Wood, Luxury Purple Glass y Dark Glass.

- **Base elegida:** Dark Glass: composición oscura sobria, mejor integrada con la interfaz azul de JavKT9.
- **Evitar:** textura de madera, ornamentación bordó, reflejos bajo las carátulas, acentos verdosos y fondos negros demasiado contrastantes.
- **Propuesta RC3:** un estilo específico JavKT9 Biblioteca, azul noche, carátulas destacadas, selección visible y controles más discretos.
- Las capturas de pruebas siguen siendo referencias de diseño; esta especificación no implica que el nuevo estilo esté implementado.

## Cambios deseados, por orden
1. Añadir un **estilo nuevo** sin alterar los estilos existentes, cuando dispongamos de los recursos de `list_bg` y la copia de prueba local.
2. Eliminar la reflexión decorativa en el nuevo estilo (el motor ya contempla `withReflect` en el archivo `style`).
3. Mejorar fondo, recuadros y estado de selección para que las carátulas sean protagonistas.
4. Mejorar el uso del ancho disponible y estudiar la posibilidad de plegar el panel lateral de opciones.
5. Evaluar el icono de portada ausente de forma separada, sin alterar cómo se localizan o guardan las imágenes.

## Código identificado
- `src/perl/lib/gcstar/GCItemsLists/GCImageLists.pm`: carga del estilo, tamaño, columnas, fondo y reflexión.
- `src/perl/lib/gcstar/GCItemsLists/GCImageListComponents.pm`: composición de carátulas y superposiciones.
- `src/perl/lib/gcstar/GCItemsLists/GCListOptions.pm`: panel de opciones de visualización.
- `src/perl/lib/gcstar/GCStyle.pm`: descubrimiento de estilos `list_bg`.

**Dependencia pendiente:** los recursos gráficos de `list_bg` no están presentes en el árbol fuente de esta rama y habrá que recuperarlos del paquete local de pruebas, sin incluir datos personales.

## Límites y comprobaciones
- Desarrollar únicamente en `desarrollo-0.8.1-rc3` y una copia local de prueba separada.
- No modificar ni volver a publicar las releases RC1/RC2, ni la rama `main`.
- No ejecutar GitHub Actions.
- Mantener las vistas Texto y Detallada y las opciones de RC2.
- No modificar colecciones, perfiles personales, rutas de portadas ni lógica de backup/restauración.
- Probar nuevo estilo con una colección de prueba y varias carátulas antes de considerarlo listo.

## Estado
- [x] Comparación de estilos y selección de base visual Dark Glass
- [x] Identificación de módulos relevantes
- [ ] Recuperar recursos de `list_bg` de la copia de prueba
- [ ] Implementar nueva variante de estilo
- [ ] Verificar visualización, selección y cambio de vistas
