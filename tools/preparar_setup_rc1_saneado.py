#!/usr/bin/env python3
"""Prepara un Setup RC1 SANITIZADO PRIVADO sin cambiar el motor ni WebView2.

No publica una release. Verifica SHA del ZIP original, compara cada modulo
modificado con la fuente recuperada y no muestra nunca valores de API.
"""
from __future__ import annotations
import argparse
from hashlib import sha256
from io import BytesIO
import json
from pathlib import Path
import re
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED, BadZipFile

ORIGINAL_SHA256 = "08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4"
PREFIX = "JAVkt9_0.8.1_RC1_PORTABLE/"
MODULES = (
    "GCPlugins/GCTVepisodes/GCThemoviedb.pm",
    "GCPlugins/GCTVseries/GCThemoviedb.pm",
    "GCPlugins/GCfilms/GCThemoviedb.pm",
    "GCPlugins/GCstar/GCThemoviedbCommon.pm",
)
API_LITERAL = re.compile(rb'(my\s+\$apiKey\s*=\s*)(["\x27])([^"\x27]+)(["\x27])')
API_ANY = re.compile(rb'my\s+\$apiKey\s*=\s*(["\x27])([^"\x27]+)\1')
DATE = (2026, 10, 11, 0, 0, 0)
SOURCE_FOLDERS = ("src/perl", "src/JavKT9WebView2", "src/instalador-rc1")
SOURCE_FILES = (
    "LICENSE", "NOTICE.md",
    "tools/preparar_setup_rc1_saneado.py",
    "docs/RESULTADO_REVISION_REDISTRIBUCION_RC1.md",
    "docs/FUENTES_Y_LICENCIAS_PARA_RC_PUBLICA.md",
)

def hash_file(path: Path) -> str:
    h = sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def add(z: ZipFile, name: str, data: bytes) -> None:
    if name.startswith("/") or "\\" in name or ".." in name.split("/"):
        raise ValueError("Ruta ZIP insegura")
    zi = ZipInfo(name, date_time=DATE)
    zi.compress_type = ZIP_DEFLATED
    zi.external_attr = 0o644 << 16
    z.writestr(zi, data, compress_type=ZIP_DEFLATED, compresslevel=6)

def sanitize(original: bytes, recovered: bytes) -> tuple[bytes, bytes]:
    """Sustituye SOLO el literal de API, verifica que no cambia otro byte."""
    matches = list(API_LITERAL.finditer(original))
    if len(matches) != 1:
        raise ValueError("El modulo original no tiene exactamente un literal API")
    match = matches[0]
    if match.group(2) != match.group(4):
        raise ValueError("Comillas API inconsistentes")
    secret = match.group(3)
    if len(secret) < 8:
        raise ValueError("Valor API inesperadamente corto")
    changed = original[:match.start(3)] + original[match.end(3):]
    # La fuente importada a GitHub debe ser IDENTICA salvo el valor retirado.
    if changed != recovered:
        raise ValueError("El modulo recuperado difiere en algo mas que la clave")
    if API_ANY.search(changed):
        raise ValueError("La clave sigue presente despues del saneamiento")
    return changed, secret

def source_zip(repo: Path) -> bytes:
    output = BytesIO()
    with ZipFile(output, "w") as z:
        names = []
        for folder in SOURCE_FOLDERS:
            root = repo / folder
            if not root.is_dir():
                raise ValueError("Faltan fuentes: " + folder)
            names += [p.relative_to(repo).as_posix() for p in root.rglob("*") if p.is_file()]
        names += list(SOURCE_FILES)
        for name in sorted(set(names)):
            add(z, name, (repo / name).read_bytes())
        add(z, "LEEME_FUENTES.txt", (
            "Fuentes recuperadas de JAVkt9 RC1. El codigo del instalador se encuentra "
            "en src/instalador-rc1/main.go y el generador en "
            "tools/preparar_setup_rc1_saneado.py. "
            "NO estan los fuentes originales de los dos lanzadores Go ni "
            "la receta verificada del PAR gcstar.exe. "
            "La redistribucion publica requiere resolver esos puntos y "
            "los avisos de dependencias.\n"
        ).encode("utf-8"))
    return output.getvalue()

def inspect_nested_par(data: bytes, secrets: list[bytes]) -> str:
    """Detecta claves en PAR si el ejecutable permite lectura como ZIP."""
    try:
        with ZipFile(BytesIO(data)) as archive:
            for entry in archive.infolist():
                if entry.is_dir() or entry.file_size > 100 * 1024 * 1024:
                    continue
                contents = archive.read(entry)
                if any(secret in contents for secret in secrets):
                    raise ValueError("Una clave antigua tambien aparece dentro del PAR gcstar.exe")
        return "PAR legible como ZIP: no se hallaron las cuatro claves en entradas extraidas"
    except BadZipFile:
        return "PAR no legible como ZIP: no se puede descartar contenido interno comprimido"

