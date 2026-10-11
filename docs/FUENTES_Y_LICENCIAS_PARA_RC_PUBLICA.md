# Fuentes y licencias — decisión de publicación de la RC

**Propósito:** identificar lo que está comprobado y lo que falta para distribuir públicamente la RC; evitar auditorías repetidas y modificaciones del programa que funciona.

## Fuentes ya disponibles

| Elemento | Situación | Ubicación |
| --- | --- | --- |
| Código Perl GCstar/JAVkt9 | 1.115 archivos recuperados, manifiesto de integridad verificado; cuatro claves heredadas retiradas en la copia del repositorio | `src/perl/`, `manifiestos/fuentes-perl-rc1-git.tsv` |
| Licencia y créditos GCstar | GNU GPL v2 completa y avisos del proyecto | `LICENSE`, `NOTICE.md` |
| Proyecto C# WebView2 | Código disponible y compilación en Windows validada; no acreditada identidad binaria con RC1 | `src/JavKT9WebView2/` |
| Lanzadores Go **nuevos** | Dos proyectos fuente creados, sin equivalencia funcional certificada con los binarios RC1 | Rama `edicion-publica-desarrollo`: `src/public-launcher/`, `src/public-bridge-launcher/` |
| Instalador Go **nuevo** | Fuente entregada como archivo separado de la candidata, aún no incorporada a este repositorio | `JAVkt9_0.8.1_RC1_Setup_Codigo_Fuente.zip` |

## Pendientes concretos (sin repetir pruebas funcionales)

**A. Lanzadores originales:** `JavKT9.exe` y `GCJavBridgeLauncher.exe` de RC1 fueron compilados con Go 1.23.2, pero no se encontraron sus proyectos fuente originales. No es correcto declarar que las fuentes de esos ejecutables están completas. Debe establecerse si son programas independientes o derivados bajo GPL, y la obligación correspondiente. Alternativa técnica: edición futura con lanzadores nuevos, **sin sustituirlos en la RC1 que el usuario probó**.

**B. PAR `gcstar.exe`:** se recuperaron el script Perl normal y el script extraído del PAR, que declaran versiones diferentes. Falta verificar receta de empaquetado, fuentes correspondientes y dependencias incluidas. No declarar que la reconstrucción es reproducible.

**C. Terceros:** identificar licencia, autoría, versión, avisos y redistribución de los módulos Perl/GTK, archivos de `payload/usr/`, host .NET/WebView2 y recursos `payload/share/gcstar/`. La fuente Liberation Sans declara SIL OFL 1.1 en el paquete original; conservar ese aviso y revisar los demás recursos. Una licencia libre del programa principal no concede automáticamente permisos sobre todos los componentes empaquetados.

**D. Revisión de secretos y datos:** los escaneos Gitleaks sin hallazgos y las cuatro claves retiradas no sustituyen la inspección del ZIP original ni de los archivos que efectivamente se distribuyen.

## Qué NO falta

- No falta comprobar que el instalador **se abre e instala** en el equipo del usuario: confirmado.
- No falta comprobar que el programa **abre**: confirmado.
- No falta comprobar la **búsqueda WebView2**: confirmado.
- No hace falta modificar la RC1 instalada ni cambiar el Bridge funcional.

## Decisión de publicación

**La RC1 candidata funciona en el equipo probado, pero no se ha acreditado aún el cumplimiento de redistribución pública de todos los binarios y dependencias.** No declarar «cumplimiento GPL completo» ni «apta para publicación sin reservas» hasta resolver A–D. Mantener separadas la candidata funcional y la edición nueva con fuentes disponibles.

La publicación en GitHub no corrige ni suple derechos de redistribución. El repositorio privado puede almacenar esta documentación y el trabajo de preparación.
