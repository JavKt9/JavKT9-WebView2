# Corrección de la ficha de películas: referencia segunda captura

**11/10/2026.** El usuario indica que la **segunda captura** es el diseño de referencia: carátula a la izquierda, datos a lo ancho, sin espacio vacío grande y sin Fecha/Director/Duración desplazados a la derecha. La primera captura, con contenido encogido y mucho espacio, **no es el diseño deseado**.

## Parche generado y verificado

Archivo: `JAVkt9_RC1_FICHA_COMPACTA_Y_CAMPOS_ALINEADOS.zip`

- Tamaño: **9.058 bytes**.
- SHA-256: `ccf544ec11496dd22dc2f3650e1c1996c558c105abd130b5bb0171ce6ed186c8`.
- **No incluye EXE ni DLL.** Solo el XML `GCfilms.gcm`, original de respaldo y scripts para aplicar/restaurar.
- Archivo original SHA-256: `64fa82c2ad5d699e9988c8567ea3974a2f4a1d53d853e581ae827d7f0899`.
- XML modificado SHA-256: `8004eeebead6da2cb2d248bbae93e53bea4eba46760e978c1e7558058f80fcef`.
- XML validado y **mismos campos del formulario**, sin quitar atributos de películas.

## Corrección técnica mínima

El formulario original coloca `Título original` en un **grid de cuatro columnas**, con el campo abarcando tres columnas. GTK3 distribuye su ancho de modo que la columna donde están los rótulos Fecha/Director/Duración se estira; los campos correspondientes empiezan demasiado a la derecha.

El parche separa la fila de Título original en un `line` de ancho completo, y coloca debajo un grid **3 × 3** con carátula en la primera columna, rótulos en la segunda y valores en la tercera. Así la columna de rótulos no hereda el ancho del campo Título. Además añade `compact="true"` a la pestaña General para evitar el gran espacio vertical vacío de la ficha.

**No se mueve la carátula a la derecha**. No se modifican código Perl, ejecutables, biblioteca, Bridge, WebView2, ícono ni rutas de usuario.

Los scripts comprueban el hash original y la ruta exacta `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Fuentes-Prueba\lib\gcstar\GCModels\GCfilms.gcm`, guardan respaldo y permiten restaurar. **La distribución final debe esperar confirmación visual del usuario en Windows**, pues el render GTK3 no se ejecutó en el entorno de compilación.

## Windows SmartScreen

El aviso «Windows protegió su PC» corresponde a la falta de firma/reputación del **EXE experimental**. El parche visual no cambia ese EXE. Para la RC1 pública se debe evaluar firma de código y reputación, además de comprobar integridad y publicar hash SHA-256; una firma no elimina de inmediato todos los avisos SmartScreen.
