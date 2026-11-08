# JavKT9 0.9.9 — desarrollo de interfaces

> **Estado:** en desarrollo, no publicar como versión estable ni como instalador listo para usuarios.
> **Repositorio principal:** JavKt9/JavKT9-WebView2.
> **Rama de trabajo:** `desarrollo-0.9.9-interfaces`.

## Objetivo

Una única aplicación y una única instalación actualizable con tres modos de interfaz:

- **Clásica:** vistas tradicionales de GCstar, 10 temas previstos/implementados en la rama local.
- **Moderna V1:** presentación derivada de Biblioteca RC3, 7 temas.
- **Moderna V2:** presentación KT9V1, 6 temas, incluido Original.

Las preferencias de color deben ser independientes por modo. El usuario debe poder cambiar el modo desde Apariencia, con aplicación al reiniciar el programa durante esta fase.

## Estado de las pruebas locales

- La rama local 0.9.9 tiene modificaciones en `GCJavSkins.pm`, `GCMainWindow.pm` y documentación.
- La sintaxis Perl de los dos primeros módulos fue comprobada localmente.
- El acceso duplicado a Apariencia en el menú Clásico se retiró en el desarrollo local.
- **Aún deben sincronizarse los archivos locales más recientes a esta rama de GitHub**, revisar los cambios y validar los tres modos después de reiniciar.
- No existe todavía un instalador 0.9.9 público validado.

## Criterios de distribución

- La familia de instaladores de JavKT9 debe mantener el mismo `AppId` ya usado por 0.9.7.
- La instalación pública predeterminada es `C:\Program Files\JavKT9`.
- Las colecciones, favoritos y preferencias de cada usuario deben permanecer fuera de la carpeta del programa.
- No subir al repositorio colecciones `.gcs`, perfiles WebView2, archivos de usuario, respaldos ni credenciales.
- Mantener el aviso de versión experimental y los créditos/licencias de GCstar.

## Próximas tareas

1. Sincronizar y revisar los módulos y manual actuales.
2. Probar el recorrido Clásica → Moderna V1 → Moderna V2 y la persistencia de los temas.
3. Incorporar la elección inicial de interfaz a Inno Setup sin preguntar otra vez en las actualizaciones.
4. Probar instalación, actualización y desinstalación preservando datos.
5. Crear una *pre-release* cuando el candidato esté aprobado.
