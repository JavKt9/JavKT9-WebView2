#!/usr/bin/env python3
"""Inventario reproducible sin mostrar secretos de la RC1 original.

Uso: python tools/auditar_paquete_rc1.py JAVkt9_0.8.1_RC1_Beta_Publica_Windows.zip
"""
import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
from zipfile import ZipFile

EXPECTED_SHA = "08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4"
MODULES = [
    "payload/lib/gcstar/GCPlugins/GCTVepisodes/GCThemoviedb.pm",
    "payload/lib/gcstar/GCPlugins/GCTVseries/GCThemoviedb.pm",
    "payload/lib/gcstar/GCPlugins/GCfilms/GCThemoviedb.pm",
    "payload/lib/gcstar/GCPlugins/GCstar/GCThemoviedbCommon.pm",
]
PARTS = {
    "Perl y aplicación": "payload/lib/gcstar/",
    "Runtime Perl/GTK": "payload/usr/",
    "Host WebView2 y .NET": "payload/bin/WebView2Host/",
    "Recursos GCstar": "payload/share/gcstar/",
}
NOTICE = re.compile(r"(^|/)(LICENSE|LICENCE|COPYING|NOTICE|AUTHORS)(\.[^/]*)?$", re.I)
API = re.compile(rb"my\s+\$apiKey\s*=\s*([\"'])([^\"']+)\1")

def digest(path):
    h = sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def audit(path):
    actual = digest(path)
    if actual != EXPECTED_SHA:
        raise ValueError("El ZIP no coincide con la RC1 original conocida: " + actual)
    with ZipFile(path) as z:
        entries = [i for i in z.infolist() if not i.is_dir()]
        if z.testzip() is not None:
            raise ValueError("Fallo CRC en el ZIP")
        counts = {}
        for title, prefix in PARTS.items():
            selected = [i for i in entries if i.filename.startswith(prefix)]
            counts[title] = {"archivos": len(selected), "bytes_descomprimidos": sum(i.file_size for i in selected)}
        explicit = [i.filename for i in entries if NOTICE.search(i.filename)]
        flagged = {}
        for name in MODULES:
            data = z.read(name)
            flagged[name] = {
                "asignaciones_apiKey": len(re.findall(rb"my\s+\$apiKey\s*=", data)),
                "valores_literales_no_vacios": len(API.findall(data)),
            }
        return {
            "sha256_zip": actual,
            "archivos_totales": len(entries),
            "secciones": counts,
            "avisos_licencia_explicitos": explicit,
            "modulos_claves_antiguas_sin_mostrar_valores": flagged,
            "conclusion": "Inventario, no certificacion de licencias. Las claves detectadas requieren saneamiento antes de distribuir.",
        }

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("zip_rc1", type=Path)
    args = ap.parse_args()
    print(json.dumps(audit(args.zip_rc1), indent=2, ensure_ascii=False))
