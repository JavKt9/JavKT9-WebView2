package main

import (
	"strings"
	"testing"
)

func TestNoUnisolatedProfile(t *testing.T) {
	if err := launch(t.TempDir(), "C:/Users/test/AppData/Local"); err == nil || !strings.Contains(err.Error(), "aislado") {
		t.Fatal(err)
	}
}
func TestMissingBridge(t *testing.T) {
	if err := launch(t.TempDir(), "C:/Users/test/AppData/Local/JavKT9-Publica-Desarrollo"); err == nil {
		t.Fatal("expected missing script")
	}
}
