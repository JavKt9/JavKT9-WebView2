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

## Resultado real de GitHub Actions — 12-10-2026

- Rama experimental independiente: `experimento-gcstar-par-rc1`.
- Primera ejecución `38193584942`: Strawberry Perl 5.32.1 presente, módulos Gtk3/Glib/Glib::Object::Introspection/Cairo/Pango ausentes. El diagnóstico debió corregirse para que un fallo esperado de carga no interrumpiera la secuencia.
- Segunda ejecución `38193688506`: PAR::Packer se instaló correctamente; la compilación paró porque no encontraba `GCOptions.pm`, pese a estar en `src/perl/lib/gcstar`. Se añadió esta ruta a la verificación Perl.
- Tercera ejecución `38193771782`: PAR::Packer se instaló; el script Perl cargó `GCOptions.pm` pero falló exactamente por `Can't locate Gtk3.pm`, importado desde `GCOptions.pm`. **No se generó gcstar-experimental.exe**.

### Siguiente bloqueo

Conseguir una **cadena de dependencias Perl/GTK3/GObject Introspection y librerías nativas compatible en Windows**, con versiones, procedencia y licencias verificables. No mezclar arbitrariamente los binarios del runtime aprobado con Strawberry Perl: podrían ser ABI incompatibles. Se pueden evaluar distribuciones de desarrollo como MSYS2 o Cygwin, pero un `gcstar.exe` construido allí será otra variante que requerirá pruebas funcionales y revisión de licencias.

Estas ejecuciones no modificaron el instalador RC1 ni reemplazaron el ejecutable aprobado. **No declarar éxito de compilación ni autorizar publicación.**
