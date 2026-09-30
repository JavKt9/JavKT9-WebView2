#define MyAppName "JavKT9"
#define MyAppVersion "0.7.36"
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
OutputBaseFilename=JavKT9-Setup-0.7.36
Compression=lzma2/max
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
WizardStyle=modern
CloseApplications=yes
RestartApplications=no
DisableProgramGroupPage=yes
VersionInfoVersion=0.7.36.0
VersionInfoCompany=kt9
VersionInfoDescription=JavKT9 Setup
VersionInfoProductName=JavKT9
VersionInfoProductVersion=0.7.36
LicenseFile=LICENSE.txt

[Files]
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
procedure KillImage(ImageName: String);
var ResultCode: Integer;
begin
  Exec(ExpandConstant('{cmd}'),
    '/D /C taskkill /F /T /IM "' + ImageName + '" >nul 2>&1 & exit /b 0',
    '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  KillImage('JavKT9.exe');
  KillImage('gcstar.exe');
  KillImage('JavKT9WebView2.exe');
  KillImage('perl.exe');
  KillImage('wperl.exe');
  Sleep(2500);
  Result := '';
end;
