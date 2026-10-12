# Reconstrucción experimental de GCstar (NO apta para release)

Este proceso prepara un intento de recompilar el ejecutable PAR a partir de `src/perl/par_embebido/script/gcstar.pl` (versión 1.7.3). La variante `src/perl/bin/gcstar` (1.8.1.RC) no es intercambiable.

**Limitación importante:** `pp` de PAR::Packer necesita el mismo entorno de Perl, módulos GTK3 y bibliotecas nativas utilizados por el paquete original. Ni el árbol Git ni los scripts recuperados documentan completamente ese entorno. Una compilación exitosa NO garantiza equivalencia funcional o licencias completas.

El script `tools/build_gcstar_par.ps1` genera únicamente un artefacto experimental; **no modifica el instalador RC1** ni sus colecciones. Requiere Windows, `perl`, `pp` y módulos previamente instalados. Antes de distribuir el resultado son obligatorios: pruebas GUI/WebView2/favoritos, listado exacto de dependencias, avisos de terceros y el código correspondiente.

Uso en un entorno Windows de construcción preparado:

```powershell
pwsh -File tools/build_gcstar_par.ps1 -OutputDir "$PWD\\build-gcstar-experimental"
```

Este comando falla explícitamente si falta Perl, PAR::Packer o alguno de los scripts; no toma un binario viejo ni publica una release.

La RC1 aprobada se mantiene sin cambios hasta que la candidata experimental supere sus pruebas.
