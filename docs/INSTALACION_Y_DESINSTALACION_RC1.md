# Instalación de JAVkt9 0.8.1 RC1 — Windows x64

## Instalación

1. Obtener el archivo oficial `JAVkt9_0.8.1_RC1_Setup_Candidata_Windows_x64.exe`.
2. Antes de ejecutarlo, verificar su SHA-256 con PowerShell:
   ```powershell
   Get-FileHash .\JAVkt9_0.8.1_RC1_Setup_Candidata_Windows_x64.exe -Algorithm SHA256
   ```
   Valor esperado: `927dccc7df6b39c08a423edcf22071254e53a2c7a49fa2c32b799d2763dc4f23`.
3. Cerrar otras ediciones de JAVkt9 y GCJav, si están abiertas.
4. Ejecutar el instalador. Confirmar la carpeta de instalación que se muestra en pantalla.
5. Abrir JAVkt9 desde el menú Inicio.
6. La primera búsqueda puede mostrar el WebView2 integrado para completar una verificación; después puede realizar búsquedas sin abrir un navegador externo.

**Carpeta de esta candidata:** `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Instalada`. Para abrirla, presionar `Win + R` y pegar la ruta.

**Advertencia de SmartScreen:** el archivo no está firmado digitalmente. Verificar que el archivo proviene de la descarga oficial y que coincide el hash; si hay dudas, no ejecutarlo. No se recomienda desactivar SmartScreen ni antivirus.

## Otras instalaciones

Esta candidata se instala separada de `C:\Program Files\JavKT9`, `C:\Program Files\JavKT9-081-RC1` y carpetas experimentales. No borrar ni modificar esas carpetas. Si la carpeta de destino ya existe, el instalador se detiene para evitar sobrescritura.

## Desinstalación

Usar **Configuración → Aplicaciones → Aplicaciones instaladas → JAVkt9 0.8.1 RC1** (si aparece con ese nombre), o ejecutar `Desinstalar-JAVkt9.exe` desde la carpeta de instalación. La desinstalación está diseñada para quitar únicamente esta candidata; los datos de usuario y otras instalaciones deben conservarse.

## Si la búsqueda no funciona

Cerrar JAVkt9 y cualquier otra versión que use el puerto 53118; volver a iniciar la candidata y comprobar la conexión a Internet. Si aparece un error, conservar una captura del mensaje. No copiar archivos del Bridge o WebView2 de otras instalaciones para intentar repararlo.

## Estado

El usuario confirmó que **la instalación, la apertura del programa y la búsqueda WebView2 funcionaron** en su equipo. Esta documentación no implica que el instalador esté firmado o que se haya probado en otros equipos.
