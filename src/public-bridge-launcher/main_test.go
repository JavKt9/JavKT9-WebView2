// SPDX-License-Identifier: GPL-2.0-or-later
package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestRejectsUnisolatedProfile(t *testing.T) {
	err := launch(t.TempDir(), "C:/Users/User/AppData/Local")
	if err == nil || !strings.Contains(err.Error(), "aislado") {
		t.Fatalf("expected rejection: %v", err)
	}
}

func TestRejectsMissingInterpreter(t *testing.T) {
	root := t.TempDir()
	script := filepath.Join(root, "lib", "gcstar", "GCPlugins", "GCfilms", "GCJavLibraryBridge.pl")
	if err := os.MkdirAll(filepath.Dir(script), 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(script, []byte("# test"), 0644); err != nil {
		t.Fatal(err)
	}
	err := launch(root, filepath.Join(root, editionMarker))
	if err == nil || !strings.Contains(err.Error(), "wperl.exe") {
		t.Fatalf("expected missing interpreter: %v", err)
	}
}
