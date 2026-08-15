#!/usr/bin/env python3
"""Extract Obsidian's own app.css next to harness.html.

The harness needs to render theme.css *over* Obsidian's stylesheet to be
worth anything — most of the surprises in this theme have come from Obsidian
rules winning on specificity or !important, which you cannot see from
theme.css alone. app.css lives inside obsidian.asar and is Obsidian's
copyright, so it is extracted locally and gitignored, never committed.

Usage:  python3 test/extract-app-css.py [path/to/obsidian.asar]
"""
import json
import pathlib
import struct
import sys

SEARCH = [
    "/var/lib/flatpak/app/md.obsidian.Obsidian/*/*/*/files/resources/obsidian.asar",
    "~/.local/share/flatpak/app/md.obsidian.Obsidian/*/*/*/files/resources/obsidian.asar",
    "/opt/Obsidian/resources/obsidian.asar",
    "/usr/lib/obsidian/resources/obsidian.asar",
    "/snap/obsidian/current/resources/obsidian.asar",
    "/Applications/Obsidian.app/Contents/Resources/obsidian.asar",
]


def find_asar():
    for pattern in SEARCH:
        expanded = pathlib.Path(pattern).expanduser()
        root = pathlib.Path(expanded.anchor)
        try:
            hits = sorted(root.glob(str(expanded.relative_to(root))))
        except (ValueError, OSError):
            continue
        if hits:
            return hits[-1]
    return None


def walk(node, path=""):
    for name, meta in node.get("files", {}).items():
        sub = f"{path}/{name}" if path else name
        if "files" in meta:
            yield from walk(meta, sub)
        else:
            yield sub, meta


def main():
    asar = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else find_asar()
    if not asar or not asar.exists():
        sys.exit(
            "could not find obsidian.asar — pass its path as an argument.\n"
            "It sits in Obsidian's resources/ directory."
        )

    data = asar.read_bytes()
    # asar header: 4-byte pickle size, 4-byte header-string size, 4-byte
    # header size, 4-byte JSON length, then the JSON, padded to 4 bytes.
    jlen = struct.unpack("<IIII", data[:16])[3]
    header = json.loads(data[16 : 16 + jlen].decode("utf-8"))
    base = 16 + jlen
    base += (4 - base % 4) % 4

    here = pathlib.Path(__file__).parent
    found_css = False
    fonts = 0

    for name, meta in walk(header):
        # app.css refers to its fonts as public/fonts/<hash>.woff2, relative to
        # itself — so extracting them to the matching path makes the harness
        # render in Obsidian's bundled Inter. Without them it falls back to a
        # face with no variable weight axis, and every heading weight lies.
        keep = name.endswith("app.css") or (
            "public/fonts/" in name and name.endswith((".woff2", ".ttf"))
        )
        if not keep:
            continue
        # Keep the archive's own layout: app.css sits at the root and its fonts
        # at public/fonts/, which is exactly the relative path it asks for.
        out = here / name
        out.parent.mkdir(parents=True, exist_ok=True)
        off, size = base + int(meta["offset"]), int(meta["size"])
        out.write_bytes(data[off : off + size])
        if name.endswith("app.css"):
            found_css = True
            print(f"{asar}\n  -> {out} ({size:,} bytes)")
        else:
            fonts += 1

    if not found_css:
        sys.exit("no app.css inside that asar")
    print(f"  -> {fonts} font file(s) under {here / 'public/fonts'}")


if __name__ == "__main__":
    main()
