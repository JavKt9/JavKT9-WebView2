# Novedades y correcciones — JavKT9 0.9.9.1

**Estado:** revisión de mantenimiento en pruebas. Todavía no es una publicación estable ni la versión 1.0.0.

La versión 0.9.9 publicada permanece intacta. Los cambios siguientes están preparados en `revision-0.9.9.1` y forman parte del proceso de validación.

## Cambios para el usuario

1. **Títulos alternativos:** se evita repetir el ID de la película al inicio del nombre cuando coincide con el código principal. En fichas anteriores la limpieza es visual hasta editar; no se reescriben colecciones automáticamente.
2. **Enlaces de modelos:** URL completa azul y subrayada. Un clic sobre el texto abre el navegador; el espacio libre permite seleccionar para editar o eliminar.
3. **Cast y enlaces:** el alto se ajusta al número de filas (mínimo 2; hasta 12 sin scroll interno). Los favoritos y la información siguen guardándose como antes.
4. **Portada de la ficha principal:** se amplía moderadamente el ancho y se respeta la altura del diseño para no deformar Fecha, Director ni Duración.
5. **View Picture:** el visor usa un tamaño inicial adaptable a la pantalla y a la resolución de la imagen, con un máximo de 800 × 650 píxeles para la imagen. La cabecera se prepara para usar el tema activo. La validación visual final de la barra de título sigue pendiente.
6. **Ayuda / Acerca de:** muestra `JavKT9 0.9.9.1` con la indicación de revisión de mantenimiento en pruebas. Help → Contents abre `Manual_JavKT9.html` actualizado; el PDF anterior es respaldo cuando ese HTML no está disponible.

## Compatibilidad y precauciones

- Se conservan las interfaces Clásica, Moderna V1 y Moderna V2, los temas existentes y el formato de las colecciones `.gcs`.
- Antes de probar un parche, cerrá JavKT9, guardá una copia de la colección y las portadas, y respaldá los `.pm` que vas a sustituir.
- Los cambios no implican que se haya generado o publicado un nuevo instalador.
- Faltan pruebas finales de interfaz, actualización e instalación limpia en Windows.

## Documentación

El manual HTML `app/docs/Manual_JavKT9.html` incorpora esta información como **capítulo 16: Novedades y correcciones 0.9.9.1**.

La versión `0.9.9` de GitHub sigue siendo la última versión publicada mientras se valida esta revisión.
