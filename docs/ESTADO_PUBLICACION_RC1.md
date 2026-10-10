# Estado de fuentes — JAVkt9 0.8.1 RC1

**AUDITORÍA PRIVADA — NO PUBLICAR TODAVÍA.**

La RC1 ya funcionaba con WebView2 y búsquedas de películas según las pruebas del usuario. No modificar el Bridge ni WebView2 por problemas hipotéticos.

## Fuentes incorporadas en esta rama

- **1115 archivos** bajo `src/perl/`, importados del ZIP RC1 verificado por SHA-256.
- Módulos Perl y configuración, incluyendo el Bridge de JavLibrary.
- Las dos variantes distintas del script `gcstar`: `src/perl/bin/gcstar` y `src/perl/par_embebido/script/gcstar.pl`.
- Cuatro claves heredadas de módulos TheMovieDB fueron retiradas durante la importación.
- Escaneo automático Gitleaks de `src/perl/`: sin coincidencias detectadas (no equivale a una auditoría completa).
- Proyecto C# WebView2 en `src/JavKT9WebView2/`, ya presente en `main`. **No está demostrada** su equivalencia reproducible con el ejecutable RC1.

## Pendiente antes de publicar

1. Recuperar los proyectos fuente originales de `JavKT9.exe` y `GCJavBridgeLauncher.exe`.
2. Documentar y verificar la generación del `gcstar.exe` PAR y de todos los ejecutables Windows.
3. Auditar licencias y derechos de redistribución de recursos, módulos y dependencias.
4. Revisar privacidad y secretos de todo el repositorio y su historial.
5. Revisar los instaladores heredados; **no usar el de Beta 1 para RC1**.

## Protección de versiones

No modificar `C:\Program Files\JavKT9` (0.8.0 Beta 1), las carpetas experimentales/RC1 instaladas, `main` ni la release borrador RC1.

La rama `fuentes-rc1-auditoria` es un área de trabajo separada y **no implica autorización para hacer público el repositorio**.
