#define MyAppName "JavKT9"
#define MyAppVersion "0.7.37"
#define MyAppPublisher "kt9 / GCstar GPL"
#define MyAppExeName "JavKT9.exe"

[Setup]
AppId={{B7F736A8-62E8-4CB5-94B4-7E5D48F53535}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\JavKT9
DefaultGroupName=JavKT9
UninstallDisplayName=JavKT9
UninstallDisplayIcon={app}\JavKT9.ico
SetupIconFile=JavKT9.ico
OutputDir=..\output
OutputBaseFilename=JavKT9-Setup-0.7.38
Compression=lzma2/max
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
WizardStyle=modern
CloseApplications=no
RestartApplications=no
DisableProgramGroupPage=yes
VersionInfoVersion=0.7.37.0
VersionInfoCompany=kt9
VersionInfoDescription=JavKT9 Setup
VersionInfoProductName=JavKT9
VersionInfoProductVersion=0.7.37
LicenseFile=LICENSE.txt

[Files]
Source: "Stop-JavKT9.ps1"; Flags: dontcopy
Source: "Payload\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "JavKT9.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\JavKT9"; Filename: "{app}\JavKT9.exe"; WorkingDir: "{app}"; IconFilename: "{app}\JavKT9.ico"
Name: "{autodesktop}\JavKT9"; Filename: "{app}\JavKT9.exe"; WorkingDir: "{app}"; IconFilename: "{app}\JavKT9.ico"

[Run]
Filename: "{app}\JavKT9.exe"; Description: "Abrir JavKT9"; Flags: nowait postinstall skipifsilent

[InstallDelete]
Type: filesandordirs; Name: "{app}\BrowserExtension"
Type: files; Name: "{app}\INSTALAR_EXTENSION.txt"

[UninstallDelete]
; Intencionalmente NO se elimina %LOCALAPPDATA%\JavKT9 ni colecciones del usuario.

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  ScriptPath: String;
begin
  { Close only processes belonging to the experimental installation. }
  ExtractTemporaryFile('Stop-JavKT9.ps1');
  ScriptPath := ExpandConstant('{tmp}\Stop-JavKT9.ps1');
  if not Exec(ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
    '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + ScriptPath +
    '" -InstallDir "' + ExpandConstant('{app}') + '"',
    '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    Result := 'No se pudo comprobar el cierre de JavKT9. Cierre JavKT9 y vuelva a intentar.';
    Exit;
  end;
  if ResultCode <> 0 then
  begin
    Result := 'Hay procesos de JavKT9 que no pudieron cerrarse. Cierre JavKT9 e inténtelo otra vez. No se modificó GCJav.';
    Exit;
  end;
  Sleep(1500);
  Result := '';
end;
