# Auditoría de limpieza — JavKT9 0.8.1 RC2

**Estado:** inventario inicial; no se han eliminado módulos en esta fase.
**Rama:** desarrollo-0.8.1-rc2. No modificar RC1.

## Inventario (árbol de GitHub)
- 1.212 archivos en el repositorio.
- `src/perl/lib/gcstar/GCLang/`: 842 archivos (~2,7 MiB de código fuente).
- `src/perl/lib/gcstar/GCPlugins/`: 189 archivos (~1,4 MiB de código fuente).
- 49 archivos cuyo nombre contiene Amazon, distribuidos entre libros, cómics, películas, juegos, gadgets y componentes comunes.
- El instalador `installer-rc1-github/JavKT9.iss` empaqueta recursivamente `Payload/*`. Por tanto, retirar fuentes sin revisar cómo se construye Payload **no garantiza** reducción del instalador.

## Candidatos de limpieza
1. **Proveedores Amazon ajenos a películas**: evaluar exclusión de Payload antes de borrar fuentes. Verificar que los plugins se descubran dinámicamente y que la aplicación siga iniciando.
2. **Proveedores de películas distintos de JavLibrary**: primero ocultar/deshabilitar en la interfaz; eliminar solo después de comprobar referencias, dependencias y búsquedas.
3. **Modelos de colecciones ajenos a películas**: comprobar si el arranque, menús o preferencias requieren módulos base antes de excluirlos.
4. **Traducciones**: mantener español y dependencias de idioma de respaldo; medir ahorro en Payload antes de excluir otras traducciones.
5. **Workflows históricos**: conservar por ahora; no afectan el tamaño del instalador y eliminarlos puede perder información útil.

## Componentes protegidos
- Motor GTK3/Perl y dependencias de GCstar.
- Modelo y lectura/escritura de colecciones .gcs.
- JavLibrary y WebView2.
- Carátulas, favoritos y sistema de backup/restauración.
- Instalador Inno Setup, accesos directos y datos de usuario.

## Criterios antes de cada eliminación
- Localizar referencias y carga dinámica.
- Verificar el contenido real de Payload y medir el tamaño previo.
- Aplicar cambios solo en RC2.
- Ejecutar pruebas de arranque, búsqueda, guardado, restauración y favoritos en Windows.
- Comparar tamaño y funcionamiento antes/después.
- No lanzar GitHub Actions sin autorización explícita.
