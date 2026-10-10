# Incorporación de las fuentes Perl RC1

**Estado: incorporadas y verificadas en la rama privada `fuentes-rc1-auditoria`.**

El workflow `.github/workflows/importar-fuentes-rc1.yml` completó la importación automática desde el asset privado de la RC1 el 10 de octubre de 2026, después de:

- Verificar el SHA-256 del ZIP: `08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4`.
- Extraer 1115 archivos de fuentes y configuración (1114 archivos nuevos; `GCJavLibrary.conf` ya existía con el mismo contenido).
- Retirar las cuatro claves API heredadas de módulos de TheMovieDB.
- Ejecutar Gitleaks sobre `src/perl` sin coincidencias detectadas.
- Confirmar los archivos en un commit automático exclusivo de la rama de auditoría.

La versión estable, la RC1 instalada, `main` y las releases **no fueron modificadas**.

## Reproducir en una copia local

Con Python 3 y el ZIP original de la RC1:

```powershell
python tools/importar_fuentes_rc1.py "RUTA_AL_ZIP_RC1" .
```

El importador rechaza un ZIP con SHA distinto y evita sobrescribir archivos diferentes. Conserva las dos variantes del script `gcstar`.

## Límites

No se han importado recursos multimedia de `share/gcstar`, ejecutables ni perfiles de navegador. La ausencia de hallazgos de Gitleaks no garantiza que no haya datos privados. La revisión de licencias, la cadena de compilación y los fuentes originales de dos ejecutables siguen pendientes.

**No fusionar con `main` ni hacer público el repositorio todavía.**
