$ErrorActionPreference = 'Stop'
$parts = @(Get-ChildItem -File 'JavKT9-Experimental.exe.part*' | Sort-Object Name)
if ($parts.Count -eq 0) { throw 'No se encontraron las partes descargadas' }
$dest = Join-Path (Get-Location) 'JavKT9-081-RC1-NO-DISTRIBUIR.exe'
$out = [IO.File]::Create($dest)
try {
  foreach ($part in $parts) {
    $src = [IO.File]::OpenRead($part.FullName)
    try { $src.CopyTo($out) } finally { $src.Dispose() }
  }
} finally { $out.Dispose() }
$expected = (Get-Content -Raw 'SHA256.txt').Trim()
$actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $dest).Hash.ToLowerInvariant()
if ($actual -ne $expected) { throw 'ERROR: la descarga no coincide con el instalador original' }
Write-Host 'Instalador reconstruido y verificado:' $dest
