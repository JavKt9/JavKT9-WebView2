# JAVkt9 0.8.1 RC1 — Notas de la candidata con instalador

**Estado: candidata probada por el usuario, pendiente de habilitación para distribución pública.**

## Qué incluye

JAVkt9 es un gestor de colecciones de películas basado en GCstar, con búsqueda de metadatos mediante un navegador **WebView2 integrado**. Esta candidata contiene el mismo programa de la RC1 funcional, reempaquetado en un instalador Windows `.exe`, **sin cambios al Bridge Perl ni al host WebView2**.

**Archivo:** `JAVkt9_0.8.1_RC1_Setup_Candidata_Windows_x64.exe`  
**Tamaño:** 168.277.681 bytes  
**SHA-256:** `927dccc7df6b39c08a423edcf22071254e53a2c7a49fa2c32b799d2763dc4f23`

## Compatibilidad

- Windows de 64 bits; instalador por usuario, sin privilegios de administrador.
- Destino: `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Instalada`.
- Acceso desde menú Inicio y entrada de desinstalación de Windows.
- No sustituye la versión Beta 1, las carpetas RC1 previas ni la edición experimental.
- **No abrir al mismo tiempo otra edición que use el Bridge en el puerto 53118.**

## Validación realizada

El usuario confirmó el **10/11 de octubre de 2026** que:
1. El instalador llegó a la pantalla de confirmación y completó la instalación.
2. El programa se abrió correctamente desde la nueva instalación.
3. La búsqueda de películas mediante WebView2 **funcionó**.

Estas pruebas acreditan las funciones principales probadas en ese equipo. No equivalen a una prueba automatizada en todos los Windows ni a una revisión de seguridad del instalador.

## Aviso de Windows

El instalador es nuevo y **no tiene firma digital**. Microsoft Defender SmartScreen puede mostrar «Editor desconocido» o «Windows protegió su PC». No se debe prometer que no habrá avisos de seguridad. Una firma Authenticode válida y reputación del editor son las vías adecuadas para mejorar la confianza, pero una firma no sustituye el análisis de seguridad.

## Código fuente, atribución y dependencias

JAVkt9 deriva de **GCstar** y conserva la licencia GNU GPL v2 y sus avisos. El código Perl recuperado y el proyecto C# están en el repositorio privado. Se adjuntó un archivo de fuentes recuperadas a esta candidata.

**Limitaciones expresas:** no se recuperaron los fuentes originales de los dos lanzadores Go de esta RC1; no se dispone de una receta de compilación verificada del ejecutable PAR `gcstar.exe`; y falta cerrar el inventario de licencias y avisos de dependencias. Por lo tanto, **no presentar todavía este archivo como una distribución pública con cumplimiento comprobado**.

## Cambios de esta candidata

- Nuevo instalador Windows por usuario, independiente de las instalaciones previas.
- No hay cambios funcionales al motor Perl, WebView2 ni a los ejecutables originales de la RC1.

## Próximo paso para GitHub

Adjuntar el archivo `.exe` a una release candidata con estas notas, junto a fuentes y avisos correspondientes, **una vez resueltas las condiciones de redistribución**. El repositorio y la release actual siguen privados/en borrador. No publicar automáticamente.
