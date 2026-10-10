#!/usr/bin/env python3
"""Verificación de integridad de las fuentes Perl RC1; solo lectura.

Valida todos los blobs frente al manifiesto Git y comprueba las cuatro
redacciones de claves heredadas, sin imprimir datos sensibles.
"""
from __future__ import annotations
import hashlib
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "manifiestos" / "fuentes-perl-rc1-git.tsv"
REDACTED = (
    "GCPlugins/GCTVepisodes/GCThemoviedb.pm",
    "GCPlugins/GCTVseries/GCThemoviedb.pm",
    "GCPlugins/GCfilms/GCThemoviedb.pm",
    "GCPlugins/GCstar/GCThemoviedbCommon.pm",
)

def git_sha(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()

def main() -> int:
    records = {}
    for line in MANIFEST.read_text(encoding="utf-8").splitlines():
        if not line or line.startswith("#"):
            continue
        try:
            name, size, sha = line.split("\t")
        except ValueError:
            raise ValueError("Línea de manifiesto mal formada") from None
        p = Path(name)
        if p.is_absolute() or ".." in p.parts or "\\" in name or not name.startswith("src/perl/"):
            raise ValueError("Ruta de manifiesto insegura")
        if name in records:
            raise ValueError("Archivo duplicado en el manifiesto")
        records[name] = (int(size), sha)
    if len(records) != 1115:
        raise ValueError(f"Se esperaban 1115 archivos, encontrados {len(records)}")
    actual_paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / "src/perl").rglob("*") if p.is_file()}
    if actual_paths != set(records):
        raise ValueError(f"Diferencias de rutas: faltantes={len(set(records)-actual_paths)}, extra={len(actual_paths-set(records))}")
    for name, (size, sha) in records.items():
        data = (ROOT / name).read_bytes()
        if len(data) != size or git_sha(data) != sha:
            raise ValueError(f"Contenido alterado: {name}")
    for rel in REDACTED:
        p = ROOT / "src/perl/lib/gcstar" / rel
        data = p.read_bytes()
        found = re.findall(rb'\bmy\s+\$apiKey\s*=\s*"([^"\r\n]*)"', data)
        if len(found) != 1 or found[0] != b"":
            raise ValueError("La revisión de claves API heredadas no pasó")
    print(f"OK: {len(records)} archivos Perl coinciden con el manifiesto Git.")
    print("OK: cuatro claves heredadas permanecen vacías.")
    print("Esta comprobación no valida licencias, privacidad ni ejecutables.")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
