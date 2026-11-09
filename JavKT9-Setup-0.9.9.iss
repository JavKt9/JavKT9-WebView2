#define SourceRoot "C:\JavKT9-ObsidianWine-Prueba"

; JavKT9 0.9.9 – instalador visual en desarrollo
; AUDITORIA: NO PUBLICAR; previews ilustrativas; falta probar instalacion limpia y actualizacion.
; Requiere Inno Setup 7.1 y los archivos de InstallerAssets/ en SourceRoot.

[Setup]
AppId={{F4CF4D9C-496B-5CC6-98FE-F95EA629C826}
AppName=JavKT9
AppVersion=0.9.9
AppVerName=JavKT9 0.9.9
AppPublisher=JavKT9
DefaultDirName={autopf}\JavKT9
UsePreviousAppDir=yes
DisableWelcomePage=no
DisableReadyPage=yes
DefaultGroupName=JavKT9
PrivilegesRequired=admin
MinVersion=10.0
SetupArchitecture=x64
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern dynamic
WizardSizePercent=150,145
SetupIconFile={#SourceRoot}\InstallerAssets\JavKT9-Logo.ico
WizardImageFile={#SourceRoot}\InstallerAssets\Wizard.png
WizardImageFileDynamicDark={#SourceRoot}\InstallerAssets\Wizard.png
WizardSmallImageFile={#SourceRoot}\InstallerAssets\WizardSmall.png
WizardSmallImageFileDynamicDark={#SourceRoot}\InstallerAssets\WizardSmall.png
WizardSmallImageBackColor=none
WizardSmallImageBackColorDynamicDark=none
UninstallDisplayName=JavKT9 0.9.9
UninstallDisplayIcon={app}\assets\JavKT9-Logo.ico
VersionInfoVersion=0.9.9.0
VersionInfoProductVersion=0.9.9.0
VersionInfoProductName=JavKT9
VersionInfoDescription=Instalador de JavKT9 0.9.9
Compression=lzma2
SolidCompression=yes
OutputDir=G:\JavKT9-KT9V1-Distribucion
OutputBaseFilename=JavKT9-Setup-0.9.9-ETAPA10-CANDIDATO-NO-PUBLICAR
CloseApplications=yes

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear acceso directo en el escritorio"; Flags: unchecked

[Files]
; Previews embebidas solo en el instalador. BMP para TBitmapImage.
Source: "{#SourceRoot}\InstallerAssets\Vista-Clasica.bmp"; Flags: dontcopy noencryption
Source: "{#SourceRoot}\InstallerAssets\Vista-Moderna-V1.bmp"; Flags: dontcopy noencryption
Source: "{#SourceRoot}\InstallerAssets\Vista-Moderna-V2.bmp"; Flags: dontcopy noencryption
Source: "{#SourceRoot}\JavKT9.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\Iniciar-JavKT9.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\InstallerAssets\JavKT9-Logo.ico"; DestDir: "{app}\assets"; Flags: ignoreversion
Source: "{#SourceRoot}\lib\*"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.gcs,*.log,*.tmp,*.bak,*.old,*.zip,*.7z,*.rar"
Source: "{#SourceRoot}\share\*"; DestDir: "{app}\share"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.gcs,*.log,*.tmp,*.bak,*.old,*.zip,*.7z,*.rar"
Source: "{#SourceRoot}\bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.gcs,*.log,*.tmp,*.bak,*.old,*.zip,*.7z,*.rar"
Source: "{#SourceRoot}\app\*"; DestDir: "{app}\app"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.gcs,*.log,*.tmp,*.bak,*.old,*.zip,*.7z,*.rar"

[Icons]
Name: "{autoprograms}\JavKT9"; Filename: "{app}\Iniciar-JavKT9.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\assets\JavKT9-Logo.ico"
Name: "{autodesktop}\JavKT9"; Filename: "{app}\Iniciar-JavKT9.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\assets\JavKT9-Logo.ico"; Tasks: desktopicon

[Run]
; El primer inicio usa el mismo lanzador probado que los accesos directos.
Filename: "{app}\Iniciar-JavKT9.cmd"; WorkingDir: "{app}"; Description: "Iniciar JavKT9"; Flags: postinstall nowait skipifsilent runasoriginaluser shellexec

[UninstallDelete]
; Solo marcadores de instalacion; nunca AppData ni bibliotecas.
Type: files; Name: "{app}\JavKT9-Initial-Interface.conf"
Type: files; Name: "{app}\JavKT9-Installation-ID.txt"

[Code]
var
  InterfacePage: TWizardPage;
  ClassicRadio: TNewRadioButton;
  V1Radio: TNewRadioButton;
  V2Radio: TNewRadioButton;
  PreviewImage: TBitmapImage;
  PreviewTitle: TNewStaticText;
  PreviewFoot: TNewStaticText;
  FirstInstallation: Boolean;
  SummaryPage: TWizardPage;
  SummaryCard: TPanel;
  SummaryTitle: TNewStaticText;
  SummaryDescription: TNewStaticText;
  SummaryOperation: TNewStaticText;
  SummaryDestination: TNewStaticText;
  SummaryInterface: TNewStaticText;
  SummaryShortcuts: TNewStaticText;
  SummaryFoot: TNewStaticText;


function ExistingInstallation(): Boolean;
var
  D, UninstallKey: String;
begin
  { Pascal Script no admite constantes declaradas dentro de funciones. }
  UninstallKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{F4CF4D9C-496B-5CC6-98FE-F95EA629C826}_is1';
  D := AddBackslash(WizardDirValue);
  { Proteger tanto instalaciones con marcador como ediciones anteriores. }
  Result := FileExists(D + 'JavKT9-Installation-ID.txt') or
            FileExists(D + 'JavKT9.exe') or
            FileExists(D + 'app\lib\gcstar\GCMainWindow.pm');

  { Si el instalador anterior esta registrado, no tratarlo como instalacion nueva,
    aunque el usuario haya seleccionado otra carpeta. Revisamos ambas vistas
    del registro por compatibilidad con instaladores anteriores. }
  if not Result then
    Result := RegKeyExists(HKLM64, UninstallKey) or
              RegKeyExists(HKLM32, UninstallKey) or
              RegKeyExists(HKCU, UninstallKey);
end;

function SelectedInitialMode(): String;
begin
  Result := 'v2';
  if ClassicRadio.Checked then Result := 'clasico'
  else if V1Radio.Checked then Result := 'v1';
end;

procedure ShowPreview();
var
  FileName: String;
begin
  if ClassicRadio.Checked then
  begin
    FileName := 'Vista-Clasica.bmp';
    PreviewTitle.Caption := 'Clásica  ·  10 temas';
  end
  else if V1Radio.Checked then
  begin
    FileName := 'Vista-Moderna-V1.bmp';
    PreviewTitle.Caption := 'Moderna V1  ·  7 temas';
  end
  else
  begin
    FileName := 'Vista-Moderna-V2.bmp';
    PreviewTitle.Caption := 'Moderna V2  ·  6 temas';
  end;
  PreviewImage.Bitmap.LoadFromFile(ExpandConstant('{tmp}\') + FileName);
end;

procedure SelectInterface(Sender: TObject);
begin
  ShowPreview();
end;

function SkipInterfacePage(Sender: TWizardPage): Boolean;
begin
  Result := ExistingInstallation();
end;

procedure AddInfoLabel(const AText: String; ALeft, ATop, AWidth, AHeight: Integer);
var
  L: TNewStaticText;
begin
  L := TNewStaticText.Create(WizardForm);
  L.Parent := InterfacePage.Surface;
  L.Caption := AText;
  L.Left := ALeft;
  L.Top := ATop;
  L.Width := AWidth;
  L.Height := AHeight;
  L.WordWrap := True;
end;

{ === JAVKT9 0.9.9 / ETAPA 10: RESUMEN AUTONOMO SIN SCROLL === }
{ Una pagina propia evita la superposicion del ReadyMemo nativo. }
function SummaryLabel(AParent: TWinControl; AX, AY, AW, AH, AFontSize: Integer;
  ACaption: String; ABold: Boolean; AColor: TColor): TNewStaticText;
var
  L: TNewStaticText;
begin
  L := TNewStaticText.Create(WizardForm);
  L.Parent := AParent;
  L.Left := AX;
  L.Top := AY;
  L.Width := AW;
  L.Height := AH;
  L.AutoSize := False;
  L.WordWrap := True;
  L.Font.Name := 'Segoe UI';
  L.Font.Size := AFontSize;
  L.Font.Color := AColor;
  if ABold then L.Font.Style := [fsBold];
  L.Caption := ACaption;
  Result := L;
end;

procedure CreateSummaryPage();
var
  W, H, Gap, CardTop, CardH, CardW, ColW, RightX, SecondTop: Integer;
  TextColor, MutedColor, AccentColor, CardColor: TColor;
begin
  SummaryPage := CreateCustomPage(wpSelectTasks,
    'Listo para instalar',
    'Revisá la configuración de JavKT9 antes de comenzar.');
  W := SummaryPage.SurfaceWidth;
  H := SummaryPage.SurfaceHeight;
  Gap := ScaleX(20);
  if IsDarkInstallMode then
  begin
    TextColor := clWhite;
    MutedColor := $00D8CED1;
    AccentColor := $00F792EB;
    CardColor := $00352D35;
  end
  else
  begin
    TextColor := $002A2029;
    MutedColor := $00625964;
    AccentColor := $00932683;
    CardColor := $00F3EDF4;
  end;

  SummaryTitle := SummaryLabel(SummaryPage.Surface, Gap, ScaleY(18),
    W - Gap * 2, ScaleY(45), 18,
    'JavKT9 0.9.9', True, TextColor);
  SummaryDescription := SummaryLabel(SummaryPage.Surface, Gap, ScaleY(65),
    W - Gap * 2, ScaleY(38), 10,
    'Comprobá estos datos antes de iniciar la instalación.', False, MutedColor);

  CardTop := ScaleY(128);
  CardH := H - CardTop - ScaleY(60);
  if CardH > ScaleY(315) then CardH := ScaleY(315);
  if CardH < ScaleY(240) then
  begin
    CardTop := ScaleY(112);
    CardH := H - CardTop - ScaleY(44);
  end;
  CardW := W - Gap * 2;
  SummaryCard := TPanel.Create(WizardForm);
  SummaryCard.Parent := SummaryPage.Surface;
  SummaryCard.ParentBackground := False;
  SummaryCard.BevelOuter := bvNone;
  SummaryCard.Caption := '';
  SummaryCard.Color := CardColor;
  SummaryCard.Left := Gap;
  SummaryCard.Top := CardTop;
  SummaryCard.Width := CardW;
  SummaryCard.Height := CardH;

  ColW := (CardW div 2) - ScaleX(34);
  RightX := (CardW div 2) + ScaleX(12);
  SecondTop := (CardH div 2) + ScaleY(3);

  SummaryLabel(SummaryCard, ScaleX(22), ScaleY(17), ColW, ScaleY(23),
    9, 'OPERACIÓN', True, AccentColor);
  SummaryOperation := SummaryLabel(SummaryCard, ScaleX(22), ScaleY(46),
    ColW, ScaleY(58), 12, '', True, TextColor);
  SummaryLabel(SummaryCard, RightX, ScaleY(17), ColW, ScaleY(23),
    9, 'CARPETA DE INSTALACIÓN', True, AccentColor);
  SummaryDestination := SummaryLabel(SummaryCard, RightX, ScaleY(46),
    ColW, ScaleY(65), 10, '', False, TextColor);

  SummaryLabel(SummaryCard, ScaleX(22), SecondTop, ColW, ScaleY(23),
    9, 'INTERFAZ INICIAL', True, AccentColor);
  SummaryInterface := SummaryLabel(SummaryCard, ScaleX(22),
    SecondTop + ScaleY(29), ColW, ScaleY(63), 11, '', False, TextColor);
  SummaryLabel(SummaryCard, RightX, SecondTop, ColW, ScaleY(23),
    9, 'ACCESOS DIRECTOS', True, AccentColor);
  SummaryShortcuts := SummaryLabel(SummaryCard, RightX,
    SecondTop + ScaleY(29), ColW, ScaleY(63), 11, '', False, TextColor);

  SummaryFoot := SummaryLabel(SummaryPage.Surface, Gap,
    CardTop + CardH + ScaleY(12), W - Gap * 2, ScaleY(40), 9,
    'Las bibliotecas, favoritos y preferencias existentes se conservan.',
    False, MutedColor);
end;

procedure RefreshSummaryPage();
var
  ModeText: String;
begin
  if ExistingInstallation() then
  begin
    SummaryOperation.Caption := 'Actualizar JavKT9';
    SummaryDescription.Caption :=
      'La versión existente se actualizará sin desinstalarla primero.';
    SummaryInterface.Caption :=
      'Se conserva tu interfaz y sus colores.';
  end
  else
  begin
    SummaryOperation.Caption := 'Instalación nueva';
    SummaryDescription.Caption :=
      'Todo listo para instalar JavKT9 0.9.9.';
    ModeText := 'Moderna V2 · 6 temas';
    if ClassicRadio.Checked then ModeText := 'Clásica · 10 temas'
    else if V1Radio.Checked then ModeText := 'Moderna V1 · 7 temas';
    SummaryInterface.Caption := ModeText + #13#10 +
      'Podrás cambiarla desde Apariencia.';
  end;
  SummaryDestination.Caption := WizardDirValue;
  SummaryShortcuts.Caption := 'Menú Inicio';
  if IsTaskSelected('desktopicon') then
    SummaryShortcuts.Caption := SummaryShortcuts.Caption + #13#10 +
      'Escritorio';
end;

procedure InitializeWizard();
var
  W, H, LeftWidth, PreviewLeft, PreviewW, PreviewH: Integer;
begin
  InterfacePage := CreateCustomPage(wpSelectDir,
      'Elegí tu interfaz inicial',
      'JavKT9 0.9.9 - Seleccioná un diseño. Podrás cambiarlo desde Apariencia sin perder datos.');
  InterfacePage.OnShouldSkipPage := @SkipInterfacePage;

  ExtractTemporaryFile('Vista-Clasica.bmp');
  ExtractTemporaryFile('Vista-Moderna-V1.bmp');
  ExtractTemporaryFile('Vista-Moderna-V2.bmp');

  W := InterfacePage.SurfaceWidth;
  H := InterfacePage.SurfaceHeight;
  LeftWidth := ScaleX(208);
  PreviewLeft := LeftWidth + ScaleX(21);
  PreviewW := W - PreviewLeft - ScaleX(8);
  PreviewH := (PreviewW * 9) div 16;
  if PreviewH > H - ScaleY(70) then PreviewH := H - ScaleY(70);

  ClassicRadio := TNewRadioButton.Create(WizardForm);
  ClassicRadio.Parent := InterfacePage.Surface;
  ClassicRadio.Caption := 'Clásica';
  ClassicRadio.Left := ScaleX(12);
  ClassicRadio.Top := ScaleY(20);
  ClassicRadio.Width := LeftWidth - ScaleX(12);
  ClassicRadio.Height := ScaleY(25);
  ClassicRadio.Font.Style := [fsBold];
  ClassicRadio.OnClick := @SelectInterface;
  AddInfoLabel('Estilo tradicional' + #13#10 + '10 temas disponibles',
      ScaleX(34), ScaleY(48), LeftWidth - ScaleX(33), ScaleY(48));

  V1Radio := TNewRadioButton.Create(WizardForm);
  V1Radio.Parent := InterfacePage.Surface;
  V1Radio.Caption := 'Moderna V1';
  V1Radio.Left := ScaleX(12);
  V1Radio.Top := ScaleY(117);
  V1Radio.Width := LeftWidth - ScaleX(12);
  V1Radio.Height := ScaleY(25);
  V1Radio.Font.Style := [fsBold];
  V1Radio.OnClick := @SelectInterface;
  AddInfoLabel('Biblioteca moderna' + #13#10 + '7 temas disponibles',
      ScaleX(34), ScaleY(145), LeftWidth - ScaleX(33), ScaleY(48));

  V2Radio := TNewRadioButton.Create(WizardForm);
  V2Radio.Parent := InterfacePage.Surface;
  V2Radio.Caption := 'Moderna V2 (recomendada)';
  V2Radio.Left := ScaleX(12);
  V2Radio.Top := ScaleY(214);
  V2Radio.Width := LeftWidth - ScaleX(12);
  V2Radio.Height := ScaleY(25);
  V2Radio.Font.Style := [fsBold];
  V2Radio.OnClick := @SelectInterface;
  AddInfoLabel('Biblioteca actualizada' + #13#10 + '6 temas disponibles',
      ScaleX(34), ScaleY(242), LeftWidth - ScaleX(33), ScaleY(48));

  PreviewTitle := TNewStaticText.Create(WizardForm);
  PreviewTitle.Parent := InterfacePage.Surface;
  PreviewTitle.Left := PreviewLeft;
  PreviewTitle.Top := ScaleY(13);
  PreviewTitle.Width := PreviewW;
  PreviewTitle.Height := ScaleY(27);
  PreviewTitle.Font.Style := [fsBold];
  PreviewTitle.Font.Size := 12;

  PreviewImage := TBitmapImage.Create(WizardForm);
  PreviewImage.Parent := InterfacePage.Surface;
  PreviewImage.Left := PreviewLeft;
  PreviewImage.Top := ScaleY(47);
  PreviewImage.Width := PreviewW;
  PreviewImage.Height := PreviewH;
  PreviewImage.Stretch := True;

  PreviewFoot := TNewStaticText.Create(WizardForm);
  PreviewFoot.Parent := InterfacePage.Surface;
  PreviewFoot.Left := PreviewLeft;
  PreviewFoot.Top := ScaleY(53) + PreviewH;
  PreviewFoot.Width := PreviewW;
  PreviewFoot.Height := ScaleY(36);
  PreviewFoot.WordWrap := True;
  PreviewFoot.Caption := 'Vista ilustrativa. Las capturas reales se añadirán antes de publicar.';

  V2Radio.Checked := True;
  ShowPreview();
  CreateSummaryPage();
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  FirstInstallation := not ExistingInstallation();
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  D, Marker, Seed: String;
begin
  if (CurStep = ssPostInstall) and FirstInstallation then
  begin
    D := AddBackslash(ExpandConstant('{app}'));
    Marker := D + 'JavKT9-Installation-ID.txt';
    Seed := D + 'JavKT9-Initial-Interface.conf';
    { Nunca sobreescribir una seleccion inicial que ya exista. }
    if not FileExists(Seed) then
      if not SaveStringToFile(Seed, 'mode=' + SelectedInitialMode() + #13#10, False) then
        RaiseException('No se pudo guardar la interfaz inicial.');
    { El marcador se crea al final, una vez guardada la seleccion. }
    if not FileExists(Marker) then
      if not SaveStringToFile(Marker, 'JavKT9'#13#10, False) then
        RaiseException('No se pudo crear el marcador de instalación.');
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = SummaryPage.ID then
  begin
    RefreshSummaryPage();
    { Inno no cambia automaticamente Siguiente por Instalar si se omite wpReady. }
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall);
  end
  else if (CurPageID = wpSelectDir) or
          (CurPageID = wpSelectTasks) or
          (CurPageID = InterfacePage.ID) then
  begin
    WizardForm.NextButton.Caption := SetupMessage(msgButtonNext);
  end;
end;
