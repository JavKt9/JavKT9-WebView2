#define MyAppName "JavKT9-081-RC1"
#define MyAppVersion "0.8.1 RC1 (prueba aislada)"

; Solo pruebas CI. No reemplaza RC1 ni se publica.
[Setup]
AppId={{C4F4A4C1-3D9A-4D52-9D86-86D3A8AC6F21}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=JavKT9 Experimental
DefaultDirName={autopf}\\JavKT9-081-RC1
DefaultGroupName=JavKT9-081-RC1
OutputDir=..\\output-gcstar-experimental
OutputBaseFilename=JavKT9-081-RC1-NO-DISTRIBUIR
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
WizardStyle=modern
SetupIconFile=..\\installer\\JavKT9.ico
UninstallDisplayIcon={app}\\JavKT9.ico
Uninstallable=yes
DisableProgramGroupPage=yes

[Files]
Source: "Payload\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "JavKT9-Experimental.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\\installer\\JavKT9.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Launcher sets an isolated profile without modifying the stable RC1 environment.
Name: "{autoprograms}\\JavKT9-081-RC1"; Filename: "{sys}\\wscript.exe"; Parameters: """{app}\\JavKT9-Experimental.vbs"""; WorkingDir: "{app}\\app"; IconFilename: "{app}\\JavKT9.ico"
Name: "{autodesktop}\\JavKT9-081-RC1"; Filename: "{sys}\\wscript.exe"; Parameters: """{app}\\JavKT9-Experimental.vbs"""; WorkingDir: "{app}\\app"; IconFilename: "{app}\\JavKT9.ico"

[Run]
; No iniciar automáticamente durante pruebas silenciosas.

[UninstallDelete]
; No borrar colecciones, perfiles ni datos del usuario.
