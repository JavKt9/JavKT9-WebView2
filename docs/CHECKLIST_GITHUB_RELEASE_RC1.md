# GitHub Releases — lista de salida para JAVkt9 0.8.1 RC1

**Estado:** instalador Windows probado por el usuario; publicación pública pendiente de revisión de fuentes/licencias.

## Archivo candidato

- `JAVkt9_0.8.1_RC1_Setup_Candidata_Windows_x64.exe`
- 168.277.681 bytes
- SHA-256 `927dccc7df6b39c08a423edcf22071254e53a2c7a49fa2c32b799d2763dc4f23`

## Hecho

- [x] Instalador compilado y empaquetado.
- [x] Hash del instalador registrado.
- [x] Instalación por usuario confirmada por el usuario.
- [x] Programa abre en la instalación nueva.
- [x] Búsqueda con WebView2 integrada funciona.
- [x] Instrucciones de instalación/desinstalación redactadas.
- [x] Notas de versión redactadas.
- [x] Fuentes Perl y licencia GPL incorporadas en la rama de auditoría.
- [x] Trabajo de reemplazo de lanzadores iniciado en rama separada.

## Pendiente antes de declarar distribución pública lista

- [ ] Retirar o revocar, según corresponda, las cuatro claves antiguas aún presentes **dentro del Setup.exe**.
- [ ] Determinar y cumplir las obligaciones de fuentes correspondientes de los binarios RC1, incluido PAR.
- [ ] Completar avisos y derechos de redistribución de dependencias y recursos incluidos.
- [x] Incorporar el código fuente exacto del instalador en `src/instalador-rc1/main.go` y verificar su reconstrucción byte por byte.
- [ ] Garantizar acceso público a esas fuentes cuando se publique la release.
- [ ] Subir **el instalador EXE**, no solo el ZIP antiguo, como asset de GitHub Release.
- [ ] Verificar desde sesión sin acceso al repositorio que el enlace de descarga es realmente público.
- [ ] Decidir explícitamente si el repositorio se hará público y si la release dejará de ser borrador.
- [ ] Opcional: firma digital Authenticode para reducir avisos de editor desconocido.

## Ruta de publicación

1. Revisar [fuentes y licencias](FUENTES_Y_LICENCIAS_PARA_RC_PUBLICA.md).
2. Crear una release nueva, sin reutilizar `v0.8.1-rc1` hasta que el asset sea el correcto; preferir una etiqueta distinta para no confundir el ZIP anterior con el instalador.
3. Adjuntar el EXE, las notas de release y los archivos fuente/licencias pertinentes.
4. Marcarla **Pre-release** si sigue siendo candidata.
5. Verificar URL de descarga y hash desde una sesión externa.

**Importante:** el repositorio actualmente es privado; una release en un repositorio privado no es una descarga pública. No cambiar visibilidad ni publicar binarios automáticamente antes de resolver la revisión.

No se requiere repetir la prueba del buscador.
