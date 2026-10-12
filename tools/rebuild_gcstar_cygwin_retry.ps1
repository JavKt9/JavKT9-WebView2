param(
    [string]$CygwinRoot = 'C:\cygwin64',
    [string]$Mirror = 'https://mirrors.kernel.org/sourceware/cygwin/'
)
$ErrorActionPreference = 'Stop'
$setup = Join-Path $env:RUNNER_TEMP 'setup-x86_64.exe'
$cache = Join-Path $env:RUNNER_TEMP 'cygwin-cache'
$bash = Join-Path $CygwinRoot 'bin\bash.exe'
if (!(Test-Path $setup) -or !(Test-Path $bash)) {
    throw 'Faltan Cygwin o su instalador en el runner temporal'
}
$tried = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$command = 'cd "$(cygpath -u "$GITHUB_WORKSPACE")" && sed -i "s/\r$//" tools/build_gcstar_cygwin_experimental.sh && bash tools/build_gcstar_cygwin_experimental.sh'

for ($round = 1; $round -le 15; $round++) {
    Write-Host "Intento experimental de GCstar: $round"
    $output = @(& $bash -lc $command 2>&1)
    $exitCode = $LASTEXITCODE
    $lines = @($output | ForEach-Object { "$_" })
    foreach ($line in $lines) { Write-Host $line }
    if ($exitCode -eq 0) {
        Write-Host 'COMPILACION EXPERIMENTAL COMPLETA; NO PUBLICAR SIN VALIDAR EN WINDOWS'
        exit 0
    }
    $text = [string]::Join([Environment]::NewLine, $lines)
    $match = [regex]::Match($text, "Can't locate ([A-Za-z0-9_/-]+)\.pm")
    if (!$match.Success) {
        throw "No es una dependencia Perl instalable automaticamente (codigo $exitCode); examinar errores."
    }
    $module = $match.Groups[1].Value.Replace('/', '-')
    $package = "perl-$module"
    if ($package -notmatch '^perl-[A-Za-z0-9_-]+$') { throw 'Nombre de paquete invalido' }
    if (!$tried.Add($package)) { throw "La dependencia sigue ausente despues de instalar: $package" }
    Write-Host "Falta $module; se intentara instalar el paquete oficial $package"
    $args = @('-q', '-n', '-N', '-R', $CygwinRoot, '-l', $cache, '-s', $Mirror, '-P', $package)
    $proc = Start-Process -FilePath $setup -ArgumentList $args -NoNewWindow -Wait -PassThru
    if ($proc.ExitCode -ne 0) { throw "No se pudo instalar $package; codigo $($proc.ExitCode)" }
}
throw 'Demasiadas dependencias ausentes; revisar lista exacta y compatibilidad'
