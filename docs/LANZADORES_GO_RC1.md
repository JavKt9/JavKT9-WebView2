# Identificación de los lanzadores Windows RC1 — código fuente pendiente

**Comprobación estática realizada sobre los binarios originales de `JAVkt9_0.8.1_RC1_Beta_Publica_Windows(1).zip`.** No se ejecutó ningún programa Windows.

## Evidencia de compilación

La herramienta oficial `go version -m` (Go 1.23.2, Linux, leyendo los ejecutables PE Windows) devolvió:

### `payload/JavKT9.exe`

- SHA-256: `6b58edf13fda123db9cde93fec72d026033cd7ecc8c037e29dbd52157b4e25f6`.
- Tamaño: **1.947.648 bytes**.
- **Compilador Go 1.23.2**.
- `path command-line-arguments`.
- `-buildmode=exe`, `-compiler=gc`, `-trimpath=true`.
- `CGO_ENABLED=0`, `GOOS=windows`, `GOARCH=amd64`, `GOAMD64=v1`.

### `payload/bin/GCJavBridgeLauncher.exe`

- SHA-256: `1388e84d76c15a8a70ab56bfd0579f89af5a42fc0efff110f4da3dfcb5e02c69`.
- Tamaño: **1.804.288 bytes**.
- **Compilador Go 1.23.2**.
- `path command-line-arguments`.
- `-buildmode=exe`, `-compiler=gc`, `-trimpath=true`.
- `CGO_ENABLED=0`, `GOOS=windows`, `GOARCH=amd64`, `GOAMD64=v1`.

En ambos casos `go tool nm` informó `no symbols`; no hay símbolos de funciones disponibles mediante esa herramienta.

## Implicaciones

- **Las fuentes que faltan son proyectos o archivos `.go`**, no C# ni Perl. La salida `command-line-arguments` no identifica la ruta original ni el número de archivos Go.
- Se examinaron los nombres de archivos de **36 ZIP** disponibles en el entorno de auditoría. No se localizaron `.go` ni proyectos Go de esos lanzadores; solo se localizaron los fuentes C# del host WebView2 y scripts de instalación.
- El código Go original no se obtiene automáticamente de `go version -m`. Los binarios compilados **no** equivalen a su código fuente.
- **No sustituir estos dos ejecutables:** el usuario confirmó que la RC1 funciona. La auditoría busca los fuentes correspondientes, no una reescritura especulativa.
- La recuperación futura debe priorizar archivos `.go` y posibles scripts de compilación originales (por ejemplo `go build`, `go.mod`), si existen en respaldos o conversaciones previas. No se requiere que el usuario repita pruebas de películas.

## Prueba de compilación pendiente

Cuando se recuperen los archivos Go originales, reconstruir en un entorno aislado con **Go 1.23.2**, `GOOS=windows`, `GOARCH=amd64`, `CGO_ENABLED=0` y la configuración de compilación observada. No asumir que un nuevo ejecutable será idéntico byte a byte ni que puede reemplazar al funcional.

**Bloqueo de publicación:** hasta obtener esos fuentes o resolver adecuadamente las obligaciones de distribución, no declarar completo el repositorio público.
