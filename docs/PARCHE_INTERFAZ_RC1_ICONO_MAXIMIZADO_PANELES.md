# Parche de interfaz RC1 experimental — 11/10/2026

**Estado:** parche ZIP generado y verificado por hash/CRC. **No ejecutado todavía en Windows**. No publicar como release.

**Archivo:** `JAVkt9_RC1_Parche_Interfaz_Icono_Maximizado_Listas_Paneles.zip` — 294.425 bytes, SHA-256 `eba997c9be6cc321cb6b1d5d1f6283c6b7315bb736f767cfd2bf7e80c2e37835`.

## Cuatro problemas reportados con capturas

1. **Ícono de GCstar en la barra de tareas:** `GCMainWindow.pm` establecía la lista de íconos GTK3 a partir de `share/gcstar/icons/gcstar_*.png`. Se cambia para cargar `icons/JavKT9-window.png`, obtenido **del GCJav.ico original** del paquete; `set_icon` en la ventana y `set_default_icon_list` en GTK3. Se conserva fallback al icono anterior si falla la carga.
2. **Ventana no maximizada:** después de `show_all`, en Windows se ejecuta `maximize`. No se cambia la lógica de guardar ancho/alto al salir.
3. **Listas Géneros y Actores recortadas durante segundos al maximizar:** se solicita una sola recalculación de tamaño del panel y divisor con `Glib::Timeout->add(180,...queue_resize)` tras maximizar. Es un intento acotado; requiere comprobar GTK3 en Windows.
4. **«Enlaces de modelos» se oculta al reabrir, y no recuerda la elección:** `GCPanel.pm` ahora carga/guarda el estado de cada expander mediante `notify::expanded` en `GCS_CONFIG_HOME/JavKT9-expanders.txt`, con clave modelo/panel/título. Se guardan estados de Géneros, Actores y Enlaces de modelos, sin alterar las películas. En `GCfilms.gcm`, «Enlaces de modelos» se establece abierto **solo como predeterminado**, pero el valor guardado prevalece.

## Alcance y reversibilidad

El ZIP incluye los archivos Perl `GCMainWindow.pm` y `GCPanel.pm`, el modelo `GCfilms.gcm` basado en la **ficha compacta aprobada**, ícono original y PNG derivado, script `APLICAR_INTERFAZ.cmd`, PowerShell, manifiesto SHA-256, LEEME y script de restauración `RESTAURAR_INTERFAZ.cmd`.

Se validaron los hashes de todos los archivos, el XML y el CRC del ZIP. El instalador PowerShell **comprueba los hashes anteriores y nuevos antes de modificar** y realiza respaldos individuales `.antes_interfaz_final`. **Solo** escribe en `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Fuentes-Prueba`. No cambia `JavKT9.exe`, `gcstar.exe`, Bridge, WebView2, biblioteca de películas, RC1 original ni `main`.

**Limitaciones:** no se pudo ejecutar GTK3 Windows en el entorno de compilación; el efecto real del ícono y de la recalculación de listas aún necesita validación. La firma digital del instalador y las obligaciones de licencias de terceros siguen pendientes antes de publicar una RC pública.

**Importante:** el buscador WebView2 ya fue probado por el usuario con dos películas, por lo que no se vuelve a tocar en este parche.
