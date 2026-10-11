# Resultado comprobado del instalador RC1 saneado (11 de octubre de 2026)

**Se generó realmente un EXE nuevo y se verificó su contenido en el entorno de construcción local. No se publicó en GitHub Releases.**

## Archivo generado

- **Nombre:** `JAVkt9_0.8.1_RC1_Setup_SANEADA_PRIVADA_Windows_x64.exe`
- **Tamaño:** 167.109.554 bytes
- **SHA-256:** `b68f9b8ef5c57645115f01b3dcae1d1e0ac2b6176d4182a163200bc1658ae73c`
- **ZIP adjunto:** 164.010.930 bytes
- **SHA-256 del ZIP adjunto:** `094629d3bf92a6d0b43551751a8c64a2d57056b15209bac5ab375fc54a2eca13`
- **Cantidad de entradas verificadas:** 6.216
- **CRC:** comprobación completa correcta
- **Módulos saneados:** cuatro módulos TheMovieDB, sin exponer valores
- **Comparación:** todos los demás archivos del ZIP RC1 candidato se copiaron sin modificar. El instalador original probado quedó intacto.
- **Destino del nuevo instalador:** `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Saneada`, separado de la candidata probada.

## Procedimiento exacto

Se utilizó como base el ZIP RC1 candidato con SHA-256 `450ac674047e8df400fcfb242d25a0e4f5253f4cf664692b0ba0471028eb8e46` y el fuente Go original del instalador con Git blob `96949d9134d881815a0c263434a9c5d6d30e1b44`.

El proceso verificó los SHA-256 de los archivos originales, encontró los cuatro literales antiguos en cuatro módulos y **en ningún otro archivo del paquete**, los sustituyó por cadenas vacías, reempaquetó el ZIP, actualizó tamaño/hash y carpeta de instalación en el código Go y compiló un nuevo Setup para Windows x64 con Go. Se abrió el EXE como ZIP y se validaron los 6.216 archivos y el CRC.

**Distinción importante:** esta construcción local está verificada, pero el workflow GitHub Actions de la rama tiene un proceso propio que no se debe dar por ejecutado ni exitoso sin consultar sus resultados. El nuevo instalador **no ha sido ejecutado en Windows**. La RC1 anterior sí fue probada por el usuario.

## Bloqueos para publicación pública

1. Fuentes correspondientes de los dos lanzadores Go antiguos y del PAR GCstar, o reemplazo validado por una edición con fuentes.
2. Inventario y avisos de redistribución de dependencias Perl/GTK/.NET/WebView2 y recursos.
3. Verificación funcional acotada de la candidata saneada en Windows antes de reemplazar la RC1 probada.
4. Adjuntar el EXE como asset de una release y comprobar la descarga pública; el repositorio actual es privado.

**No modificar la RC1 instalada, `main` ni la release borrador existente.**
