//go:build !windows

package main

import "errors"

func cleanupOwnBridge(root string) error {
	return errors.New("limpieza de Bridge disponible solo en Windows")
}
