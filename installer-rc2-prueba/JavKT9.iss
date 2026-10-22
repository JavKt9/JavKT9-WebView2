#define MyAppName "JAVkt9"
#define MyAppVersion "0.8.1 RC2"
#define MyAppPublisher "JAVkt9 / GCstar GPL"
#define MyAppExeName "JavKT9.exe"

; RC2 DE PRUEBA: instalacion independiente, sin sobrescribir RC1 ni otras versiones.
; IMPORTANTE: Payload debe contener los binarios RC2 actualizados, NO solo el RC1 extraido.
[Setup]
AppId={{C9C8579B-7294-4A93-911B-202610220002}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName=JAVkt9 0.8.1 RC2 Prueba
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\JavKT9-081-RC2-Prueba
DefaultGroupName=JAVkt9 0.8.1 RC2
UninstallDisplayName=JAVkt9 0.8.1 RC2 Prueba
UninstallDisplayIcon={app}\JavKT9.ico
SetupIconFile=..\installer\JavKT9.ico
OutputDir=..\output-rc2-prueba
OutputBaseFilename=JAVkt9-0.8.1-RC2-Prueba-Setup-Windows-x64
Compression=lzma2/max
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
WizardStyle=modern
WizardImageFile=WizardImage.bmp
WizardSmallImageFile=WizardSmallImage.bmp
CloseApplications=no
RestartApplications=no
DisableProgramGroupPage=yes
VersionInfoVersion=0.8.1.2
VersionInfoCompany=JAVkt9
VersionInfoDescription=JAVkt9 0.8.1 RC2 - Windows Setup
VersionInfoProductName=JAVkt9
VersionInfoProductVersion=0.8.1.2
LicenseFile=..\installer\LICENSE.txt
DisableWelcomePage=no
DisableDirPage=no
Uninstallable=yes

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
Source: "Payload\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\installer\JavKT9.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\JAVkt9 0.8.1 RC2"; Filename: "{app}\JavKT9.exe"; WorkingDir: "{app}"; IconFilename: "{app}\JavKT9.ico"
Name: "{autodesktop}\JAVkt9 0.8.1 RC2"; Filename: "{app}\JavKT9.exe"; WorkingDir: "{app}"; IconFilename: "{app}\JavKT9.ico"

[Run]
Filename: "{app}\JavKT9.exe"; Description: "Abrir JAVkt9 ahora"; Flags: nowait postinstall skipifsilent

; No limpiar ni modificar otras versiones ni datos de colecciones.
[UninstallDelete]
; Las colecciones y los perfiles de usuario quedan intactos.
