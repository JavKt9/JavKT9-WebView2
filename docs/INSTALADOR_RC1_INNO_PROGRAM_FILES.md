# Instalador RC1 clásico (Inno Setup) — Program Files

**Objetivo:** recuperar el instalador visual de las versiones anteriores de JAVkt9. La candidata anterior se instalaba en `%LOCALAPPDATA%\Programs` mediante un instalador Go mínimo. Ese diseño fue rechazado por el usuario.

## Qué cambia

- Instalador **Inno Setup 6**, asistente moderno en español con pantalla de bienvenida, licencia y selección de carpeta.
- Instalación por defecto en **`C:\Program Files\JavKT9-081-RC1-GitHub`**. Pide permiso de administrador (UAC).
- Acceso directo en **Escritorio** seleccionado por defecto y acceso en **Inicio**.
- Desinstalador estándar de Windows, con ícono de JAVkt9.
- Opción para abrir JAVkt9 al finalizar.
- **No sobrescribe** `C:\Program Files\JavKT9`, `JavKT9-081-Experimental`, `JavKT9-081-RC1`, la RC1 instalada en AppData, GCJav ni bibliotecas personales.

## Cómo se construye

Se reutiliza el **EXE candidato integrado ya subido a la release borrador** (`JAVkt9_0.8.1_RC1_GITHUB_CANDIDATA_Setup_Windows_x64.exe`, SHA-256 `bb45bce1024598abc9688bc20abedc7083ac3ad103bd470ae619a11640f5ff88`) únicamente como **fuente del ZIP de payload adjunto**. `extract_candidate.py` comprueba hash, CRC, contenido esencial, claves saneadas y correcciones de interfaz/Bridge antes de extraerlo. No modifica `JavKT9.exe` ni los módulos.

El workflow `build-rc1-inno-program-files.yml` descarga ese asset **privado** desde la release `v0.8.1-rc1`, instala Inno Setup y genera un nuevo instalador `JAVkt9-0.8.1-RC1-GitHub-Setup-Windows-x64.exe` como **artefacto privado de GitHub Actions**. No publica una release automáticamente.

## Estado y próximos pasos

Este instalador se diseñó para corregir el problema señalado por el usuario. **No afirmar compilación ni prueba de instalación hasta verificar el workflow y probar el EXE nuevo en Windows.**

Una vez comprobado, sustituir en el borrador el asset del Setup Go anterior por el nuevo Setup Inno. **No publicar aún** hasta resolver la correspondencia de fuentes de `gcstar.exe` PAR y los avisos de licencias de terceros. No pedir que se vuelvan a probar las dos películas ni los ajustes de interfaz que ya fueron aprobados; basta una instalación de humo de este nuevo Setup.

El ícono del instalador y los accesos directos proceden de `installer/JavKT9.ico`, utilizado por las versiones anteriores.
