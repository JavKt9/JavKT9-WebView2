# Corrección concreta: búsqueda WebView2 en edición experimental

**Síntoma observado en Windows (11/10/2026):** JAVkt9 experimental abre, pero la búsqueda de `MIDA-726` tarda más de dos minutos y termina sin datos.

## Defecto encontrado en código

El nuevo lanzador Go aísla `LOCALAPPDATA` del proceso Perl bajo `JavKT9-Publica-Desarrollo/Runtime`. El Bridge `GCJavLibraryBridge.pl` busca la captura HTML bajo esa ruta aislada. **Pero el host .NET original** usa `Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)` para escribir `JavKT9/WebView2Capture/<codigo>.html` en el directorio real de Windows. Por tanto, host y Bridge no coinciden en la ruta de captura. Esto es una **causa técnica demostrada por los fuentes**, aunque aún falta comprobar en Windows que sea la única causa de la falla.

## Parche privado construido, sin reinstalar

`JAVkt9_RC1_Parche_Buscador_WebView2_Experimental.zip` (2.001.647 bytes; SHA-256 `6ad756f61d03c720208c79171f2a1c26536a3988b3e5ac45d20886860face9a5`).

Se recompiló el nuevo lanzador Windows x64 con Go y se modificó **solo el Bridge Perl experimental**. El lanzador pasa al proceso hijo `JAVKT9_WEBVIEW2_CAPTURE_BASE` con el valor original de `LOCALAPPDATA` antes del aislamiento; el Bridge utiliza ese valor **solo para buscar el archivo HTML del host**. Sus registros y cachés continúan aislados. Se mantiene el host WebView2 original, el motor GCstar y la biblioteca original sin cambios.

| Archivo | SHA-256 anterior | SHA-256 nuevo |
| --- | --- | --- |
| `JavKT9.exe` | `4f1fe6fa687b8f4f056b66d470495b3c87cca45dca5c947832a9531f86bffe61` | `b529d4416936c79cb5beb47d33c82869dc1720567b453feb6b6d4cc2b3518e3f` |
| `lib/gcstar/GCPlugins/GCfilms/GCJavLibraryBridge.pl` | `2a1b0aa47b302672a9f933509b4b031b2b050a4ed118e3ffd84ee59d7159aa11` | `7c6493640af505a72e391bf0567675408169c64103dd168b661b3f1f7161f29b` |

### Cambios mínimos

En el nuevo lanzador Go, antes de sobrescribir `LOCALAPPDATA` del hijo:

```go
env = setEnv(env, "JAVKT9_WEBVIEW2_CAPTURE_BASE", localData)
```

En el Bridge Perl experimental:

```perl
my $capture_local = $ENV{JAVKT9_WEBVIEW2_CAPTURE_BASE} || $local;
sub capture_path {
    my ($code) = @_;
    return File::Spec->catfile($capture_local, 'JavKT9', 'WebView2Capture', "$code.html");
}
```

El ZIP contiene los **fuentes completos modificados** (Go y Perl), un `.cmd` y un script PowerShell. El script comprueba los SHA-256 anteriores, confirma la instalación **solo** en `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Fuentes-Prueba`, crea respaldos y sustituye únicamente esos dos archivos tras confirmación. No cambia ni desinstala otras versiones.

**Limitación consciente:** el host WebView2 original sigue utilizando su perfil habitual de Windows, igual que en la prueba anterior; el aislamiento completo del perfil del navegador requiere compilar y validar el host público separado. **No es aún una release pública ni está validado el parche en Windows.**

**Siguiente prueba útil:** una única búsqueda en la edición experimental ya parcheada; si falla, consultar `%LOCALAPPDATA%\JavKT9-Publica-Desarrollo\Runtime\JavKT9\JavKT9-webview2-bridge.log` y `%LOCALAPPDATA%\JavKT9\JavKT9-webview2.log` antes de generar otra versión.
