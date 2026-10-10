# Compilación — alcance actual (RC1)

Solo está disponible en el repositorio el proyecto C# del host WebView2. En Windows, con .NET SDK 8:

```powershell
dotnet restore .\src\JavKT9WebView2\JavKT9WebView2.csproj
dotnet publish .\src\JavKT9WebView2\JavKT9WebView2.csproj -c Release -r win-x64 --self-contained true
```

**No es una compilación verificada aquí**, ni se ha probado que produzca el ejecutable distribuido en RC1.

No hay receta completa y verificada para `JavKT9.exe`, `GCJavBridgeLauncher.exe`, `gcstar.exe` (PAR) ni el instalador RC1.

El script `installer/JavKT9.iss` heredado corresponde a Beta 1 y puede usar la ruta de la instalación estable. **No usarlo para RC1.**

No copiar ningún resultado de compilación a las instalaciones funcionales.
