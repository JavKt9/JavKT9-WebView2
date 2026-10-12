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

## Resultado de compilación — 11 de octubre de 2026

**Compilación y subida a release borrador: EXITOSA.**

- [Workflow completado](https://github.com/JavKt9/JavKT9-WebView2/actions/runs/38182770423)
- Archivo: `JAVkt9_0.8.1_RC1_INNO_Setup_Program_Files_Windows_x64.exe`
- Tamaño: `111150088` bytes
- SHA-256: `ca36d83d5818904e19e591655ec51f8e74560c0cb6817e929ee5eb0eca1e2880`
- Ubicación: assets de la release **en borrador** `v0.8.1-rc1` (no publicada)
- Se verificó el ZIP fuente, la ausencia de las claves TMDB antiguas y la presencia de correcciones del Bridge, interfaz y favoritos antes de compilar.
- Se conservó el EXE candidato Go anterior como asset separado, sin borrarlo ni sustituirlo.

**Pendiente de prueba en Windows:** ejecutar **solo** este nuevo Setup Inno y confirmar que instala en `C:\Program Files\JavKT9-081-RC1-GitHub` y crea el acceso directo de escritorio. No hace falta repetir búsquedas ni pruebas de interfaz ya aprobadas.

**Pendiente antes de publicación pública:** completar fuentes correspondientes de ejecutables antiguos y avisos de licencias de terceros. No publicar la release todavía.
