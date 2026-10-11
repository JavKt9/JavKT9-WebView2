# Fuente exacta del instalador RC1 saneado

**Este directorio contiene el código Go exacto usado para compilar el Setup saneado privado**, separado del código del Setup candidato original para evitar dos funciones `main()` en un mismo paquete.

- Archivo: `main.go`
- Git blob SHA-1: `bc152a0e59e9e3c63c773a88c117a6dd842d5aa4`
- Compilador: Go 1.23.2, `GOOS=windows`, `GOARCH=amd64`, `CGO_ENABLED=0`
- Comando del stub: `go build -trimpath -ldflags="-H windowsgui" -o setup_stub.exe main.go`
- SHA-256 del stub verificado: `2d6dbfecbb318b0608cec7b9fb64a3ec99d8f2ee695eff83a7876032dfa03633`
- Tamaño del stub: **3.098.624 bytes**
- El ZIP saneado de **164.010.930 bytes** se concatena al stub sin modificarlo.
- SHA-256 del ZIP saneado: `094629d3bf92a6d0b43551751a8c64a2d57056b15209bac5ab375fc54a2eca13`
- SHA-256 del Setup final: `b68f9b8ef5c57645115f01b3dcae1d1e0ac2b6176d4182a163200bc1658ae73c`

El archivo ZIP de payload **no está almacenado en GitHub**; forma parte del instalador local verificado y de los archivos privados entregados. Este fuente **no** corresponde a los dos lanzadores antiguos `JavKT9.exe` y `GCJavBridgeLauncher.exe`.

El Setup instala en `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Saneada`, separado de las instalaciones anteriores. **No publicar** sin resolver fuentes de lanzadores/PAR, avisos de dependencias y prueba funcional de la nueva candidata.
