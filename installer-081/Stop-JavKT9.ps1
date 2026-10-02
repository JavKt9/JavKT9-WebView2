param([Parameter(Mandatory=$true)][string]$InstallDir)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($InstallDir).TrimEnd('\') + '\'
$names = @('JavKT9.exe','gcstar.exe','JavKT9WebView2.exe','perl.exe','wperl.exe','GCJavBridgeLauncher.exe')
function Get-TargetProcesses {
  @(Get-CimInstance Win32_Process | Where-Object {
    if ($names -notcontains $_.Name) { return $false }
    $exe = [string]$_.ExecutablePath
    $cmd = [string]$_.CommandLine
    ($exe.StartsWith($root,[StringComparison]::OrdinalIgnoreCase)) -or
    ($cmd.IndexOf($root,[StringComparison]::OrdinalIgnoreCase) -ge 0)
  })
}
try {
  $targets = @(Get-TargetProcesses)
  foreach ($p in $targets) {
    try { Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop }
    catch { Write-Output "Could not close JavKT9 PID $($p.ProcessId): $_" }
  }
  Start-Sleep -Milliseconds 1200
  $remaining = @(Get-TargetProcesses)
  if ($remaining.Count -gt 0) { exit 2 }
  exit 0
} catch { Write-Output $_; exit 3 }