def make_zip(original_zip: Path, repo: Path, output: Path) -> dict:
    if hash_file(original_zip) != ORIGINAL_SHA256:
        raise ValueError("SHA-256 del ZIP RC1 original incorrecto")
    output.parent.mkdir(parents=True, exist_ok=True)
    sources = source_zip(repo)
    secrets = []
    checks = {}
    with ZipFile(original_zip) as src:
        if src.testzip() is not None:
            raise ValueError("CRC del ZIP original incorrecto")
        for mod in MODULES:
            path = "payload/lib/gcstar/" + mod
            recovered = (repo / "src/perl/lib/gcstar" / mod).read_bytes()
            _, secret = sanitize(src.read(path), recovered)
            secrets.append(secret)
        # Antes de generar una nueva version, asegurar que los valores no
        # aparecen en otros archivos del payload, incluido el motor PAR.
        par_result = "No se inspecciono PAR"
        files = [x for x in src.infolist() if not x.is_dir() and x.filename.startswith("payload/")]
        if len(files) < 6000:
            raise ValueError("El payload RC1 no contiene la cantidad de archivos esperada")
        with ZipFile(output, "w", allowZip64=True) as dest:
            for item in files:
                name = item.filename
                rel = name[len("payload/"):]
                if not rel or "\\" in rel or ".." in rel.split("/") or rel.startswith("/"):
                    raise ValueError("Ruta insegura del payload original")
                data = src.read(item)
                if name == "payload/bin/gcstar.exe":
                    par_result = inspect_nested_par(data, secrets)
                if name.startswith("payload/lib/gcstar/") and name[len("payload/lib/gcstar/"):] in MODULES:
                    data, _ = sanitize(data, (repo / "src/perl/lib/gcstar" / name[len("payload/lib/gcstar/"):]).read_bytes())
                    checks[rel] = sha256(data).hexdigest()
                elif any(secret in data for secret in secrets):
                    raise ValueError("Una clave antigua aparece en otro archivo del payload: " + rel)
                add(dest, PREFIX + "payload/" + rel, data)
            add(dest, PREFIX + "FUENTES_RECUPERADAS_RC1.zip", sources)
            add(dest, PREFIX + "LEEME_PRIMERO.txt", (
                "JAVkt9 RC1 — INSTALADOR SANEADO DE DESARROLLO PRIVADO\n"
                "La aplicacion original se conserva salvo cuatro literales antiguos "
                "de TheMovieDB, sustituidos por valores vacios. "
                "El Bridge y WebView2 no fueron modificados.\n"
                "NO PUBLICAR hasta resolver fuentes originales, PAR y licencias de terceros.\n"
            ).encode("utf-8"))
            manifest = {
                "tipo": "RC1 saneada privada; no release publica",
                "zip_original_sha256": ORIGINAL_SHA256,
                "archivos_payload": len(files),
                "modulos_saneados_sha256": checks,
                "fuentes_zip_sha256": sha256(sources).hexdigest(),
                "inspeccion_par": par_result,
            }
            add(dest, PREFIX + "MANIFIESTO_RC1.json",
                (json.dumps(manifest, ensure_ascii=False, indent=2) + "\n").encode("utf-8"))
    with ZipFile(output) as check:
        if check.testzip() is not None:
            raise ValueError("CRC del ZIP saneado incorrecto")
        for mod in MODULES:
            name = PREFIX + "payload/lib/gcstar/" + mod
            if API_ANY.search(check.read(name)):
                raise ValueError("Clave aun presente en ZIP saneado")
    return {
        "zip_saneado_sha256": hash_file(output),
        "zip_saneado_bytes": output.stat().st_size,
        "modulos_saneados": len(MODULES),
        "archivos_payload": len(files),
        "inspeccion_par": par_result,
    }

def make_installer_source(repo: Path, result: dict, path: Path) -> None:
    text = (repo / "src/instalador-rc1/main.go").read_text("utf-8")
    replacements = [
        (r'zipSize int64 = \d+', f'zipSize int64 = {result["zip_saneado_bytes"]}'),
        (r'zipSHA256 = "[a-f0-9]{64}"', f'zipSHA256 = "{result["zip_saneado_sha256"]}"'),
        (r'installFolder = "JAVkt9-081-RC1-Instalada"',
         'installFolder = "JAVkt9-081-RC1-Saneada"'),
        (r'shortcutName = "JAVkt9 0.8.1 RC1 Candidata.lnk"',
         'shortcutName = "JAVkt9 0.8.1 RC1 Saneada.lnk"'),
        (r'JAVkt9-081-RC1-Candidata', 'JAVkt9-081-RC1-Saneada'),
        (r'Paquete original RC1 conservado sin cambios\.',
         'RC1: cuatro claves antiguas retiradas; motor y WebView2 conservados.'),
    ]
    for pattern, repl in replacements:
        text, count = re.subn(pattern, lambda _: repl, text)
        if count != 1:
            raise ValueError("No se pudo ajustar de forma univoca el instalador: " + pattern)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, "utf-8")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--original", type=Path, required=True)
    p.add_argument("--repo", type=Path, default=Path("."))
    p.add_argument("--output-zip", type=Path, required=True)
    p.add_argument("--output-go", type=Path, required=True)
    p.add_argument("--output-report", type=Path, required=True)
    args = p.parse_args()
    result = make_zip(args.original, args.repo, args.output_zip)
    make_installer_source(args.repo, result, args.output_go)
    args.output_report.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print("ZIP PRIVADO saneado y fuente de instalador generados; no se publico release")
    print("Archivos payload:", result["archivos_payload"])
    print("Modulos saneados:", result["modulos_saneados"])
    print("Inspeccion PAR:", result["inspeccion_par"])

if __name__ == "__main__":
    main()
