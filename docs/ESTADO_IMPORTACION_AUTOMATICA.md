# Importacion de fuentes Perl RC1

El workflow `importar-fuentes-rc1.yml` importo los archivos Perl y configuraciones de la RC1 tras verificar su SHA-256 y pasar un escaneo automatizado de secretos. Cuatro claves heredadas fueron retiradas de los archivos destinados a GitHub.

El codigo fue importado a la rama privada `fuentes-rc1-auditoria`, sin modificar `main`, ejecutables ni instalaciones de Windows.

**No publicar aun:** siguen pendientes licencias, datos privados y fuentes originales de los ejecutables `JavKT9.exe` y `GCJavBridgeLauncher.exe`. El escaneo automatizado no garantiza seguridad ni legalidad.
