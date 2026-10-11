# Avance concreto: dos lanzadores Go nuevos + Setup Windows experimental

**11 de octubre de 2026 — Compilado y verificado localmente. No publicado.**

En lugar de seguir buscando indefinidamente los archivos Go antiguos, se construyeron **dos ejecutables nuevos a partir de código fuente disponible**, para sustituirlos en una copia aislada de JAVkt9 RC1.

| Ejecutable | Resultado | SHA-256 |
| --- | --- | --- |
| `JavKT9.exe` nuevo | Go 1.23.2, Windows x64; 4 pruebas unitarias superadas | `4f1fe6fa687b8f4f056b66d470495b3c87cca45dca5c947832a9531f86bffe61` |
| `GCJavBridgeLauncher.exe` nuevo | Go 1.23.2, Windows x64; 2 pruebas unitarias superadas | `758816c6208fb45328459389d860aab50540f01cc2bfd283526073b908cf3443` |

**Instalador experimental real:** `JAVkt9_0.8.1_RC1_EXPERIMENTAL_Lanzadores_Con_Fuentes_Windows_x64.exe`

- Tamaño: **168.977.887 bytes**.
- SHA-256: `4e3a6745aef276474408d119681fb2030b5efb3086260ef1ffd56ab1db150d33`.
- **6.218 entradas** ZIP verificadas con CRC.
- Se comparó contra el Setup saneado: **solo cambiaron 3 entradas** (los dos lanzadores Go y el ZIP de fuentes), se agregaron 2 (acceso a modo Perl fuente y LEEME). Los demás archivos permanecen iguales, incluidos los cuatro módulos ya saneados y el host WebView2 original.
- Instalación independiente: `%LOCALAPPDATA%\Programs\JAVkt9-081-RC1-Fuentes-Prueba`.
- El Setup RC1 saneado y la instalación funcional previa **no se modificaron**.
- El ZIP de fuentes dentro del instalador incluye los fuentes Go nuevos. El kit de fuentes independiente `JAVkt9_0.8.1_RC1_Lanzadores_Nuevos_Fuentes_Privadas.zip` contiene además la receta exacta y el código fuente del nuevo Setup.

## La única comprobación funcional necesaria ahora

El usuario puede instalar el **Setup experimental** sin sobrescribir otras versiones y verificar si abre JAVkt9. Después de cerrar el programa, puede abrir `JavKT9-Fuentes.cmd` desde su carpeta de instalación para probar **arranque sin PAR**. La prueba importante es si la búsqueda WebView2 continúa funcionando en el modo de fuentes.

**No afirmar equivalencia funcional todavía:** la RC1 anterior sí se probó, pero los dos nuevos ejecutables no se ejecutaron en Windows en este entorno. El host WebView2 original podría no respetar la carpeta de datos aislada del lanzador nuevo; si falla la captura, no sustituir componentes del usuario a ciegas.

## Qué resuelve y qué no

**Resuelve:** hay implementaciones Go nuevas con fuentes, pruebas y compilación, y un instalador real independiente para validarlas. Ya no dependemos exclusivamente de recuperar el código perdido de esos dos lanzadores para explorar una futura edición pública.

**No resuelve todavía:** la candidata aún conserva el PAR `gcstar.exe` original. El modo `JavKT9-Fuentes.cmd` permitirá decidir si podemos retirarlo sin perder funcionalidad. Faltan también avisos de redistribución de Perl/GTK, .NET/WebView2 y recursos.

El repositorio permanece privado; no tocar `main` ni la release `v0.8.1-rc1` en borrador. **No publicar este instalador experimental como RC pública.**
