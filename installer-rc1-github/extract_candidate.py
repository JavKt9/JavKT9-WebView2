#!/usr/bin/env python3
"""Extract the already-uploaded RC1 candidate into an Inno Setup Payload.

No recompilation or patching of the working application is performed.
Input is the existing GitHub draft release EXE (Go stub + appended ZIP).
"""
import argparse
import hashlib
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import zipfile

EXPECTED_EXE_SHA256 = "bb45bce1024598abc9688bc20abedc7083ac3ad103bd470ae619a11640f5ff88"
PREFIX = "JAVkt9_0.8.1_RC1_PORTABLE/payload/"
KEY_PATHS = (
    "lib/gcstar/GCPlugins/GCTVepisodes/GCThemoviedb.pm",
    "lib/gcstar/GCPlugins/GCTVseries/GCThemoviedb.pm",
    "lib/gcstar/GCPlugins/GCfilms/GCThemoviedb.pm",
    "lib/gcstar/GCPlugins/GCstar/GCThemoviedbCommon.pm",
)
REQUIRED = (
    "JavKT9.exe",
    "bin/gcstar.exe",
    "bin/wperl.exe",
    "bin/WebView2Host/JavKT9WebView2.exe",
    "lib/gcstar/GCPlugins/GCfilms/GCJavLibraryBridge.pl",
    "lib/gcstar/GCPanel.pm",
    "lib/gcstar/GCMainWindow.pm",
    "lib/gcstar/GCModels/GCfilms.gcm",
    "BridgePortGuard.ps1",
    "icons/JavKT9-window.png",
)

def extract(exe: Path, output: Path) -> None:
    with exe.open("rb") as input_file:
        digest = hashlib.file_digest(input_file, "sha256").hexdigest()
    if digest != EXPECTED_EXE_SHA256:
        raise ValueError("El EXE de origen no coincide con la candidata RC1 validada: " + digest)
    if output.exists() and any(output.iterdir()):
        raise ValueError("El directorio de destino no esta vacio: " + str(output))
    output.mkdir(parents=True, exist_ok=True)
    seen: set[str] = set()
    count = 0
    total = 0
    with zipfile.ZipFile(exe) as z:
        if len(z.infolist()) != 6221:
            raise ValueError(f"Cantidad de entradas inesperada: {len(z.infolist())}")
        for info in z.infolist():
            if info.is_dir() or not info.filename.startswith(PREFIX):
                continue
            name = info.filename[len(PREFIX):]
            parts = PurePosixPath(name).parts
            if not parts or any(p in (".", "..") for p in parts) or "\\" in name or ":" in name:
                raise ValueError("Ruta insegura: " + name)
            if stat.S_IFMT(info.external_attr >> 16) == stat.S_IFLNK:
                raise ValueError("Enlace simbolico no permitido: " + name)
            key = name.casefold()
            if key in seen:
                raise ValueError("Ruta duplicada: " + name)
            seen.add(key)
            total += info.file_size
            if total > 900 * 1024 * 1024:
                raise ValueError("Payload demasiado grande")
            dest = output.joinpath(*parts)
            dest.parent.mkdir(parents=True, exist_ok=True)
            with z.open(info) as src, dest.open("xb") as dst:
                shutil.copyfileobj(src, dst, length=1024 * 1024)
            count += 1
        bad = z.testzip()
        if bad:
            raise ValueError("Error de integridad ZIP: " + bad)
    if count < 6000:
        raise ValueError("Faltan archivos de la RC1: " + str(count))
    for name in REQUIRED:
        if not (output / name).is_file():
            raise ValueError("Archivo esencial ausente: " + name)
    for name in KEY_PATHS:
        content = (output / name).read_bytes()
        if re.search(rb'my\s+\$apiKey\s*=\s*["\x27][^"\x27]+["\x27]', content):
            raise ValueError("Clave TheMovieDB sin sanear: " + name)
    bridge = (output / REQUIRED[4]).read_text(encoding="utf-8-sig")
    if "JAVKT9_WEBVIEW2_CAPTURE_BASE" not in bridge or "/shutdown" not in bridge:
        raise ValueError("El Bridge no contiene los cambios RC1 aprobados")
    panel = (output / "lib/gcstar/GCPanel.pm").read_text(encoding="utf-8-sig")
    if "JavKT9-expanders.txt" not in panel or "set_fixed_width(36)" not in panel:
        raise ValueError("Faltan ajustes de paneles/favoritos")
    print(f"OK: {count} archivos de payload, {total:,} bytes. RC1 saneada y correcciones conservadas.")

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("exe", type=Path)
    p.add_argument("output", type=Path)
    args = p.parse_args()
    extract(args.exe, args.output)
