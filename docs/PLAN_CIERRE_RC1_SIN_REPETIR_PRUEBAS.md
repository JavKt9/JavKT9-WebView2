# Plan de cierre de RC1 pública — sin rehacer el programa

**Ya comprobado por el usuario:** instalador ejecutado en Windows, instalación terminada, programa abierto y búsqueda WebView2 funcional. No repetir esas pruebas de la candidata sin cambios.

## Qué falta realmente

**Prioridad 1 — paquete público sin secretos:** cuatro módulos TheMovieDB conservan claves literales antiguas en el paquete original. Revisar si son credenciales válidas; rotar/revocar las que corresponda; retirar valores del paquete **destinado a publicación**. La copia de fuentes del repositorio ya los tiene retirados, pero el instalador funcional original no.

**Prioridad 2 — fuente correspondiente:** la RC1 probada usa dos ejecutables Go antiguos sin proyectos fuente originales encontrados y un PAR `gcstar.exe` cuya receta no está documentada. Determinar las obligaciones de fuente según si los componentes son independientes o derivados; no confundir fuentes nuevas de reemplazo con fuentes de los binarios RC1.

**Prioridad 3 — dependencias:** completar tabla de componentes y licencias para Perl/GTK, .NET/WebView2, recursos e imágenes. Los avisos GPLv2 y OFL 1.1 sí están presentes en el paquete original; falta cobertura de terceros.

**Instalador Go — RESUELTO:** el código original de `Setup.exe` está en `src/instalador-rc1/main.go` y se reprodujo su stub **byte por byte** con Go 1.23.2. No confundirlo con los lanzadores originales de la aplicación.

**Prioridad 4 — GitHub:** después de 1–3, adjuntar el instalador correcto y el paquete de fuentes/avisos a una release `Pre-release`; comprobar descarga pública desde una sesión sin acceso privado. La conexión de GitHub actual no permite adjuntar directamente el archivo EXE grande.

## Lo que no hay que hacer

- No sustituir el Bridge Perl ni el WebView2 que ya funcionan en la RC1 probada.
- No cambiar ni borrar las instalaciones del usuario.
- No afirmar que el código fuente nuevo de los lanzadores reproduce exactamente los binarios antiguos.
- No subir el instalador original sin revisar los literales de claves.
- No repetir auditorías genéricas: usar el inventario exacto de `RESULTADO_REVISION_REDISTRIBUCION_RC1.md`.

## Estado

**Documentación y revisión del paquete original completadas en esta rama.** Sigue pendiente **resolver**, no solo describir, los elementos anteriores antes de publicar.
