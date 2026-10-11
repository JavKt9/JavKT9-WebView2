# RC1 saneada — trabajo final para GitHub

**Objetivo:** preparar una candidata Windows `Setup.exe` sin las cuatro claves antiguas, preservando el motor, el Bridge y WebView2 de la RC1 que el usuario probó.

## Qué se preparó

- Rama aislada `rc-0.8.1-setup-saneado-privado`, sin modificar `main` ni la instalación del usuario.
- `tools/preparar_setup_rc1_saneado.py`: toma el ZIP RC1 original y **exige su SHA-256**, compara los cuatro módulos con el código fuente ya saneado en GitHub y **solo** elimina el valor de cada clave.
- Si otro archivo del payload contiene esos valores, el proceso **falla** en lugar de publicar un paquete inseguro.
- Intenta inspeccionar el contenido PAR como ZIP; si no puede, registra expresamente la limitación. No declara que el PAR esté libre de secretos por inferencia.
- Empaqueta las fuentes Perl, C# WebView2, licencia, créditos y código fuente del instalador.
- Genera un instalador Go para Windows x64 con **otra carpeta de destino**, `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Saneada`, para no reemplazar la RC1 probada.
- Workflow `.github/workflows/preparar-setup-rc1-saneado.yml`: ejecuta pruebas, arma el EXE, valida el ZIP adjunto y, si todo sale bien, guarda un **artefacto privado de GitHub Actions** y un informe con SHA-256.

## Cómo saber si terminó

**La compilación local del Setup saneado ya se completó y se verificó**: ver `docs/RESULTADO_COMPILACION_LOCAL_RC1_SANEADA.md`, con SHA-256 y 6.216 entradas. Su código Go exacto está en `src/instalador-rc1-saneado/main.go`. **El workflow de GitHub Actions es otro procedimiento:** no se debe dar por exitoso sin consultar sus resultados; si falla, no invalida el EXE local ya verificado.

El instalador saneado es **una compilación distinta** de la probada. No afirmar que se probó su instalación en Windows.

## Qué impide todavía publicarlo para todos

1. Resolver la correspondencia de fuentes de los dos lanzadores Go antiguos y del ejecutable PAR GCstar, o distribuir una edición con componentes nuevos que sí dispongan de fuentes y estén validados.
2. Completar los avisos de licencia y derechos de redistribución de las dependencias y recursos incluidos.
3. Confirmar que el paquete final está saneado, y hacer una verificación acotada del nuevo instalador si se modifica el contenido.
4. Adjuntar `Setup.exe` a GitHub Releases y asegurar que sea públicamente descargable. El repositorio sigue privado.

**No se repetirá la auditoría de instalación y búsqueda WebView2 del instalador original**: el usuario ya la confirmó. Tampoco se modifica la RC1 instalada.
