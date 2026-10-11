# Lanzador RC1 nuevo — fuente disponible

Este directorio contiene el código Go de `JavKT9.exe` que se utilizó en la candidata integrada. **No es el código original del lanzador antiguo de GCstar**.

El código Perl de la ficha, los favoritos y el Bridge se encuentra en `src/perl/lib/gcstar`. El código del instalador se encuentra en `src/instalador-rc1-github/main.go`.

## Pruebas y compilación

```sh
GO111MODULE=off go test .
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 GO111MODULE=off go build -trimpath -ldflags="-s -w -H windowsgui" -o JavKT9.exe .
```

Para reproducir el **ícono PE integrado** del EXE entregado, copiar también `rsrc_windows_amd64.syso` del archivo de código disponible `FUENTES_RECUPERADAS_RC1.zip` a este directorio antes de compilar. Ese archivo binario de recursos **no está almacenado en Git**. El icono de ventana GTK está incluido en el payload como `icons/JavKT9-window.png`.

**No se garantiza igualdad binaria byte a byte al recompilar en una ruta o con opciones distintas.** La candidata distribuida incluye el EXE exacto verificado por SHA-256.

El guard de puerto `BridgePortGuard.ps1` se copia a la raíz de la instalación. Cierra únicamente procesos `wperl.exe` del Bridge que pertenezcan a esa misma instalación, no a otras aplicaciones.

Este directorio no acredita por sí solo la correspondencia de fuentes del `gcstar.exe` empaquetado mediante PAR.
