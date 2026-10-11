param([Parameter(Mandatory=$true)][string]$Root)
$ErrorActionPreference = 'Stop'
$bin = [IO.Path]::GetFullPath((Join-Path $Root 'bin\wperl.exe'))
$script = [IO.Path]::GetFullPath((Join-Path $Root 'lib\gcstar\GCPlugins\GCfilms\GCJavLibraryBridge.pl'))
$listener = @(Get-NetTCPConnection -LocalAddress '127.0.0.1' -LocalPort 53118 -State Listen -ErrorAction SilentlyContinue)
if ($listener.Count -eq 0) { exit 0 }
if ($listener.Count -ne 1) { Write-Error 'Multiples listeners; no se cierra nada.'; exit 2 }
$ownerPid = [int]$listener[0].OwningProcess
$process = Get-CimInstance Win32_Process -Filter "ProcessId=$ownerPid" -ErrorAction Stop
if ($null -eq $process) { Write-Error 'No se puede identificar al dueño del puerto.'; exit 3 }
$exe = [string]$process.ExecutablePath
$cmd = [string]$process.CommandLine
if (-not $exe.Equals($bin, [StringComparison]::OrdinalIgnoreCase) -or
    $cmd.IndexOf($script, [StringComparison]::OrdinalIgnoreCase) -lt 0) {
    Write-Error 'El puerto pertenece a otro proceso; no se cierra nada.'
    exit 4
}
# Do not interrupt the bridge of a still-running GUI in the same installation.
$gcstar = [IO.Path]::GetFullPath((Join-Path $Root 'bin\gcstar.exe'))
$running = @(Get-CimInstance Win32_Process -Filter "Name='gcstar.exe'" -ErrorAction SilentlyContinue | Where-Object {
    ([string]$_.ExecutablePath).Equals($gcstar,[StringComparison]::OrdinalIgnoreCase)
})
if ($running.Count -gt 0) { Write-Error 'Hay una edicion de JAVkt9 activa; no se cierra el Bridge.'; exit 5 }
Stop-Process -Id $ownerPid -Force -ErrorAction Stop
Write-Output "Bridge huerfano propio cerrado: PID $ownerPid"
exit 0
