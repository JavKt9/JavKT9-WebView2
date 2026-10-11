// SPDX-License-Identifier: GPL-2.0-or-later
// Nuevo lanzador JAVkt9 de desarrollo; NO es el fuente original de la RC1.
package main

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

const profile = "JavKT9-Publica-Desarrollo"

func main() {
	if len(os.Args) == 2 && os.Args[1] == "--version" {
		fmt.Println("JAVkt9 - lanzador con fuentes, privado")
		return
	}
	if err := run(); err != nil {
		showError("JAVkt9 - prueba privada", err.Error())
		os.Exit(1)
	}
}
func run() error {
	exe, err := os.Executable()
	if err != nil {
		return err
	}
	source := len(os.Args) > 1 && os.Args[1] == "--source-mode"
	args := os.Args[1:]
	if source {
		args = args[1:]
	}
	return launch(filepath.Dir(exe), os.Getenv("APPDATA"), os.Getenv("LOCALAPPDATA"), os.Environ(), args, source)
}
func setEnv(env []string, k, v string) []string {
	out := make([]string, 0, len(env)+1)
	for _, x := range env {
		a, _, ok := strings.Cut(x, "=")
		if !ok || !strings.EqualFold(a, k) {
			out = append(out, x)
		}
	}
	return append(out, k+"="+v)
}
func envValue(env []string, k string) string {
	for i := len(env) - 1; i >= 0; i-- {
		a, b, ok := strings.Cut(env[i], "=")
		if ok && strings.EqualFold(a, k) {
			return b
		}
	}
	return ""
}
func checkRuntime(root string, source bool) error {
	required := []string{"bin/wperl.exe", "usr/bin", "usr/lib", "usr/lib/typelib", "usr/lib/schema", "lib/gcstar/GCPlugins/GCfilms/GCJavLibraryBridge.pl", "bin/WebView2Host/JavKT9WebView2.exe"}
	if source {
		required = append(required, "bin/gcstar")
	} else {
		required = append(required, "bin/gcstar.exe")
	}
	for _, rel := range required {
		if _, err := os.Stat(filepath.Join(root, filepath.FromSlash(rel))); err != nil {
			return fmt.Errorf("falta %s: %w", rel, err)
		}
	}
	return nil
}
func launch(root, appData, localData string, env []string, args []string, source bool) error {
	if appData == "" || localData == "" {
		return errors.New("APPDATA o LOCALAPPDATA vacios")
	}
	if err := checkRuntime(root, source); err != nil {
		return err
	}
	isolatedApp := filepath.Join(appData, profile, "Runtime")
	isolatedLocal := filepath.Join(localData, profile, "Runtime")
	for _, p := range []string{isolatedApp, isolatedLocal} {
		if err := os.MkdirAll(p, 0700); err != nil {
			return err
		}
	}
	// Close a Bridge from the preceding session if its token still matches.
	// Older Bridges are cleaned up only after Windows verifies BOTH their
	// executable and script paths belong to this experimental installation.
	sessionFile := filepath.Join(isolatedLocal, "JavKT9", "bridge.session")
	if err := os.MkdirAll(filepath.Dir(sessionFile), 0700); err != nil {
		return err
	}
	if portBusy() {
		if old, err := os.ReadFile(sessionFile); err == nil {
			_ = shutdownBridge(strings.TrimSpace(string(old)))
			waitForPort(1800 * time.Millisecond)
		}
		if portBusy() {
			if err := cleanupOwnBridge(root); err != nil {
				return fmt.Errorf("puerto 53118 ocupado: %w", err)
			}
			waitForPort(1800 * time.Millisecond)
		}
		if portBusy() {
			return errors.New("puerto 53118 ocupado por otro programa o una edicion activa; no se cerró ningún proceso ajeno")
		}
	}
	secret, err := newSessionToken()
	if err != nil {
		return err
	}
	if err := os.WriteFile(sessionFile, []byte(secret+"\n"), 0600); err != nil {
		return err
	}
	defer func() {
		// Never delete a newer session's token.
		if current, err := os.ReadFile(sessionFile); err == nil && strings.TrimSpace(string(current)) == secret {
			_ = os.Remove(sessionFile)
		}
	}()
	usr := filepath.Join(root, "usr")
	bin := filepath.Join(root, "bin")
	// El host WebView2 de la RC1 obtiene LocalApplicationData de Windows,
	// no de la variable LOCALAPPDATA aislada. Comunicar al Bridge el destino
	// real de la captura, sin cambiar el perfil aislado de GCstar.
	env = setEnv(env, "JAVKT9_WEBVIEW2_CAPTURE_BASE", localData)
	env = setEnv(env, "JAVKT9_BRIDGE_SESSION", secret)
	env = setEnv(env, "APPDATA", isolatedApp)
	env = setEnv(env, "LOCALAPPDATA", isolatedLocal)
	env = setEnv(env, "PATH", filepath.Join(usr, "bin")+string(os.PathListSeparator)+filepath.Join(usr, "lib")+string(os.PathListSeparator)+envValue(env, "PATH"))
	env = setEnv(env, "GI_TYPELIB_PATH", filepath.Join(usr, "lib", "typelib"))
	env = setEnv(env, "GSETTINGS_SCHEMA_DIR", filepath.Join(usr, "lib", "schema"))
	env = setEnv(env, "LANG", "ES")
	var cmd *exec.Cmd
	if source {
		cmd = exec.Command(filepath.Join(bin, "wperl.exe"), append([]string{filepath.Join(bin, "gcstar")}, args...)...)
	} else {
		cmd = exec.Command(filepath.Join(bin, "gcstar.exe"), args...)
	}
	cmd.Dir = bin
	cmd.Env = env
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("iniciar GCstar: %w", err)
	}
	waitErr := cmd.Wait()
	// GCstar has exited: terminate only the Bridge created by THIS session.
	_ = shutdownBridge(secret)
	waitForPort(1300 * time.Millisecond)
	if portBusy() {
		_ = cleanupOwnBridge(root)
	}
	if waitErr != nil {
		return fmt.Errorf("GCstar terminó: %w", waitErr)
	}
	return nil
}

// A Bridge is not the GUI process: it must not survive the launcher session.
func portBusy() bool {
	c, err := net.DialTimeout("tcp", "127.0.0.1:53118", 250*time.Millisecond)
	if err != nil {
		return false
	}
	_ = c.Close()
	return true
}
func waitForPort(d time.Duration) {
	deadline := time.Now().Add(d)
	for portBusy() && time.Now().Before(deadline) {
		time.Sleep(100 * time.Millisecond)
	}
}
func newSessionToken() (string, error) {
	b := make([]byte, 24)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}
func shutdownBridge(token string) error {
	if len(token) < 32 {
		return errors.New("token de sesion no valido")
	}
	client := &http.Client{Timeout: 1200 * time.Millisecond}
	resp, err := client.Get("http://127.0.0.1:53118/shutdown?key=" + url.QueryEscape(token))
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	b, _ := io.ReadAll(io.LimitReader(resp.Body, 32))
	if resp.StatusCode != 200 || strings.TrimSpace(string(b)) != "OK" {
		return errors.New("Bridge ajeno o sin autorizacion de cierre")
	}
	return nil
}
