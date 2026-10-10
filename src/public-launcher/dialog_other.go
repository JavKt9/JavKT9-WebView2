//go:build !windows

// SPDX-License-Identifier: GPL-2.0-or-later
package main

import (
	"fmt"
	"os"
)

func showError(_, message string) { fmt.Fprintln(os.Stderr, message) }
