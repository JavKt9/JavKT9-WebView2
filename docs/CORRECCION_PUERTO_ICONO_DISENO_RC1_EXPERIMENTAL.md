# Corrección integrada de puerto, ícono y ficha — RC1 experimental

**11 de octubre de 2026.** El usuario confirmó que **dos búsquedas WebView2 funcionan** después del parche de captura, pero también reprodujo un Bridge `wperl.exe` huérfano en el puerto `53118` y rechazó el cambio visual que trasladaba la carátula a la derecha.

## Paquete privado generado y verificado

`JAVkt9_RC1_CORRECCION_PUERTO_ICONO_Y_DISENO_EXPERIMENTAL.zip`

- Tamaño: **2.768.028 bytes**.
- SHA-256: `f59e0ddcd3354a97900058e46cee8d1fb20103508667f1472465c51a9ca2c551`.
- Contiene ejecutable Go Windows x64 recompilado, Bridge Perl modificado, archivo original `GCfilms.gcm`, verificador PowerShell, ícono, fuentes, pruebas y script de instalación con respaldo.
- **Nuevo `JavKT9.exe`** SHA-256: `efb06a6467a9f0b5da07916780d4073a8662b74b34bf4ae7a7f60b6fff26734f`.
- **Nuevo `GCJavLibraryBridge.pl`** SHA-256: `d81c5dae5fb8e83898278c70f0c5d6e825d37797c2e4acb13ca50fb226fa0d07`.

### Puerto 53118: corrección de ciclo de vida

1. El lanzador genera un token aleatorio de 192 bits para **su propia sesión** y se lo pasa al Bridge mediante `JAVKT9_BRIDGE_SESSION`.
2. El Bridge nuevo acepta `GET /shutdown?key=...` **solo** con el token de esa sesión. Una petición con clave incorrecta recibe HTTP 403.
3. Al cerrar GCstar, el lanzador pide al Bridge que finalice y espera que libere el puerto.
4. Si quedó un Bridge antiguo sin token, un script PowerShell identifica el PID propietario del puerto y **solo lo finaliza si tanto el ejecutable `wperl.exe` como la ruta absoluta del script `GCJavLibraryBridge.pl` pertenecen a esta instalación experimental** y no hay un `gcstar.exe` de la misma instalación activo. Si pertenece a otro programa o edición, no se cierra y se informa del bloqueo.
5. El token de sesión anterior puede recuperarse de la carpeta aislada para solicitar cierre limpio al iniciar de nuevo tras un cierre anormal.

**No se usan comandos `taskkill /IM wperl.exe` ni se cierran procesos de otras instalaciones.**

### Diseño e ícono

- Se **restaura el modelo original** `GCfilms.gcm` SHA-256 `64fa82c2ad5d699e9988c8567ea3974a2f4a1d53d853e581ae827d6b7d7f0899`, con carátula a la izquierda, descartando el ajuste no deseado.
- Se recompiló el lanzador con el ícono original `JavKT9.ico` incrustado en recursos PE `RT_ICON` y `RT_GROUP_ICON`. Se verificó que el directorio de recursos de Windows contiene **siete tamaños de ícono** y un grupo.
- Se conserva el ajuste de ruta de captura WebView2 que permitió importar dos películas. **No se modificó el host WebView2.**

### Pruebas realizadas en entorno de compilación

- `go test`: **cinco pruebas unitarias correctas**.
- Compilación Windows x64 de `JavKT9.exe` y del binario de pruebas: correcta.
- `perl -c GCJavLibraryBridge.pl`: sintaxis correcta.
- **Prueba real del servidor Perl local**: `/ping` devolvió OK, `/shutdown` con clave errónea devolvió HTTP 403 y el proceso siguió vivo; `/shutdown` con clave correcta devolvió OK y el proceso terminó con código 0.
- ZIP: integridad CRC verificada.
- Recursos PE: comprobación del ícono mediante `objdump`.

**Pendiente:** ejecutar en Windows la prueba de abrir, cerrar y volver a abrir la edición experimental sin usar CMD ni `taskkill`. El script PowerShell de identificación de procesos no se ha ejecutado en Windows en este entorno. Por tanto, **no afirmar todavía que el problema quedó resuelto en Windows**.

### Instalación del parche

Cerrar la edición experimental, extraer el ZIP y ejecutar `APLICAR_CORRECCION.cmd`, confirmar `SI`. Se valida el SHA-256 de cada archivo, se guardan copias y se actúa **solo** en `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Fuentes-Prueba`. Si los archivos instalados no coinciden con los hashes esperados, se cancela sin sobrescribir.

No tocar la RC1 probada, biblioteca original, `main` ni la release borrador. No publicar hasta completar validación de Windows y redistribución de terceros.
