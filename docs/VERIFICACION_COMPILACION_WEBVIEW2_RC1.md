# Verificacion de compilacion WebView2 RC1

**RESULTADO: COMPILACION CORRECTA EN WINDOWS** (GitHub Actions).

Se ejecuto `dotnet restore` y `dotnet publish` para `src/JavKT9WebView2/JavKT9WebView2.csproj`, con .NET SDK 8, `win-x64` y `--self-contained true`.

Se genero `JavKT9WebView2.exe` en una carpeta temporal del runner. No se publico, instalo ni ejecuto el host.

**No se ha comprobado equivalencia con el EXE RC1 ni funcionamiento de WebView2 con JavLibrary.** Tampoco se han compilado `JavKT9.exe`, `GCJavBridgeLauncher.exe` ni el instalador.
El SHA-256 del ejecutable generado se muestra en los registros de GitHub Actions; la comparación con el binario distribuido aún está pendiente.

