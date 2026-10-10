#!/usr/bin/env python3
"""Importa exclusivamente fuentes Perl de la distribución RC1 verificada.

No modifica ejecutables, instaladores ni carpetas Windows.
Excluye perfiles, colecciones y recursos multimedia de share/gcstar.
"""
from __future__ import annotations
import hashlib
import io
from pathlib import Path
import sys
import zipfile

EXPECTED_SHA256 = "08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4"
LIB_PREFIX = "payload/lib/gcstar/"
DEST_PREFIX = "src/perl/lib/gcstar/"
EXTRA = {
    "payload/bin/gcstar": "src/perl/bin/gcstar",
    "payload/bin/gcstar.bat": "src/perl/bin/gcstar.bat",
}

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def safe_write(root: Path, rel: str, data: bytes) -> bool:
    rel_path = Path(rel)
    if rel_path.is_absolute() or ".." in rel_path.parts or "\\" in rel or "\x00" in rel:
        raise ValueError(f"Ruta insegura: {rel!r}")
    target = root / rel_path
    if target.exists():
        if target.read_bytes() != data:
            raise ValueError(f"Archivo preexistente distinto; no sobrescribir: {rel}")
        return False
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    return True

def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("Uso: python tools/importar_fuentes_rc1.py RC1.zip RAIZ_REPO")
    archive, root = Path(sys.argv[1]), Path(sys.argv[2])
    actual = sha256_file(archive)
    if actual != EXPECTED_SHA256:
        raise SystemExit(f"ERROR: SHA-256 RC1 incorrecto: {actual}")
    root.mkdir(parents=True, exist_ok=True)
    added = 0
    seen = 0
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None:
            raise SystemExit("ERROR: RC1 ZIP corrupto")
        for entry in z.infolist():
            if entry.is_dir():
                continue
            name = entry.filename
            if name.startswith(LIB_PREFIX):
                rel = name[len(LIB_PREFIX):]
                if not rel:
                    continue
                if Path(rel).suffix.lower() not in {".pm", ".pl", ".conf", ".txt", ".gcm", ".png", ".pm_archive"} and Path(rel).name not in {"GCstar", "README"}:
                    raise SystemExit(f"ERROR: tipo de archivo inesperado: {name}")
                added += safe_write(root, DEST_PREFIX + rel, z.read(entry))
                seen += 1
            elif name in EXTRA:
                added += safe_write(root, EXTRA[name], z.read(entry))
                seen += 1
        with zipfile.ZipFile(io.BytesIO(z.read("payload/bin/gcstar.exe"))) as par:
            embedded = par.read("script/gcstar.pl")
            added += safe_write(root, "src/perl/par_embebido/script/gcstar.pl", embedded)
            seen += 1
    if seen != 1115:
        raise SystemExit(f"ERROR: número de fuentes inesperado: {seen} (esperado 1115)")
    print(f"Verificado SHA-256 de RC1. Fuentes revisadas: {seen}; incorporadas: {added}.")
    print("No se importaron ejecutables, perfiles, colecciones ni recursos de share/gcstar.")

if __name__ == "__main__":
    main()
