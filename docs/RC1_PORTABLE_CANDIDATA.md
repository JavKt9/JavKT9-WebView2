# JAVkt9 0.8.1 RC1 — candidata portátil de referencia

**Estado:** candidata privada para Windows. La RC1 funcional de referencia se conservó byte por byte en su directorio `payload/`. **No es la edición pública recompilada**.

## Artefacto preparado el 10 de octubre de 2026

- Nombre: `JAVkt9_0.8.1_RC1_PORTABLE_CON_FUENTES_CANDIDATA.zip`
- Tamaño: **165.179.057 bytes**
- SHA-256 del ZIP nuevo: `450ac674047e8df400fcfb242d25a0e4f5253f4cf664692b0ba0471028eb8e46`
- SHA-256 del ZIP original: `08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4`
- Fuente original: borrador de release `v0.8.1-rc1` del repositorio privado, asset `JAVkt9_0.8.1_RC1_Beta_Publica_Windows.zip`
- Fuentes recuperadas incluidas como `FUENTES_RECUPERADAS_RC1.zip` (SHA-256 `5a18d23c227c22cffab6390855bf8e348aa6b76f3578b3dfc50604f3c769f8dd`).
- **6.213 archivos** de `payload/` copiados sin modificar sus contenidos. Se excluyeron los scripts instaladores y desinstaladores originales. Se añadieron instrucciones y un manifiesto.

## Uso seguro

Extraer en una carpeta nueva fuera de `C:\\Program Files` y ejecutar `payload\\JavKT9.exe`. No instalar sobre Beta 1, RC1 existente ni GCJav; no ejecutar simultáneamente otra instancia que use el puerto 53118. La primera búsqueda puede mostrar el navegador interno WebView2 para la verificación; la funcionalidad corresponde a la RC1 ya confirmada por el usuario.

## Verificaciones realizadas

- SHA-256 del ZIP RC1 original coincide con el digest de la release.
- Archivo ZIP de salida supera prueba completa de integridad CRC.
- Contenido del `payload/` original se reempaquetó sin modificar bytes de los archivos.
- No se modificaron los binarios, el plugin Perl ni el host WebView2 de la RC1.
- Prueba de ejecución en Windows **no realizada en este entorno**. No afirmar que el ZIP nuevo haya sido instalado o ejecutado.

## Límites de publicación

Los fuentes originales de los dos ejecutables Go de la RC1 no están disponibles. Los sustitutos nuevos con fuentes están en `edicion-publica-desarrollo` y requieren integración Windows. La receta de reconstrucción del PAR `gcstar.exe` y el inventario de licencias de dependencias también están pendientes. Por eso esta candidata se entrega para **evaluación privada**, no como distribución pública completamente verificable.

No cambiar `main`, no publicar la release draft `v0.8.1-rc1` y no hacer público el repositorio hasta resolver los pendientes. La siguiente RC pública debería incorporar los nuevos lanzadores, fuentes y dependencias auditadas.
