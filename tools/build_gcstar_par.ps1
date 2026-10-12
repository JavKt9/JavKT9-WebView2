param(
  [string]$OutputDir = "build-gcstar-experimental"
)
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$source = Join-Path $root "src/perl/par_embebido/script/gcstar.pl"
$lib = Join-Path $root "src/perl/lib/gcstar"
if (!(Test-Path $source) -or !(Test-Path $lib)) { throw "Faltan fuentes GCstar: no generar ejecutable" }
$perl = Get-Command perl -ErrorAction SilentlyContinue
$pp = Get-Command pp -ErrorAction SilentlyContinue
if (!$perl -or !$pp) { throw "Se requieren perl y pp (PAR::Packer) para compilar; no sustituyas ejecutables existentes" }
& perl -MPAR::Packer -e "print qq(PAR::Packer disponible\\n)"
if ($LASTEXITCODE -ne 0) { throw "PAR::Packer no funciona en este entorno" }
& perl -I $lib -c $source
if ($LASTEXITCODE -ne 0) { throw "No se pudo compilar el script: revisar módulos Perl faltantes en el log" }
New-Item -ItemType Directory -Force $OutputDir | Out-Null
$out = (Resolve-Path $OutputDir).Path
$target = Join-Path $out "gcstar-experimental.exe"
if (Test-Path $target) { throw "El archivo experimental ya existe: usar una carpeta vacia" }
& pp -o $target -I $lib $source
if ($LASTEXITCODE -ne 0 -or !(Test-Path $target)) { throw "Falló PAR::Packer, falta completar las dependencias GTK/Perl" }
Get-FileHash $target -Algorithm SHA256 | Format-List
Write-Host "EXPERIMENTAL: no distribuir ni copiar a Program Files sin validar runtime, fuentes y licencias"
