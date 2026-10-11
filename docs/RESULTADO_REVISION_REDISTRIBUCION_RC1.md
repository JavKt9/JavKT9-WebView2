# Revisión concreta de redistribución — RC1 instalador

**Revisado el 11 de octubre de 2026 sobre el ZIP RC1 original.** El usuario confirmó instalación, apertura y búsqueda WebView2 funcionales en Windows. Esta revisión no cambia el programa ni pide repetir pruebas.

## Paquete inspeccionado

- Archivo: `JAVkt9_0.8.1_RC1_Beta_Publica_Windows.zip`.
- SHA-256 verificado: `08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4`.
- 6.221 archivos dentro del ZIP; 6.213 corresponden a `payload/` y otros son scripts instaladores externos.
- Comprobación CRC del ZIP: correcta.
- **1.112** archivos de aplicación y Perl en `payload/lib/gcstar/`.
- **4.255** archivos de runtime Perl/GTK en `payload/usr/`.
- **472** archivos de host WebView2/.NET en `payload/bin/WebView2Host/`.
- **348** archivos de recursos en `payload/share/gcstar/`.

## Licencias encontradas dentro del paquete

| Archivo | Hallazgo | Resultado |
| --- | --- | --- |
| `payload/share/gcstar/LICENSE` | Texto GNU GPL versión 2 | **Encontrado**; cubre el programa sujeto a esa licencia, no automáticamente todos los componentes |
| `payload/share/gcstar/fonts/LICENSE` | SIL Open Font License 1.1 | **Encontrado** para Liberation Sans; conservar junto a la tipografía |
| `payload/share/gcstar/fonts/AUTHORS` | Créditos de fuentes | **Encontrado**; conservar |

No se localizaron otros archivos con nombre exacto `LICENSE`, `LICENCE`, `COPYING`, `NOTICE` o `AUTHORS` en el ZIP. **Esto no demuestra ausencia de licencias:** pueden existir encabezados en archivos fuente, documentación con otros nombres o avisos incorporados a bibliotecas. Es una falta de **inventario de avisos reunidos**, no prueba automática de infracción.

## Hallazgo adicional de seguridad

En el **ZIP binario original**, cuatro módulos Perl `GCThemoviedb.pm` / `GCThemoviedbCommon.pm` todavía tienen **un valor literal no vacío asignado a `$apiKey` cada uno**. Los valores **no se muestran ni se suben a la documentación**. Los cuatro valores ya se habían retirado de la copia de fuentes en GitHub, pero el instalador probado **incluye la RC1 original sin modificación**, por lo que aún contiene esos valores.

Esto no prueba que las claves sigan activas ni que pertenezcan a una cuenta actual, pero **se debe verificar su titularidad y rotarlas/revocarlas si corresponde**. Una versión pública saneada necesitaría retirar esos literales del paquete distribuido y comprobar que no afecta las búsquedas. No se cambió la RC1 funcional.

## Código fuente correspondiente

- **Recuperado:** 1.115 fuentes Perl en la rama de auditoría, proyecto C# WebView2, GPL y créditos.
- **Instalador nuevo:** código Go original del instalador candidato disponible en un ZIP de fuentes separado; se está incorporando a esta rama.
- **No recuperado:** fuentes de los dos lanzadores Go originales de la RC1 y receta verificada de compilación del `gcstar.exe` PAR. La existencia de lanzadores nuevos en otra rama no demuestra que correspondan a los binarios ya distribuidos.
- **Terceros:** no está completa la atribución/redistribución del runtime GTK/Perl, librerías .NET/WebView2, imágenes y recursos. No asumir licencias concretas de cada DLL sin inventario por paquete.

## Conclusión de esta revisión

**La instalación y el buscador están probados. El instalador RC1 actual no está listo para una publicación pública con conformidad verificada.** Hay dos tareas de alta prioridad y concretas: **(1)** resolver las cuatro claves antiguas del paquete final y **(2)** asegurar código fuente correspondiente y avisos de redistribución de todos los componentes aplicables. La documentación sola no arregla esos puntos.

No se modifica `main`, la RC1 instalada ni el borrador de release. La auditoría es reproducible con `tools/auditar_paquete_rc1.py` sobre el ZIP original, sin mostrar los valores de las claves.
