//go:build !windows

package main

import (
	"fmt"
	"os"
)

func showError(_, msg string) { fmt.Fprintln(os.Stderr, msg) }
