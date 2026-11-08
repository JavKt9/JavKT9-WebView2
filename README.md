# JavKT9 0.9.9

**Gestor de colecciones para Windows, basado en GCstar.**

Esta rama contiene la preparacion de **JavKT9 0.9.9**, la proxima version publica prevista. **No es una descarga final todavia:** el instalador y las pruebas de instalacion/actualizacion siguen pendientes de validacion.

## Tres interfaces en una sola aplicacion

| Interfaz | Opciones de tema |
|---|---:|
| **Clásica** | **10** |
| **Moderna V1** | **7** |
| **Moderna V2** | **6**, incluida Original |

La seleccion de interfaz y los colores se guardan de manera independiente. Durante el desarrollo, un cambio de modo entra en vigor al reiniciar JavKT9.

## Funciones

- Gestion de colecciones locales, fichas, caratulas y favoritos.
- Consulta de metadatos mediante los componentes del proyecto.
- Herramientas de copias de seguridad y restauracion.
- Personalizacion visual de las tres interfaces.
- Manual HTML/PDF integrado.

## Estado y publicacion

**Objetivo:** publicar directamente **JavKT9 0.9.9** cuando pasen las pruebas finales. No hay instalador 0.9.9 disponible para descarga por ahora.

Pendiente: sincronizar fuentes locales actuales, verificar sintaxis y funcionamiento en Windows, finalizar la eleccion inicial de interfaz en Inno Setup, comprobar instalacion y actualizacion sin perdida de datos, y revisar los metadatos del ejecutable.

Consultar [planificacion tecnica de 0.9.9](docs/desarrollo-0.9.9.md).

## Codigo y compatibilidad

La aplicacion combina componentes propios con GCstar (Perl/GTK), y mantiene la integracion WebView2 del proyecto. El codigo fuente versionado no reemplaza automaticamente el entorno completo de compilacion o empaquetado de Windows.

**No subir al repositorio** colecciones personales `.gcs`, cookies, perfiles WebView2, credenciales, portadas privadas ni respaldos.

## Licencia y creditos

Derivado de **GCstar**, software libre distribuido bajo la licencia GNU GPL (version 2 o posterior, segun los archivos correspondientes). Se conserva la atribucion a sus autores; revisar [LICENSE](LICENSE) y [NOTICE.md](NOTICE.md).

Proyecto original: http://www.gcstar.org/

---

JavKT9 - Organizando tus colecciones, a tu manera.
