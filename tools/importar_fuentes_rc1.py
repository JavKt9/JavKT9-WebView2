#!/usr/bin/env python3
"""Importar fuentes RC1 en un repositorio privado, sin ejecutables ni credenciales.

Requiere el ZIP RC1 exacto; modifica SOLO la copia de fuentes destino.
"""
from __future__ import annotations
import hashlib
import io
from pathlib import Path
import re
import sys
import zipfile

EXPECTED_SHA256 = "08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4"
LIB_PREFIX = "payload/lib/gcstar/"
DEST_PREFIX = "src/perl/lib/gcstar/"
EXTRA = {
    "payload/bin/gcstar": "src/perl/bin/gcstar",
    "payload/bin/gcstar.bat": "src/perl/bin/gcstar.bat",
}
REDACT_KEYS = {
    "GCPlugins/GCTVepisodes/GCThemoviedb.pm",
    "GCPlugins/GCTVseries/GCThemoviedb.pm",
    "GCPlugins/GCfilms/GCThemoviedb.pm",
    "GCPlugins/GCstar/GCThemoviedbCommon.pm",
}

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def safe_write(root: Path, rel: str, data: bytes) -> bool:
    rel_path = Path(rel)
    if rel_path.is_absolute() or ".." in rel_path.parts or "\\" in rel or "\x00" in rel:
        raise ValueError(f"Ruta insegura: {rel!r}")
    target = root / rel_path
    if target.exists():
        if target.read_bytes() != data:
            raise ValueError(f"Archivo existente distinto; no sobrescribir: {rel}")
        return False
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    return True

def redact_keys(data: bytes, rel: str) -> bytes:
    if rel not in REDACT_KEYS:
        return data
    data, count = re.subn(
        rb'(?m)(\bmy\s+\$apiKey\s*=\s*")[^"\r\n]+(")',
        rb'\1\2',
        data,
    )
    if count != 1:
        raise ValueError(f"No se pudo retirar la clave esperada: {rel}")
    # Una URL de ejemplo en un comentario tambien contenia una clave.
    data = re.sub(rb'(?i)(api_key=)[a-f0-9]{32}', rb'\1REDACTED', data)
    return data

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
    redacted = set()
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
                    raise SystemExit(f"ERROR: tipo inesperado: {name}")
                data = z.read(entry)
                if rel in REDACT_KEYS:
                    data = redact_keys(data, rel)
                    redacted.add(rel)
                added += safe_write(root, DEST_PREFIX + rel, data)
                seen += 1
            elif name in EXTRA:
                added += safe_write(root, EXTRA[name], z.read(entry))
                seen += 1
        with zipfile.ZipFile(io.BytesIO(z.read("payload/bin/gcstar.exe"))) as par:
            embedded = par.read("script/gcstar.pl")
            added += safe_write(root, "src/perl/par_embebido/script/gcstar.pl", embedded)
            seen += 1
    if seen != 1115 or redacted != REDACT_KEYS:
        raise SystemExit(f"ERROR: fuentes inesperadas ({seen}) o redacciones incompletas ({len(redacted)})")
    print(f"ZIP RC1 verificado. Archivos fuente: {seen}; nuevos: {added}; claves retiradas: {len(redacted)}.")
    print("No se importaron ejecutables, colecciones, perfiles ni datos de navegador.")

if __name__ == "__main__":
    main()
