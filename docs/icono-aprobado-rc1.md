# Icono aprobado — JavKT9 0.9.9.1 RC1

El usuario proporcionó el archivo binario original **JavKT9-Logo.ico** el 24/11/2026.

- SHA-256 del ICO original: `cbb08accdec03be806cae93316824ddd7fdca23543c65daf78c0cc76dabf7445`
- Resoluciones incluidas: 16×16, 24×24, 32×32, 48×48, 64×64, 128×128, 256×256.
- Arte: círculo con flores de cerezo, monte Fuji y texto «JAVkt9».
- **La compilación GitHub Actions actual incrusta una versión ICO generada desde el PNG de la misma ilustración** `app/share/gcstar/Logo_Circular.png`. Es visualmente equivalente, pero no se ha comprobado identidad binaria frente al ICO recibido.
- El instalador final utiliza el ICO **original** en `InstallerAssets/JavKT9-Logo.ico` (dentro de SourceRoot), tanto para instalador/accesos directos como para `assets/JavKT9-Logo.ico`.
- Antes de publicar, validar que el archivo en `InstallerAssets` tenga exactamente el hash indicado. En PowerShell:
  `(Get-FileHash "C:\JavKT9-ObsidianWine-Prueba\InstallerAssets\JavKT9-Logo.ico" -Algorithm SHA256).Hash`

**No subir paquetes de datos del usuario ni claves/credenciales con el instalador.**

**Importante:** ícono y firma de código son cosas diferentes. El ícono no modifica reputación de SmartScreen ni soluciona una detección de Defender. `0.9.9.1 RC1` sigue sin publicar.
