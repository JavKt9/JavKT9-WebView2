package main

import (
	"strings"
	"testing"
	"time"
)

func TestSessionToken(t *testing.T) {
	a, e := newSessionToken()
	if e != nil || len(a) != 48 {
		t.Fatalf("token: %q %v", a, e)
	}
	b, e := newSessionToken()
	if e != nil || a == b {
		t.Fatal("tokens not unique")
	}
}
func TestSetEnv(t *testing.T) {
	x := setEnv([]string{"Path=abc", "FOO=1"}, "PATH", "xyz")
	if len(x) != 2 || envValue(x, "path") != "xyz" {
		t.Fatal(x)
	}
}
func TestShutdownInvalidToken(t *testing.T) {
	if shutdownBridge("x") == nil {
		t.Fatal("accepted invalid token")
	}
}
func TestWaitForPortNoListener(t *testing.T) { waitForPort(10 * time.Millisecond) }
func TestSourceFlag(t *testing.T) {
	if strings.TrimSpace(profile) == "" {
		t.Fatal("empty profile")
	}
}
