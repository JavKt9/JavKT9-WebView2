# Microsoft Store: JavKT9 0.9.9.1 RC1 (sin publicar)

Se reservó correctamente JavKT9 en Microsoft Partner Center.

| Dato | Valor |
|---|---|
| Nombre de paquete | `kt9JavKT9` |
| Editor | `CN=71C19D36-B618-411F-A36C-B0450B18E70F` |
| Publisher display | `kt9` |
| Store ID | `9PBW4G8PF37W` |
| Estado | Borrador |

El archivo `Package.appxmanifest` es un **borrador** para empaquetar el EXE de JavKT9 y todas sus dependencias de Perl/GTK como aplicación Windows Full Trust. **No hay MSIX listo para subir.**

## Dependencias necesarias antes de generar MSIX

1. Obtener una **copia completa del payload de distribución**, no solo el lanzador: `JavKT9.exe`, `app/bin`, `app/lib`, `app/share`, dependencias WebView2, configuración, iconos e imágenes. La mayoría de esos archivos binarios no están en GitHub; NO recuperar el `JavKT9.exe` original que Defender puso en cuarentena.
2. Incorporar los archivos de los parches **V2–V10**, más Manual y Acerca de, desde la rama RC1. **Excluir V11/V12**.
3. Generar los recursos MSIX `Assets/StoreLogo.png`, `Assets/Square150x150Logo.png`, `Assets/Square44x44Logo.png` usando el logo original aprobado.
4. Hacer las pruebas de empaquetado MSIX en Windows 11 con SDK/MakeAppx y el Windows App Certification Kit, en equipo de pruebas o VM, **sin reemplazar la instalación 0.9.9+V10 funcional**.
5. Verificar compatibilidad con `C:\Program Files\WindowsApps` **solo lectura**. Datos de bibliotecas, carátulas, favoritos y preferencias deberán persistir fuera del directorio de la instalación (AppData o rutas seleccionadas por el usuario); probar que el runtime Perl y los subprocesos arranquen desde esa ubicación.
6. Seguridad: confirmar ausencia de malware, resultados de Defender y cierre de Bridge. La revisión original de Bearfoos se mantiene separada. No cambiar opciones globales de Defender/SmartScreen.
7. Publicar a Store únicamente tras aprobar pruebas, completar metadatos, política de privacidad/requisitos de contenido y certificación. **La firma de Store aplica al MSIX** aprobado, no al instalador EXE/MSI externo descargado de GitHub.

No guardar colecciones personales `.gcs`, cookies, perfiles ni claves de usuarios en el paquete.

Referencias:
- https://learn.microsoft.com/en-us/windows/apps/publish/get-started
- https://learn.microsoft.com/en-us/windows/msix/desktop/desktop-to-uwp-manual-conversion
- https://learn.microsoft.com/en-us/windows/msix/msix-containerization-overview
