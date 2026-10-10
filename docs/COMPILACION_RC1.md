# Compilación verificable — JAVkt9 0.8.1 RC1

**Estado: compilación parcial, no instalador reproducible.** No ejecutar scripts antiguos que escriban en `C:\\Program Files\\JavKT9`.

## 1. Host C# WebView2: código disponible

Proyecto: `src/JavKT9WebView2/JavKT9WebView2.csproj` (Windows Forms, `net8.0-windows`, `win-x64`, .NET 8 self-contained, WebView2 NuGet `1.0.3537.50`).

En Windows, con .NET SDK 8 y conexión para NuGet:

```powershell
dotnet restore .\\src\\JavKT9WebView2\\JavKT9WebView2.csproj -r win-x64
dotnet publish .\\src\\JavKT9WebView2\\JavKT9WebView2.csproj -c Release -r win-x64 --self-contained true --no-restore -o .\\build-validation\\WebView2Host
```

Resultado esperado: `build-validation\\WebView2Host\\JavKT9WebView2.exe`. **No copiarlo sobre una instalación funcional.**

GitHub Actions: `.github/workflows/verificar-compilacion-webview2-rc1.yml` compila este host en Windows y verifica que exista el ejecutable; **no ejecuta búsquedas, no crea instalador y no publica una release**. Su resultado debe consultarse en Actions; tener el workflow no demuestra que haya pasado.

**Limitación:** el código fuente tiene referencias históricas a versiones 0.7.x en mensajes y títulos; no se ha demostrado que genere exactamente el host que se incluyó en la RC1. No actualizar esos textos ni sustituir el host funcional sin necesidad.

## 2. Código Perl: disponible para revisión

`src/perl/lib/gcstar/` contiene módulos Perl, el plugin JavLibrary y su Bridge. `src/perl/bin/gcstar` es el lanzador Perl plano de la RC1; `src/perl/par_embebido/script/gcstar.pl` es el script encontrado **dentro** de `gcstar.exe` PAR.

Ambos scripts son distintos:
- `src/perl/bin/gcstar`: versión declarada `1.8.1.RC-db9844e3`.
- `src/perl/par_embebido/script/gcstar.pl`: versión declarada `1.7.3`.

No hay receta confirmada de PAR::Packer ni inventario verificado de sus dependencias. No sustituir el `gcstar.exe` funcional por un paquete reconstruido especulativamente.

La inspección de los ejecutables originales con `go version -m` confirmó que **`JavKT9.exe` y `GCJavBridgeLauncher.exe` fueron compilados con Go 1.23.2** para Windows/amd64, sin CGO y con `-trimpath=true`. Véase [LANZADORES_GO_RC1.md](LANZADORES_GO_RC1.md). No se encontraron archivos `.go` de esos lanzadores entre los nombres de archivos de 36 ZIP examinados.

## 3. Componentes que bloquean una compilación completa

| Binario RC1 | Fuente actual | Verificación |
| --- | --- | --- |
| `payload/JavKT9.exe` | Fuentes **Go 1.23.2** originales ausentes | **Bloqueado** |
| `payload/bin/GCJavBridgeLauncher.exe` | Fuentes **Go 1.23.2** originales ausentes | **Bloqueado** |
| `payload/bin/gcstar.exe` | Script interno recuperado, receta PAR ausente | **Bloqueado** |
| `payload/bin/WebView2Host/JavKT9WebView2.exe` | Proyecto C# presente | Compilación CI por verificar; equivalencia RC1 no comprobada |

Los recursos `payload/share/gcstar/` (348 archivos) y las dependencias `payload/usr/` también son necesarios para una distribución funcional y requieren revisión de licencias.

## 4. Instaladores

`installer/JavKT9.iss` contiene `MyAppVersion "0.8.0 Beta 1"`, `DefaultDirName={autopf}\\JavKT9` y borra componentes de extensión en `{app}`. Los workflows históricos construyen instaladores a partir de ZIP de releases, **no** desde fuentes completos.

**Prohibido utilizar esos scripts para instalar RC1 sobre Beta 1.** Antes de crear un instalador RC1 independiente, hace falta una receta auditada, ruta de destino distinta, pruebas de desinstalación y confirmación explícita.

## 5. Criterio de finalización

No declarar «compilación completa desde fuentes» hasta disponer de los dos proyectos fuente originales, receta PAR, dependencias identificadas y un proceso de construcción probado en Windows. No modificar el Bridge/WebView2 funcional solo para conseguir hashes idénticos.
