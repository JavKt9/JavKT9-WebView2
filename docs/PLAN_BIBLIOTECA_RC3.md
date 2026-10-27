# RC3 — Nueva vista Biblioteca (diseño tipo catálogo moderno)

## Objetivo acordado
Implementar una **vista Biblioteca nueva**, inspirada en los bocetos de interfaz tipo catálogo con carátulas y paneles modernos compartidos en la conversación. **NO es simplemente modificar el skin Dark Glass ni recolorear la vista Imagen heredada.**

## Resultado esperado
- **Catálogo principal en cuadrícula adaptable:** tarjetas de carátulas con tamaños consistentes, código/título legibles y espacio bien aprovechado; sin reflejos, texturas de madera ni íconos decorativos desproporcionados.
- **Cabecera de Biblioteca:** búsqueda accesible y, en una etapa posterior, filtros y ordenación.
- **Panel de detalle:** seleccionar una película muestra sus datos sin perder de vista el catálogo.
- **Estética JavKT9:** fondos azul noche, superficies diferenciadas y acentos azules/violetas coherentes con los temas; no replicar el fondo estampado del skin histórico.
- **Panel de opciones plegable o reubicado:** evitar que los ajustes técnicos ocupen permanentemente el espacio de las carátulas.
- **Comportamiento familiar:** abrir, seleccionar, editar, menú contextual, favoritos y visualización de datos permanecen disponibles.

## Compatibilidad obligatoria
1. Mantener **Texto (vista clásica)** tal como está.
2. Mantener **Imagen (vista anterior)** y **Detallada** disponibles, sin reescribirlas para imitar el boceto.
3. Crear **Biblioteca como nueva opción de visualización**, inicialmente experimental y opcional.
4. No tocar datos de colecciones, portadas, perfiles, backup/restauración ni las releases RC1/RC2.
5. Nada de workflows de GitHub Actions.

## Implementación técnica propuesta (en etapas pequeñas)
1. **Integración básica:** agregar entrada `Biblioteca (RC3)` en selector de vistas y estructura GTK3 propia, sin modificar las vistas existentes. Asegurar selección y apertura de una película.
2. **Cuadrícula de tarjetas:** usar componentes GTK3 adecuados (por ejemplo, FlowBox dentro de ScrolledWindow), aprovechando caché/rutas de portadas existentes. Manejar títulos largos y carátulas ausentes con un marcador neutro.
3. **Panel de detalles y navegación:** mostrar/editar el registro seleccionado mediante el panel existente; conservar controles y menú contextual.
4. **Búsqueda/filtros y opciones:** integrar con el modelo y búsqueda actuales antes de crear lógicas nuevas. Dar prioridad al catálogo y permitir esconder opciones.
5. **Acabado visual:** espaciados, estados de foco/selección, contraste, distintos tamaños de ventana y coherencia con los temas.
6. **Pruebas locales:** colección de prueba sin datos personales; comprobar alternar vistas, selección, menús, guardado y reinicio.

## Código existente identificado
- `src/perl/lib/gcstar/GCMainWindow.pm`: crea la vista según `options->view`.
- `src/perl/lib/gcstar/GCMenu.pm`: selector de vistas en barra.
- `src/perl/lib/gcstar/GCItemsLists/GCImageLists.pm`: vista Imagen existente y tratamiento de carátulas.
- `src/perl/lib/gcstar/GCItemsLists/GCImageListComponents.pm`: composición/caché de imágenes.
- `src/perl/lib/gcstar/GCItemsLists/GCTextLists.pm`: vista clásica que se debe conservar.
- `src/perl/lib/gcstar/GCItemsLists/GCListOptions.pm`: opciones según la vista.
- `src/perl/lib/gcstar/GCLang/ES/GCstar.pm` y otros idiomas: etiquetas de vistas.

**Advertencia:** el árbol de código en GitHub no es una copia íntegra del instalador listo para compilar. Los cambios funcionales deben probarse sobre un entorno local separado de RC2; todavía no hay una implementación Biblioteca RC3 lista para instalar.

## No confundir con
Las pruebas de Wood / Luxury Purple Glass / Dark Glass sirvieron para evaluar limitaciones de la vista actual y la paleta. **Ninguno de esos skins es el diseño final de Biblioteca RC3.**

## Estado
- [x] Crear rama `desarrollo-0.8.1-rc3` separada de RC2.
- [x] Analizar vista Imagen de RC2 y comparar estilos.
- [x] Corregir alcance: **nueva vista tipo catálogo**, no skin.
- [ ] Agregar entrada opcional Biblioteca (RC3) sin alterar Texto/Imagen/Detallada.
- [ ] Implementar cuadrícula, selección y enlace al panel actual.
- [ ] Añadir búsqueda/filtros y mejorar presentación.
- [ ] Probar en copia local y aprobar visualmente antes de preparar instalador RC3.
