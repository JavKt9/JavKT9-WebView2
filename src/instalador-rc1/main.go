// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2026 JAVkt9 contributors.
// Standalone Windows per-user installer for the unchanged JAVkt9 RC1 payload.
// This is NEW installer source, not the source of the original RC1 launchers.
package main

import (
 "archive/zip"
 "crypto/sha256"
 "encoding/base64"
 "encoding/hex"
 "errors"
 "fmt"
 "io"
 "os"
 "os/exec"
 "path/filepath"
 "strings"
 "syscall"
 "unicode/utf16"
 "unsafe"
)

const (
 appTitle = "JAVkt9 0.8.1 RC1 - Instalador candidato"
 installFolder = "JAVkt9-081-RC1-Instalada"
 uninstallExe = "Desinstalar-JAVkt9.exe"
 shortcutName = "JAVkt9 0.8.1 RC1 Candidata.lnk"
 registryKey = \`HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\JAVkt9-081-RC1-Candidata\`
 zipPrefix = "JAVkt9_0.8.1_RC1_PORTABLE/"
 zipSize int64 = 165179057
 zipSHA256 = "450ac674047e8df400fcfb242d25a0e4f5253f4cf664692b0ba0471028eb8e46"
 markerName = "INSTALACION_RC1_CANDIDATA.txt"
)

func main() {
 exe, err := os.Executable()
 if err != nil { fatal(err); return }
 if strings.EqualFold(filepath.Base(exe), uninstallExe) {
  if err := uninstall(exe); err != nil { fatal(err) }
  return
 }
 if len(os.Args) > 1 {
  if os.Args[1] == "--version" { message(appTitle, "Instalador candidato JAVkt9 0.8.1 RC1. Código GPL; paquete no validado en Windows.", 0x40); return }
  fatal(errors.New("opción no reconocida")); return
 }
 if err := install(exe); err != nil { fatal(err) }
}

func install(exe string) error {
 local := os.Getenv("LOCALAPPDATA")
 roaming := os.Getenv("APPDATA")
 if local == "" || roaming == "" { return errors.New("Windows no proporcionó LOCALAPPDATA y APPDATA") }
 dest := filepath.Join(local, "Programs", installFolder)
 if _, err := os.Stat(dest); err == nil { return fmt.Errorf("ya existe la carpeta de instalación:\n%s\n\nNo se modificó nada. Desinstalá la candidata anterior antes de reinstalar", dest) } else if !os.IsNotExist(err) { return err }
 if message(appTitle, "Se instalará JAVkt9 RC1 en:\n\n"+dest+"\n\nSe crearán un acceso en Inicio y una entrada de desinstalación. No se sobrescribirán Beta 1, RC1 existente ni GCJav.\n\nLa instalación puede tardar varios minutos.\n\n¿Continuar?", 0x41) != 1 { return nil }
 // Verify the entire embedded original ZIP before touching the target directory.
 z, stubSize, source, err := openAndVerify(exe)
 if err != nil { return err }
 defer source.Close()
 if err := validateEntries(z); err != nil { return err }
 if err := os.MkdirAll(filepath.Dir(dest), 0755); err != nil { return err }
 tmp, err := os.MkdirTemp(filepath.Dir(dest), ".JAVkt9-RC1-candidata-*")
 if err != nil { return err }
 defer os.RemoveAll(tmp)
 if err := extract(z, tmp); err != nil { return err }
 if _, err := os.Stat(filepath.Join(tmp, "JavKT9.exe")); err != nil { return fmt.Errorf("falta el lanzador JAVkt9.exe: %w", err) }
 if _, err := os.Stat(filepath.Join(tmp, "bin", "gcstar.exe")); err != nil { return fmt.Errorf("falta el motor GCstar: %w", err) }
 if err := createUninstaller(source, stubSize, filepath.Join(tmp, uninstallExe)); err != nil { return err }
 marker := "JAVkt9 0.8.1 RC1 candidata instalada por el Setup independiente.\r\nPaquete original RC1 conservado sin cambios.\r\nDesinstalar desde Configuración > Aplicaciones o Desinstalar-JAVkt9.exe.\r\nFuentes recuperadas: FUENTES_RECUPERADAS_RC1.zip.\r\nNo es una versión pública con fuentes completas verificadas.\r\n"
 if err := os.WriteFile(filepath.Join(tmp, markerName), []byte(marker), 0644); err != nil { return err }
 if err := os.Rename(tmp, dest); err != nil { return fmt.Errorf("no se pudo completar la instalación: %w", err) }
 var warnings []string
 if err := shortcut(dest, roaming, true); err != nil { warnings = append(warnings, "Acceso directo: "+err.Error()) }
 if err := registerUninstall(dest); err != nil { warnings = append(warnings, "Registro de desinstalación: "+err.Error()) }
 done := "JAVkt9 0.8.1 RC1 quedó instalado en:\n"+dest+"\n\nAbrilo desde Inicio > JAVkt9 0.8.1 RC1 Candidata o directamente con JavKT9.exe.\n\nNo se modificaron las instalaciones anteriores."
 if len(warnings)>0 { done += "\n\nAvisos: "+strings.Join(warnings,"; ") }
 message(appTitle, done, 0x40)
 return nil
}

func openAndVerify(exe string) (*zip.Reader,int64,*os.File,error) {
 f, err := os.Open(exe)
 if err != nil { return nil,0,nil,err }
 st, err := f.Stat()
 if err != nil { f.Close(); return nil,0,nil,err }
 offset := st.Size()-zipSize
 if offset < 100*1024 || offset > 30*1024*1024 { f.Close(); return nil,0,nil,errors.New("el instalador no contiene un ZIP RC1 adjunto válido") }
 h := sha256.New()
 if _, err := io.Copy(h,io.NewSectionReader(f,offset,zipSize)); err != nil { f.Close(); return nil,0,nil,err }
 if hex.EncodeToString(h.Sum(nil)) != zipSHA256 { f.Close(); return nil,0,nil,errors.New("falló la comprobación SHA-256 del contenido RC1: archivo dañado o alterado") }
 z, err := zip.NewReader(f,st.Size())
 if err != nil { f.Close(); return nil,0,nil,err }
 return z,offset,f,nil
}

func destination(name string) (string,bool,error) {
 if !strings.HasPrefix(name,zipPrefix) { return "",false,errors.New("entrada fuera del paquete RC1") }
 rel := strings.TrimPrefix(name,zipPrefix)
 if rel == "" { return "",false,nil }
 if strings.Contains(rel,"\\") || strings.HasPrefix(rel,"/") || strings.Contains(rel,":") { return "",false,errors.New("ruta ZIP insegura") }
 parts := strings.Split(rel,"/")
 for _, p := range parts { if p==".." || p=="." || p=="" { return "",false,errors.New("ruta ZIP no normalizada") } }
 if strings.HasPrefix(rel,"payload/") { rel = strings.TrimPrefix(rel,"payload/") } else if rel != "LEEME_PRIMERO.txt" && rel != "FUENTES_RECUPERADAS_RC1.zip" && rel != "MANIFIESTO_RC1.json" { return "",false,errors.New("entrada inesperada en la raíz del ZIP") }
 if rel=="" { return "",false,nil }
 // Old launch/diagnostic scripts may contain hard-coded paths for the original RC1.
 switch rel {
 case "Iniciar_JAVkt9_RC1_Publica.ps1","Iniciar_JAVkt9_RC1_Publica.cmd","Diagnosticar_JAVkt9_RC1_Publica.ps1","Diagnosticar_JAVkt9_RC1_Publica.cmd": return "",false,nil
 }
 return filepath.FromSlash(rel),true,nil
}

func validateEntries(z *zip.Reader) error {
 if len(z.File) < 6000 || len(z.File)>7000 { return errors.New("cantidad inesperada de archivos RC1") }
 seen := make(map[string]bool,len(z.File))
 var total uint64
 for _, entry := range z.File {
  if entry.Mode()&os.ModeSymlink != 0 { return errors.New("el ZIP contiene un enlace simbólico no permitido") }
  if entry.FileInfo().IsDir() { continue }
  rel,ok,err := destination(entry.Name)
  if err != nil { return fmt.Errorf("%s: %w",entry.Name,err) }
  if !ok { continue }
  key:=strings.ToLower(rel)
  if seen[key] { return fmt.Errorf("archivo duplicado en ZIP: %s",rel) }
  seen[key]=true
  total += entry.UncompressedSize64
  if total > 900*1024*1024 { return errors.New("el ZIP excede el tamaño máximo esperado") }
 }
 for _, must := range []string{"javkt9.exe","bin\\gcstar.exe","fuentes_recuperadas_rc1.zip"} { if !seen[must] { return fmt.Errorf("archivo esencial ausente: %s",must) } }
 return nil
}

func extract(z *zip.Reader, root string) error {
 for _, entry := range z.File {
  if entry.FileInfo().IsDir() { continue }
  rel,ok,err := destination(entry.Name)
  if err != nil { return err }; if !ok { continue }
  path := filepath.Join(root,rel)
  check,err:=filepath.Rel(root,path)
  if err!=nil || check==".." || strings.HasPrefix(check,".."+string(os.PathSeparator)) { return errors.New("ruta de extracción fuera de destino") }
  if err:=os.MkdirAll(filepath.Dir(path),0755); err!=nil { return err }
  src,err:=entry.Open(); if err!=nil { return err }
  out,err:=os.OpenFile(path,os.O_WRONLY|os.O_CREATE|os.O_EXCL,0644)
  if err!=nil { src.Close(); return err }
  n,copyErr:=io.Copy(out,src)
  closeErr:=out.Close(); srcErr:=src.Close()
  if copyErr!=nil { return copyErr }; if closeErr!=nil { return closeErr }; if srcErr!=nil { return srcErr }
  if uint64(n)!=entry.UncompressedSize64 { return fmt.Errorf("tamaño incorrecto al extraer %s",rel) }
 }
 return nil
}

func createUninstaller(src *os.File, size int64, path string) error {
 out,err:=os.OpenFile(path,os.O_WRONLY|os.O_CREATE|os.O_EXCL,0755)
 if err!=nil { return err }
 _,err=io.CopyN(out,io.NewSectionReader(src,0,size),size)
 if cerr:=out.Close();err==nil { err=cerr }
 return err
}

func shortcut(dest, roaming string, create bool) error {
 start := filepath.Join(roaming,"Microsoft","Windows","Start Menu","Programs",shortcutName)
 if !create { err:=os.Remove(start); if os.IsNotExist(err) { return nil }; return err }
 script := fmt.Sprintf(\`$ErrorActionPreference='Stop'; $w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut('%s'); $s.TargetPath='%s'; $s.WorkingDirectory='%s'; $s.IconLocation='%s'; $s.Description='JAVkt9 0.8.1 RC1 candidata'; $s.Save()\`, psQuote(start),psQuote(filepath.Join(dest,"JavKT9.exe")),psQuote(dest),psQuote(filepath.Join(dest,"icons","GCJav.ico")))
 return powerShell(script,false)
}

func registerUninstall(dest string) error {
 props:=[][3]string{
  {"DisplayName","REG_SZ","JAVkt9 0.8.1 RC1 Candidata"},
  {"DisplayVersion","REG_SZ","0.8.1-RC1"},
  {"Publisher","REG_SZ","JAVkt9 / GCstar contributors"},
  {"InstallLocation","REG_SZ",dest},
  {"DisplayIcon","REG_SZ",filepath.Join(dest,"JavKT9.exe")},
  {"UninstallString","REG_SZ",\`"\`+filepath.Join(dest,uninstallExe)+\`"\`},
  {"NoModify","REG_DWORD","1"},
  {"NoRepair","REG_DWORD","1"},
 }
 for _, p := range props {
  cmd:=exec.Command("reg.exe","add",registryKey,"/v",p[0],"/t",p[1],"/d",p[2],"/f")
  cmd.SysProcAttr=&syscall.SysProcAttr{HideWindow:true}
  if out,err:=cmd.CombinedOutput();err!=nil { return fmt.Errorf("reg.exe: %w (%s)",err,strings.TrimSpace(string(out))) }
 }
 return nil
}

func uninstall(exe string) error {
 local:=os.Getenv("LOCALAPPDATA"); roaming:=os.Getenv("APPDATA")
 if local=="" || roaming=="" { return errors.New("no se pudo localizar el perfil de Windows") }
 root:=filepath.Dir(exe)
 expected:=filepath.Join(local,"Programs",installFolder)
 if !strings.EqualFold(filepath.Clean(root),filepath.Clean(expected)) { return errors.New("desinstalador fuera de la carpeta prevista; no se eliminó nada") }
 if _,err:=os.Stat(filepath.Join(root,markerName));err!=nil { return errors.New("falta el marcador de esta instalación; no se eliminó nada") }
 if message("Desinstalar JAVkt9 RC1 candidata","Se quitará solamente:\n"+root+"\n\nNo se borrarán las bibliotecas personales ni otras versiones de JAVkt9 o GCJav.\n\n¿Continuar?",0x41)!=1 { return nil }
 if err:=shortcut(root,roaming,false);err!=nil { return err }
 cmd:=exec.Command("reg.exe","delete",registryKey,"/f")
 cmd.SysProcAttr=&syscall.SysProcAttr{HideWindow:true}
 _=cmd.Run()
 // Windows does not allow a running EXE to delete itself. A separate hidden
 // PowerShell process waits for this uninstaller to exit and then removes it.
 script:=fmt.Sprintf(\`$ErrorActionPreference='Stop'; $parentProcessId=%d; for($i=0;$i -lt 120;$i++){if(-not (Get-Process -Id $parentProcessId -ErrorAction SilentlyContinue)){break}; Start-Sleep -Milliseconds 250}; Remove-Item -LiteralPath '%s' -Recurse -Force\`,os.Getpid(),psQuote(root))
 if err:=powerShell(script,true);err!=nil { return err }
 message("Desinstalar JAVkt9 RC1 candidata","Se inició la desinstalación. La carpeta se quitará unos segundos después de cerrar este mensaje. Los datos personales y otras versiones quedan intactos.",0x40)
 return nil
}

func psQuote(s string) string { return strings.ReplaceAll(s,"'","''") }
func powerShell(script string, detached bool) error {
 encoded:=base64.StdEncoding.EncodeToString(utf16Bytes(script))
 cmd:=exec.Command("powershell.exe","-NoProfile","-NonInteractive","-ExecutionPolicy","Bypass","-EncodedCommand",encoded)
 cmd.SysProcAttr=&syscall.SysProcAttr{HideWindow:true}
 if detached { cmd.Dir=os.TempDir(); return cmd.Start() }
 out,err:=cmd.CombinedOutput()
 if err!=nil { return fmt.Errorf("PowerShell: %w (%s)",err,strings.TrimSpace(string(out))) }
 return nil
}
func utf16Bytes(s string) []byte {
 units:=utf16.Encode([]rune(s)); out:=make([]byte,0,len(units)*2)
 for _,u:=range units { out=append(out,byte(u),byte(u>>8)) }
 return out
}
func message(title,text string,flags uintptr) uintptr {
 user32:=syscall.NewLazyDLL("user32.dll")
 box:=user32.NewProc("MessageBoxW")
 t,_:=syscall.UTF16PtrFromString(text); cap,_:=syscall.UTF16PtrFromString(title)
 ret,_,_:=box.Call(0,uintptr(unsafe.Pointer(t)),uintptr(unsafe.Pointer(cap)),flags)
 return ret
}
func fatal(err error) { message(appTitle,"No se completó la operación:\n\n"+err.Error(),0x10) }
