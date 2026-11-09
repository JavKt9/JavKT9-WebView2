# JavKT9 0.9.9 — preparación de la versión pública

> **Versión objetivo:** JavKT9 0.9.9.
> **Estado técnico actual:** candidata en preparación, no etiquetar todavía como final.
> **Rama:** `desarrollo-0.9.9-interfaces`.

## Presentación pública

La próxima versión pública del programa se identificará como **JavKT9 0.9.9**. No se publicarán instaladores intermedios ni se solicitará al usuario realizar pasos por versiones de desarrollo.

## Funciones de interfaz de 0.9.9

Una única aplicación con tres modos seleccionables y una sola biblioteca:

- **Clásica:** distribución tradicional, 10 paletas.
- **Moderna V1:** diseño de biblioteca moderna de primera generación, 7 paletas.
- **Moderna V2:** diseño de biblioteca moderna de segunda generación, 6 paletas incluyendo Original.

Cada interfaz conserva su paleta. En la fase actual, el cambio de modo se aplica después de reiniciar la aplicación.

## Reglas de instalación y actualización

- Nombre y versión mostrados: **JavKT9 0.9.9**.
- Ejecutable: `JavKT9.exe`, con metadatos e ícono oficial correctos.
- Carpeta predeterminada: `C:\Program Files\JavKT9`.
- Mantener de forma permanente el `AppId` ya establecido para la familia JavKT9. No generar uno nuevo por versión.
- Las actualizaciones se instalan sobre la misma ubicación sin eliminar bibliotecas `.gcs`, portadas, favoritos o preferencias.
- La elección inicial entre Clásica, Moderna V1 y Moderna V2 debe ofrecerse solo en instalaciones iniciales. Una actualización debe conservar la preferencia existente.
- La desinstalación no debe borrar datos personales automáticamente.

## Control previo a declarar la versión final

1. Sincronizar los fuentes actuales y los manuales con esta rama.
2. Probar el recorrido Clásica → Moderna V1 → Moderna V2, navegación, temas y persistencia al reiniciar.
3. Incorporar y comprobar la pantalla de selección inicial en Inno Setup.
4. Actualizar los metadatos del ejecutable y todos los identificadores visibles a 0.9.9.
5. Probar instalación limpia, actualización sobre la misma carpeta y desinstalación sin pérdida de datos.
6. Auditar que ni repositorio ni instalador incluyan colecciones personales, cookies, credenciales, respaldos o registros privados.
7. Verificar licencias y atribuciones de GCstar y componentes distribuidos.

## Estrategia GitHub

- Mantener `main` sin cambios hasta la aprobación.
- Subir fuentes revisados, manual y proyecto Inno a esta rama.
- Crear una release de JavKT9 0.9.9 con instalador y notas claras **solo después** de superar los controles.
