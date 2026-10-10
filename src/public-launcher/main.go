// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2026 JAVkt9 contributors.
// New public-edition launcher; NOT the original RC1 Go source.
package main

import (
	"errors"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

const (
	appName       = "JAVkt9 Publica - desarrollo"
	profileName   = "JavKT9-Publica-Desarrollo"
	bridgeAddress = "127.0.0.1:53118"
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		message := fmt.Sprintf("%s: %v", appName, err)
		logError(message)
		showError(appName, message)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 1 && args[0] == "--version" {
		fmt.Println(appName)
		return nil
	}
	exe, err := os.Executable()
	if err != nil {
		return fmt.Errorf("localizar lanzador: %w", err)
	}
	root := filepath.Dir(exe)
	sourceMode := len(args) > 0 && args[0] == "--source-mode"
	if sourceMode {
		args = args[1:]
	}
	return launchWithMode(root, os.Getenv("APPDATA"), os.Getenv("LOCALAPPDATA"), os.Environ(), args, sourceMode)
}

// launch starts GCstar using the same GTK runtime layout as the RC1, but
// redirects APPDATA and LOCALAPPDATA only in the child process.
func launch(root, appData, localAppData string, env []string, args []string) error {
	return launchWithMode(root, appData, localAppData, env, args, false)
}

func launchWithMode(root, appData, localAppData string, env []string, args []string, sourceMode bool) error {
	if appData == "" || localAppData == "" {
		return errors.New("faltan APPDATA o LOCALAPPDATA; no se inicia para evitar perfiles compartidos")
	}
	if err := checkRuntime(root, sourceMode); err != nil {
		return err
	}
	if bridgeIsRunning(bridgeAddress) {
		return errors.New("el puerto 53118 ya está ocupado: cerrá JAVkt9/GCJav antes de iniciar esta edición para evitar mezclar sesiones")
	}
	runtimeApp := filepath.Join(appData, profileName, "Runtime")
	runtimeLocal := filepath.Join(localAppData, profileName, "Runtime")
	for _, dir := range []string{runtimeApp, runtimeLocal} {
		if err := os.MkdirAll(dir, 0700); err != nil {
			return fmt.Errorf("crear perfil aislado %s: %w", dir, err)
		}
	}
	usr := filepath.Join(root, "usr")
	bin := filepath.Join(root, "bin")
	env = setEnv(env, "APPDATA", runtimeApp)
	env = setEnv(env, "LOCALAPPDATA", runtimeLocal)
	env = setEnv(env, "PATH", filepath.Join(usr, "bin")+string(os.PathListSeparator)+filepath.Join(usr, "lib")+string(os.PathListSeparator)+envValue(env, "PATH"))
	env = setEnv(env, "GI_TYPELIB_PATH", filepath.Join(usr, "lib", "typelib"))
	env = setEnv(env, "GSETTINGS_SCHEMA_DIR", filepath.Join(usr, "lib", "schema"))
	env = setEnv(env, "LANG", "ES")

	var cmd *exec.Cmd
	if sourceMode {
		cmd = exec.Command(filepath.Join(bin, "wperl.exe"), append([]string{filepath.Join(bin, "gcstar")}, args...)...)
	} else {
		cmd = exec.Command(filepath.Join(bin, "gcstar.exe"), args...)
	}
	cmd.Dir = bin
	cmd.Env = env
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("iniciar GCstar: %w", err)
	}
	// The original RC1 checks for immediate failure after a short delay.
	// Waiting here also ensures the GUI child's lifetime is tracked.
	if err := cmd.Wait(); err != nil {
		return fmt.Errorf("GCstar terminó con error: %w", err)
	}
	return nil
}

func checkRuntime(root string, sourceMode bool) error {
	required := []string{
		filepath.Join("bin", "wperl.exe"),
		filepath.Join("usr", "bin"),
		filepath.Join("usr", "lib"),
		filepath.Join("usr", "lib", "typelib"),
		filepath.Join("usr", "lib", "schema"),
		filepath.Join("lib", "gcstar", "GCPlugins", "GCfilms", "GCJavLibraryBridge.pl"),
		filepath.Join("bin", "WebView2Host", "JavKT9WebView2.exe"),
	}
	if sourceMode {
		required = append(required, filepath.Join("bin", "gcstar"))
	} else {
		required = append(required, filepath.Join("bin", "gcstar.exe"))
	}
	for _, rel := range required {
		if _, err := os.Stat(filepath.Join(root, rel)); err != nil {
			return fmt.Errorf("componente faltante %s: %w", rel, err)
		}
	}
	return nil
}

func bridgeIsRunning(addr string) bool {
	conn, err := net.DialTimeout("tcp", addr, 300*time.Millisecond)
	if err != nil { return false }
	_ = conn.Close()
	return true
}

// Windows environment keys are case-insensitive. Remove all existing spellings
// before setting a value, avoiding ambiguous duplicate environment variables.
func setEnv(env []string, key, value string) []string {
	result := make([]string, 0, len(env)+1)
	for _, item := range env {
		name, _, ok := strings.Cut(item, "=")
		if !ok || !strings.EqualFold(name, key) { result = append(result, item) }
	}
	return append(result, key+"="+value)
}

func envValue(env []string, key string) string {
	for i := len(env)-1; i >= 0; i-- {
		name, value, ok := strings.Cut(env[i], "=")
		if ok && strings.EqualFold(name, key) { return value }
	}
	return ""
}

func logError(message string) {
	local := os.Getenv("LOCALAPPDATA")
	if local == "" { return }
	dir := filepath.Join(local, profileName, "Launcher")
	if os.MkdirAll(dir, 0700) != nil { return }
	f, err := os.OpenFile(filepath.Join(dir, "errores.log"), os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0600)
	if err != nil { return }
	defer f.Close()
	_, _ = fmt.Fprintf(f, "%s %s\n", time.Now().Format(time.RFC3339), message)
}
