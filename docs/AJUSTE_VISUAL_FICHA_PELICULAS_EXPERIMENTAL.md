# Ajuste visual reversible de ficha de películas — RC1 experimental

**11/10/2026.** Usuario confirma que el buscador WebView2 ya importó correctamente **dos películas** tras el parche de rutas. El bloqueo del puerto 53118 fue causado por un `wperl.exe` persistente, y se liberó de forma manual.

## Verificación de la regresión visual

La ficha muestra `Título original` alineado a la izquierda, mientras `Fecha de salida`, `Director` y `Duración` aparecen más a la derecha.

Se comparó byte a byte `payload/lib/gcstar/GCModels/GCfilms.gcm` entre el **ZIP RC1 original** y el **Setup experimental con lanzadores nuevos**. El SHA-256 en ambos es exactamente:

`64fa82c2ad5d699e9988c8567ea3974a2f4a1d53d853e581ae827d6b7d7f0899`

**Conclusión:** el desplazamiento NO lo introdujeron los lanzadores ni el parche WebView2; estaba definido así en la ficha original: la carátula ocupaba columna 0, filas 1 a 3, y los rótulos restantes ocupaban columna 1.

## Ajuste opcional preparado

Se generó `JAVkt9_RC1_Ajuste_Alineacion_Experimental.zip` de **5.587 bytes** (SHA-256 `278e9973846836b8e6180b86262180546856d1f7692bae9b68e6199b1df2dc8c`).

El ajuste de `GCfilms.gcm`:

- Mueve los rótulos Fecha/Director/Duración de la columna 1 a la columna 0, alineados con Título original.
- Mueve sus valores de columna 2 a columna 1.
- Mueve la carátula de la columna 0 a la **columna 3 (derecha)**, manteniendo las mismas filas y el mismo tamaño.
- **No modifica el modelo de datos, las películas, el buscador, el Bridge ni la RC1 original.**
- El XML resultante pasó validación de sintaxis.
- SHA-256 del modelo ajustado: `96c82f4c41e7f46f9ccda3912345be4c812e95030ce1dd265ca9ac7cef819cff`.

El ZIP contiene `APLICAR_AJUSTE.cmd`, `Aplicar-Ajuste.ps1`, `GCfilms.gcm`, `RESTAURAR_DISENO.cmd`, `Restaurar-Diseno.ps1` y `LEEME.txt`.

El script verifica el SHA-256 original antes de aplicar, solo actúa en `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Fuentes-Prueba\lib\gcstar\GCModels\GCfilms.gcm`, guarda un respaldo, verifica el archivo nuevo y permite restaurar el original. **No se ha ejecutado todavía en Windows**, por lo que su aspecto visual final requiere confirmación.

## Para cierre

Integrar el ajuste solo si el usuario aprueba la carátula a la derecha y confirma el resultado visual. No incorporar el cambio de distribución a la RC1 original ni a `main` sin esa aprobación. Corregir por separado el icono de Windows del nuevo lanzador y el cierre limpio del Bridge, para evitar bloquear futuras aperturas por el puerto 53118.
