#!/usr/bin/env python3
"""Arma SOLO un ZIP portátil PRIVADO de desarrollo a partir de la RC1 verificada.

No instala, no publica releases, no modifica la RC1 original ni el sistema.
No usar para distribución pública hasta revisar licencias y fuentes PAR.
"""
from __future__ import annotations
import argparse
import hashlib
from pathlib import Path, PurePosixPath
import zipfile

RC1_SHA256 = "08fb8ef765e01909225245768d36be7797f4770a6a5d8eb7198d3f6195aadac4"
ROOT = "JAVkt9-Publica-Desarrollo/"
REDACT = {
    "GCPlugins/GCTVepisodes/GCThemoviedb.pm",
    "GCPlugins/GCTVseries/GCThemoviedb.pm",
    "GCPlugins/GCfilms/GCThemoviedb.pm",
    "GCPlugins/GCstar/GCThemoviedbCommon.pm",
}
README = """JAVkt9 - EDICION PUBLICA EN DESARROLLO (VISTA PREVIA PRIVADA)

NO ES UNA RELEASE PUBLICA. NO ES UN INSTALADOR.
No copiar archivos a Program Files ni sobre una instalacion de JAVkt9.

Esta vista previa usa un lanzador Go nuevo con fuentes en src/public-launcher/
y una variante separada del host C# con fuentes en src/public-webview2/.
Conserva el GCstar/PAR y dependencias de la RC1 original, aun pendientes de
verificacion de licencias y receta de compilacion.

Para una futura prueba aislada en Windows, extraer a una carpeta propia y
abrir JavKT9.exe. No ejecutar en paralelo con la RC1: ambas usan el puerto 53118.
La variante WebView2 de desarrollo mantiene su perfil en carpetas separadas.

NO REDISTRIBUIR ESTE ZIP. Falta comprobar funcionamiento integral en Windows.
"""


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def safe_zip_entry(name: str) -> bool:
    p = PurePosixPath(name)
    return name.startswith("payload/") and ".." not in p.parts and "\\" not in name and not p.is_absolute()


def add_file(zout: zipfile.ZipFile, name: str, data: bytes, manifest: list[str]) -> None:
    if not name.startswith(ROOT) or ".." in PurePosixPath(name).parts:
        raise ValueError("Ruta insegura de salida")
    zi = zipfile.ZipInfo(name, date_time=(2026, 10, 10, 0, 0, 0))
    zi.compress_type = zipfile.ZIP_DEFLATED
    zi.external_attr = 0o644 << 16
    zout.writestr(zi, data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=6)
    manifest.append(f"{hashlib.sha256(data).hexdigest()}  {name[len(ROOT):]}")


def assemble(rc1: Path, launcher: Path, host: Path, repo: Path, output: Path) -> None:
    if sha256_file(rc1) != RC1_SHA256:
        raise ValueError("El ZIP RC1 no coincide con el SHA-256 original")
    if not launcher.is_file():
        raise ValueError("Falta el lanzador Go nuevo")
    if not (host / "JavKT9WebView2.exe").is_file():
        raise ValueError("Falta el host WebView2 compilado para la edicion publica")
    host_files = sorted(p for p in host.rglob("*") if p.is_file())
    if not host_files:
        raise ValueError("Directorio del host vacio")
    output.parent.mkdir(parents=True, exist_ok=True)
    manifest: list[str] = []
    count = 0
    with zipfile.ZipFile(rc1) as source, zipfile.ZipFile(output, "w", allowZip64=True) as dest:
        if source.testzip() is not None:
            raise ValueError("ZIP RC1 corrupto")
        for item in source.infolist():
            name = item.filename
            if item.is_dir() or not safe_zip_entry(name):
                continue
            rel = name[len("payload/"):]
            if not rel:
                continue
            # Original Go executables and host are deliberately omitted.
            if rel in {"JavKT9.exe", "bin/GCJavBridgeLauncher.exe"}:
                continue
            if rel.startswith("bin/WebView2Host/"):
                continue
            data = source.read(item)
            prefix = "lib/gcstar/"
            if rel.startswith(prefix) and rel[len(prefix):] in REDACT:
                data = (repo / "src/perl/lib/gcstar" / rel[len(prefix):]).read_bytes()
                if b'my $apiKey = ""' not in data:
                    raise ValueError("Clave heredada no retirada del modulo: " + rel)
            add_file(dest, ROOT + rel, data, manifest)
            count += 1
        add_file(dest, ROOT + "JavKT9.exe", launcher.read_bytes(), manifest)
        for path in host_files:
            rel = path.relative_to(host).as_posix()
            add_file(dest, ROOT + "bin/WebView2Host/" + rel, path.read_bytes(), manifest)
        for name in ("LICENSE", "NOTICE.md"):
            add_file(dest, ROOT + name, (repo / name).read_bytes(), manifest)
        add_file(dest, ROOT + "LEEME_PRIVADO.txt", README.encode("utf-8"), manifest)
        # Manifest excludes its own hash.
        add_file(dest, ROOT + "MANIFIESTO_SHA256.txt", ("\n".join(manifest) + "\n").encode("utf-8"), [])
    print(f"Paquete privado creado: {output}")
    print(f"Entradas de payload conservadas: {count}; archivos WebView2 nuevos: {len(host_files)}")
    print("Excluidos: dos ejecutables Go originales, host WebView2 original e instaladores RC1")
    print("NO PUBLICAR: licencias y receta PAR pendientes.")


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--rc1", type=Path, required=True)
    p.add_argument("--launcher", type=Path, required=True)
    p.add_argument("--host", type=Path, required=True)
    p.add_argument("--repo", type=Path, default=Path("."))
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    assemble(args.rc1, args.launcher, args.host, args.repo, args.output)


if __name__ == "__main__":
    main()
