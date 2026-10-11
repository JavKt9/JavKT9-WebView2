# Instalador Windows JAVkt9 0.8.1 RC1 — fuentes Go

Este es el **código fuente real del instalador candidato probado** por el usuario, recuperado del paquete `JAVkt9_0.8.1_RC1_Setup_Codigo_Fuente.zip`. No es el código fuente de los dos lanzadores antiguos de la aplicación.

- Licencia del instalador: `GPL-2.0-or-later`.
- Entorno: Go 1.23.2, Windows x64, sin paquetes Go externos.
- Código: `main.go`.
- Se compila el stub con `GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags="-H windowsgui" -o setup-stub.exe main.go`.
- El EXE distribuido concatena el `setup-stub.exe` y el ZIP `JAVkt9_0.8.1_RC1_PORTABLE_CON_FUENTES_CANDIDATA.zip`, cuyo SHA-256 debe ser `450ac674047e8df400fcfb242d25a0e4f5253f4cf664692b0ba0471028eb8e46`.
- El instalador final candidato tiene SHA-256 `927dccc7df6b39c08a423edcf22071254e53a2c7a49fa2c32b799d2763dc4f23`.
- No ejecutar sobre las instalaciones existentes. No publicar la RC1 antigua sin resolver el inventario de dependencias y los fuentes faltantes.

**Importante:** los binarios Go antiguos `JavKT9.exe` y `GCJavBridgeLauncher.exe` no se derivan de este archivo. El proyecto de reemplazo con fuentes se encuentra en `edicion-publica-desarrollo`.
