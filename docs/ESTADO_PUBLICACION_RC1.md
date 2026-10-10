# Estado de fuentes — JAVkt9 0.8.1 RC1

**AUDITORÍA PRIVADA — NO PUBLICAR TODAVÍA.**

La RC1 ya funcionaba con WebView2 y búsquedas de películas según las pruebas del usuario. No hay motivo para modificar ese comportamiento. Esta rama sirve exclusivamente para reunir y auditar el código fuente.

## Recuperado
- Código Perl y recursos extraídos de la distribución Windows RC1 (en el paquete local de fuentes, todavía pendiente de incorporar íntegramente a GitHub).
- Dos variantes distintas de `gcstar`: `payload/bin/gcstar` y `script/gcstar.pl` embebido en `gcstar.exe`. Deben conservarse ambas.
- Proyecto C# WebView2 en `src/JavKT9WebView2/`, ya presente en la rama `main`. Su equivalencia exacta con el ejecutable RC1 no está verificada.
- Scripts de instalación históricos: **no ejecutar ni reutilizar para RC1** sin revisión.

## Bloqueos para publicar
1. Faltan los proyectos fuente originales de `JavKT9.exe` y `GCJavBridgeLauncher.exe`.
2. Falta una receta comprobada para generar el PAR `gcstar.exe` desde fuentes.
3. Falta comprobar en Windows la compilación del host WebView2 y la cadena completa de construcción.
4. Faltan la revisión de licencias de dependencias y recursos, y la revisión de privacidad/secretos del árbol e historial.
5. No afirmar que el repositorio contiene «todos los fuentes correspondientes» hasta resolver lo anterior.

## Protección de versiones
No modificar `C:\Program Files\JavKT9` (0.8.0 Beta 1), ni las carpetas experimentales/RC1 instaladas. No aplicar la corrección P1 del Bridge: el usuario confirmó que la búsqueda RC1 ya funcionaba.

Procedencia del paquete de referencia: `JAVkt9_0.8.1_RC1_Beta_Publica_Windows(1).zip`, SHA-256 `08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4`.
