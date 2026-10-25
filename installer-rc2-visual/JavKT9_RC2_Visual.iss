#define MyAppName "JAVkt9"
#define MyAppVersion "0.8.1 RC2"
#define MyAppPublisher "JAVkt9 / GCstar GPL"
#define MyAppExeName "JavKT9-RC2-Inicio.exe"

; RC2 de prueba: instalador INDEPENDIENTE. RC1 queda intacta.
; La carpeta Payload se prepara desde la RC2 local que ya probo el usuario.
; No incluir colecciones ni archivos personales dentro de Payload.
[Setup]
AppId={{C9C8579B-7294-4A93-911B-202610220002}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName=JAVkt9 0.8.1 RC2 (version de prueba)
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\JavKT9-081-RC2-Prueba
DefaultGroupName=JAVkt9 0.8.1 RC2
UninstallDisplayName=JAVkt9 0.8.1 RC2 (version de prueba)
UninstallDisplayIcon={app}\JavKT9.ico
SetupIconFile=JavKT9.ico
OutputDir=Output
OutputBaseFilename=JAVkt9-0.8.1-RC2-Visual-PRUEBA-Windows-x64
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
DisableWelcomePage=no
DisableDirPage=no
Uninstallable=yes
LicenseFile=LICENSE_RC2.txt
VersionInfoVersion=0.8.1.2
VersionInfoCompany=JAVkt9
VersionInfoDescription=JAVkt9 0.8.1 RC2 - Instalador visual de prueba
VersionInfoProductName=JAVkt9
VersionInfoProductVersion=0.8.1.2

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
Source: "Payload\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\JAVkt9 0.8.1 RC2"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\JavKT9.ico"
Name: "{autodesktop}\JAVkt9 0.8.1 RC2"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\JavKT9.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Abrir JAVkt9 RC2"; Flags: nowait postinstall skipifsilent runasoriginaluser

; No borrar ni modificar carpetas de RC1, colecciones o perfiles de usuario.
[UninstallDelete]
; Solo se desinstalan los archivos instalados por este setup.
