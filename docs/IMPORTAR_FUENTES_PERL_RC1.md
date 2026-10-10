# Incorporación de las fuentes Perl RC1

Esta rama contiene un importador comprobado con la distribución RC1 aportada. El importador no ejecuta el programa ni modifica instalaciones de Windows.

## Procedimiento para la copia local

1. Descargar el repositorio de la rama `fuentes-rc1-auditoria` y descomprimirlo.
2. Conservar el archivo original `JAVkt9_0.8.1_RC1_Beta_Publica_Windows.zip` sin modificar.
3. Desde la carpeta raíz del repositorio, ejecutar en Windows (con Python instalado):

```powershell
python tools/importar_fuentes_rc1.py "RUTA_AL_ZIP_RC1" .
```

El script verifica el SHA-256 exacto `08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4`, comprueba la integridad del ZIP y copia únicamente los 1115 archivos fuente/configuración previstos. No sobrescribe contenido diferente. Conserva tanto `src/perl/bin/gcstar` como `src/perl/par_embebido/script/gcstar.pl`.

**Estado actual de GitHub:** el script y los documentos ya están en la rama privada. Los 1115 archivos fuente todavía no se han incorporado al repositorio remoto; el script permite hacerlo en una copia local y revisar los cambios antes de subirlos. No ejecutar workflows antiguos de instalador.

**Importante:** falta la revisión de derechos de terceros, las fuentes de dos ejecutables y la compilación completa. No publicar el repositorio todavía.
