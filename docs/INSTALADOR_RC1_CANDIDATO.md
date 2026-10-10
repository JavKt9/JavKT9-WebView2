# Instalador EXE — JAVkt9 0.8.1 RC1 candidata

**Se preparó un instalador real para Windows x64**, distinto del paquete portátil anterior. Este instalador es nuevo y se generó a partir de la RC1 funcional **sin modificar sus ejecutables, Bridge ni WebView2**.

- Archivo: `JAVkt9_0.8.1_RC1_Setup_Candidata_Windows_x64.exe`
- Tamaño: **168.277.681 bytes**
- SHA-256: `927dccc7df6b39c08a423edcf22071254e53a2c7a49fa2c32b799d2763dc4f23`
- Formato: **PE32+ Windows GUI x64**; instalador nuevo Go 1.23.2, con ZIP RC1 íntegro adjunto.
- SHA-256 del ZIP interno: `450ac674047e8df400fcfb242d25a0e4f5253f4cf664692b0ba0471028eb8e46` (6.216 entradas).
- Instalación **por usuario**, sin elevación: `%LOCALAPPDATA%\\Programs\\JAVkt9-081-RC1-Instalada`.
- Incluye acceso directo en menú Inicio, entrada en «Aplicaciones instaladas» y `Desinstalar-JAVkt9.exe`.
- Incluye `FUENTES_RECUPERADAS_RC1.zip` en la instalación.
- **No modifica** `C:\\Program Files\\JavKT9`, `C:\\Program Files\\JavKT9-081-RC1` ni GCJav. Si ya existe la carpeta de la candidata, se detiene en vez de sobrescribirla.
- Comprueba SHA-256 de todo el ZIP adjunto antes de extraerlo; valida rutas, duplicados y tamaño.
- Excluye scripts de inicio/diagnóstico que pudieran usar rutas de instalación anteriores.
- Desinstala únicamente esta instalación, conservando datos de usuario y otras versiones.

**Pruebas realizadas:** compilación cruzada con Go 1.23.2; `go vet` Windows; validación de formato PE; validación del ZIP interno por Python y por `archive/zip` de Go; integridad CRC de 6.216 entradas y SHA-256 del adjunto. **No se pudo ejecutar el instalador en Windows desde el entorno de construcción.** No afirmar que se probó su instalación ni el funcionamiento completo del buscador después de instalarlo.

**Estado:** candidata privada para evaluación. Los ejecutables Go originales de la RC1 siguen sin fuentes originales disponibles y hay licencias de dependencias pendientes. Este instalador no resuelve esas obligaciones ni debe publicarse como una release pública completa todavía. El nuevo código del instalador se entrega por separado como fuente GPL-2.0-or-later.

La RC1 funcional, la rama `main` y el borrador de release `v0.8.1-rc1` no fueron alterados.
