// SPDX-License-Identifier: GPL-2.0-or-later
package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestSetEnvCaseInsensitive(t *testing.T) {
	env := []string{"Path=original", "PATH=duplicate", "APPDATA=old", "KEEP=yes"}
	got := setEnv(env, "path", "new")
	if strings.Join(got, "|") != "APPDATA=old|KEEP=yes|path=new" {
		t.Fatalf("unexpected environment: %q", got)
	}
	if envValue(got, "PATH") != "new" { t.Fatal("wrong PATH") }
}

func TestCheckRuntimeRejectsIncompleteDistribution(t *testing.T) {
	root := t.TempDir()
	err := checkRuntime(root)
	if err == nil || !strings.Contains(err.Error(), "gcstar.exe") { t.Fatalf("expected missing exe: %v", err) }
}

func TestCheckRuntimeCompleteStructure(t *testing.T) {
	root := t.TempDir()
	for _, p := range []string{
		"bin/gcstar.exe", "bin/wperl.exe", "usr/bin", "usr/lib", "usr/lib/typelib",
		"usr/lib/schema", "lib/gcstar/GCPlugins/GCfilms/GCJavLibraryBridge.pl",
		"bin/WebView2Host/JavKT9WebView2.exe",
	} {
		full := filepath.Join(root, filepath.FromSlash(p))
		if filepath.Ext(p) != "" {
			if err := os.MkdirAll(filepath.Dir(full), 0755); err != nil { t.Fatal(err) }
			if err := os.WriteFile(full, []byte("test"), 0644); err != nil { t.Fatal(err) }
		} else if err := os.MkdirAll(full, 0755); err != nil { t.Fatal(err) }
	}
	if err := checkRuntime(root); err != nil { t.Fatal(err) }
}

func TestLaunchDoesNotTouchUserProfilesOnMissingRuntime(t *testing.T) {
	root := t.TempDir()
	app := filepath.Join(root, "appdata")
	local := filepath.Join(root, "local")
	if err := launch(root, app, local, []string{"PATH=original"}, nil); err == nil { t.Fatal("expected failure") }
	for _, path := range []string{app, local} {
		if _, err := os.Stat(path); !os.IsNotExist(err) { t.Fatalf("profile unexpectedly created: %s", path) }
	}
}
