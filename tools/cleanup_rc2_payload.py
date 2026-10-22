#!/usr/bin/env python3
"""RC2-only optional Payload cleanup. Dry-run by default; never touch RC1."""
import argparse
from pathlib import Path

# These providers belong to non-film collection types and are not needed by
# JavKT9's film/JavLibrary workflow. Do not remove shared GCstar components.
UNUSED_CATEGORIES = ("GCbooks", "GCcomics", "GCgadgets", "GCgames")

def candidates(payload: Path):
    root = payload / "lib" / "gcstar" / "GCPlugins"
    for category in UNUSED_CATEGORIES:
        folder = root / category
        if folder.is_dir():
            yield from sorted(folder.glob("GCAmazon*.pm"))
    films = root / "GCfilms"
    if films.is_dir():
        yield from sorted(films.glob("*.pm_archive"))

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("payload", type=Path, help="RC2 extracted Payload directory")
    parser.add_argument("--apply", action="store_true", help="Actually delete listed files")
    args = parser.parse_args()
    root = args.payload.resolve()
    if not root.is_dir() or not (root / "lib/gcstar/GCPlugins/GCfilms/GCJavLibrary.pm").is_file():
        parser.error("Not a valid JavKT9 Payload (JavLibrary plugin missing)")
    found = list(candidates(root))
    total = sum(p.stat().st_size for p in found)
    for path in found:
        print(("REMOVE" if args.apply else "WOULD REMOVE") + ": " + str(path.relative_to(root)))
        if args.apply:
            path.unlink()
    print(f"{len(found)} files, {total:,} bytes; " + ("applied" if args.apply else "dry-run only"))
    print("RC2 must still be tested on Windows before distribution.")

if __name__ == "__main__":
    main()
