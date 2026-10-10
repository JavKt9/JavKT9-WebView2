# Verificacion automatica de fuentes Perl RC1

**RESULTADO: CORRECTO** (GitHub Actions).

- Archivos verificados: **1115**, contra `manifiestos/fuentes-perl-rc1-git.tsv`.
- Los hashes Git de los archivos coinciden con el manifiesto.
- Cuatro claves API heredadas permanecen vacias.
- Commit fuente verificado: consultar el historial del workflow (SHA del evento que inició la verificación).
- Proceso: `.github/workflows/verificar-integridad-fuentes-rc1.yml`.

Esto **no** valida la compilacion de los ejecutables, las licencias, el historial completo ni la seguridad general. El repositorio debe permanecer privado.
