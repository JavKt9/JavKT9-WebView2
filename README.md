# JavKT9 0.7.1 WebView2 Experimental

Proyecto mínimo para compilar automáticamente en GitHub Actions un host WebView2 x64 separado de GCJav 0.6.31.

## Compilar sin instalar Visual Studio
1. Crear un repositorio nuevo en GitHub.
2. Subir el contenido de este ZIP a la raíz del repositorio.
3. Abrir **Actions** > **Build JavKT9 WebView2 Windows** > **Run workflow**.
4. Al terminar, descargar el artifact `JavKT9-0.7.1-WebView2-Experimental-win-x64`.

El host usa `%LOCALAPPDATA%\JavKT9\WebView2` como perfil y guarda el HTML capturado en `%LOCALAPPDATA%\JavKT9\WebView2Capture`.
