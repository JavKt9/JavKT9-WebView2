// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2026 JAVkt9 contributors.
// Replacement source for the public edition, not the original RC1 binary.
package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

const editionMarker = "JavKT9-Publica-Desarrollo"

func main() {
	if len(os.Args) == 2 && os.Args[1] == "--version" {
		fmt.Println("JAVkt9 Public Bridge Launcher - development")
		return
	}
	if err := run(); err != nil {
		logError(err)
		os.Exit(1)
	}
}

func run() error {
	exe, err := os.Executable()
	if err != nil {
		return err
	}
	bin := filepath.Dir(exe)
	root := filepath.Dir(bin)
	return launch(root, os.Getenv("LOCALAPPDATA"))
}

func launch(root, localAppData string) error {
	if localAppData == "" || !strings.Contains(strings.ToLower(localAppData), strings.ToLower(editionMarker)) {
		return errors.New("se requiere perfil LOCALAPPDATA aislado de la edicion publica")
	}
	script := filepath.Join(root, "lib", "gcstar", "GCPlugins", "GCfilms", "GCJavLibraryBridge.pl")
	interpreter := filepath.Join(root, "bin", "wperl.exe")
	for _, path := range []string{script, interpreter} {
		info, err := os.Stat(path)
		if err != nil {
			return fmt.Errorf("falta componente del Bridge: %s: %w", path, err)
		}
		if info.IsDir() {
			return fmt.Errorf("componente del Bridge es un directorio: %s", path)
		}
	}
	cmd := exec.Command(interpreter, script)
	cmd.Dir = filepath.Join(root, "bin")
	cmd.Env = os.Environ()
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("Bridge Perl termino con error: %w", err)
	}
	return nil
}

func logError(err error) {
	local := os.Getenv("LOCALAPPDATA")
	if local == "" || !strings.Contains(strings.ToLower(local), strings.ToLower(editionMarker)) {
		return
	}
	dir := filepath.Join(local, "JavKT9", "Launcher")
	if os.MkdirAll(dir, 0700) != nil {
		return
	}
	file, e := os.OpenFile(filepath.Join(dir, "bridge-launcher.log"), os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0600)
	if e != nil {
		return
	}
	defer file.Close()
	_, _ = fmt.Fprintf(file, "%s %s\n", time.Now().Format(time.RFC3339), err)
}
