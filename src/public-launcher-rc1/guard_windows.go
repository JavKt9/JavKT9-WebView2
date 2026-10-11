//go:build windows

package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
)

func cleanupOwnBridge(root string) error {
	script := filepath.Join(root, "BridgePortGuard.ps1")
	if _, err := os.Stat(script); err != nil {
		return fmt.Errorf("falta verificador del Bridge: %w", err)
	}
	cmd := exec.Command("powershell.exe", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", script, "-Root", root)
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
	b, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("no se cerro ningun proceso ajeno (%s): %w", strings.TrimSpace(string(b)), err)
	}
	return nil
}
