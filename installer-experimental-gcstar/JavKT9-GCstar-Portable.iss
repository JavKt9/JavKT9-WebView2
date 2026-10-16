#define MyAppName "JavKT9 GCstar Experimental"
#define MyAppVersion "0.8.1 GCstar Test"

; Solo pruebas CI. No reemplaza RC1 ni se publica.
[Setup]
AppId={{C4F4A4C1-3D9A-4D52-9D86-86D3A8AC6F21}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=JavKT9 Experimental
DefaultDirName={autopf}\\JavKT9-GCstar-Experimental
DefaultGroupName=JavKT9 GCstar Experimental
OutputDir=..\\output-gcstar-experimental
OutputBaseFilename=JavKT9-GCstar-Experimental-NO-DISTRIBUIR
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
WizardStyle=modern
Uninstallable=yes
DisableProgramGroupPage=yes

[Files]
Source: "Payload\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "JavKT9-Experimental.cmd"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Launcher sets an isolated profile without modifying the stable RC1 environment.
Name: "{autoprograms}\\JavKT9-081-RC1 Experimental"; Filename: "{app}\\JavKT9-Experimental.cmd"; WorkingDir: "{app}\\app"

[Run]
; No iniciar automáticamente durante pruebas silenciosas.

[UninstallDelete]
; No borrar colecciones, perfiles ni datos del usuario.
