#define MyAppName "JAVkt9"
#define MyAppVersion "0.8.1 RC1"
#define MyAppPublisher "JAVkt9 / GCstar GPL"
#define MyAppExeName "JavKT9.exe"

; Instalador Inno Setup con asistente visual, basado en installer/JavKT9.iss.
; Instala una RC1 separada, no sobrescribe JavKT9, GCJav ni otras RC.
[Setup]
AppId={{8B2E714F-16C7-481B-AC60-810C20261011}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName=JAVkt9 0.8.1 RC1 GitHub
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\JavKT9-081-RC1-GitHub
DefaultGroupName=JAVkt9 0.8.1 RC1
UninstallDisplayName=JAVkt9 0.8.1 RC1 GitHub
UninstallDisplayIcon={app}\JavKT9.ico
SetupIconFile=..\installer\JavKT9.ico
OutputDir=..\output-rc1-github
OutputBaseFilename=JAVkt9-0.8.1-RC1-GitHub-Setup-Windows-x64
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
VersionInfoVersion=0.8.1.0
VersionInfoCompany=JAVkt9
VersionInfoDescription=JAVkt9 0.8.1 RC1 - Windows Setup
VersionInfoProductName=JAVkt9
VersionInfoProductVersion=0.8.1.0
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
Name: "{autoprograms}\JAVkt9 0.8.1 RC1"; Filename: "{app}\JavKT9.exe"; WorkingDir: "{app}"; IconFilename: "{app}\JavKT9.ico"
Name: "{autodesktop}\JAVkt9 0.8.1 RC1"; Filename: "{app}\JavKT9.exe"; WorkingDir: "{app}"; IconFilename: "{app}\JavKT9.ico"

[Run]
Filename: "{app}\JavKT9.exe"; Description: "Abrir JAVkt9 ahora"; Flags: nowait postinstall skipifsilent

; No limpiar ni modificar otras versiones ni datos de colecciones.
[UninstallDelete]
; Las colecciones y los perfiles de usuario quedan intactos.
