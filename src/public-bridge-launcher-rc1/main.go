// SPDX-License-Identifier: GPL-2.0-or-later
// Nuevo BridgeLauncher; NO es el codigo fuente original de RC1.
package main

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

const profile = "JavKT9-Publica-Desarrollo"

func main() {
	if len(os.Args) == 2 && os.Args[1] == "--version" {
		fmt.Println("Bridge JAVkt9 nuevo - privado")
		return
	}
	if err := run(); err != nil {
		os.Exit(1)
	}
}
func run() error {
	exe, err := os.Executable()
	if err != nil {
		return err
	}
	return launch(filepath.Dir(filepath.Dir(exe)), os.Getenv("LOCALAPPDATA"))
}
func launch(root, local string) error {
	if local == "" || !strings.Contains(strings.ToLower(local), strings.ToLower(profile)) {
		return errors.New("perfil no aislado")
	}
	script := filepath.Join(root, "lib", "gcstar", "GCPlugins", "GCfilms", "GCJavLibraryBridge.pl")
	perl := filepath.Join(root, "bin", "wperl.exe")
	for _, p := range []string{script, perl} {
		info, err := os.Stat(p)
		if err != nil {
			return fmt.Errorf("falta %s: %w", p, err)
		}
		if info.IsDir() {
			return fmt.Errorf("componente es directorio: %s", p)
		}
	}
	cmd := exec.Command(perl, script)
	cmd.Dir = filepath.Join(root, "bin")
	cmd.Env = os.Environ()
	return cmd.Run()
}
