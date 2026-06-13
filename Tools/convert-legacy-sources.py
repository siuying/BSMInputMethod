#!/usr/bin/env python3
"""One-time conversion of the legacy BIG5 dictionary sources to UTF-8 (ADR 0011).

The legacy Ruby pipeline read BIAU1.TXT as BIG5 and bsm_applet.dat as
BIG5-HKSCS, both with `invalid: :replace, undef: :replace`, so undefined
characters became U+FFFD. Some HKSCS bytes decode to Unicode Private Use Area
characters; Ruby treated those as undefined and replaced them. We reproduce that
behavior here so the database the Swift builder generates matches the committed
bsm.db.

Run from the repository root:
    python3 Tools/convert-legacy-sources.py
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LEGACY = ROOT / "Legacy" / "data"
DATA = ROOT / "Data"

REPLACEMENT = "�"


def replace_pua(text: str) -> str:
    # Private Use Area characters were undefined in Ruby's tables -> U+FFFD.
    return "".join(REPLACEMENT if 0xE000 <= ord(c) <= 0xF8FF else c for c in text)


def convert(src: Path, dst: Path, encoding: str) -> None:
    raw = src.read_bytes()
    text = replace_pua(raw.decode(encoding, errors="replace"))
    dst.write_text(text, encoding="utf-8")
    print(f"{src.name}: {encoding} -> UTF-8 ({len(text)} chars)")


def main() -> int:
    # The legacy Ruby pipeline read BIAU1.TXT as plain BIG5: it decodes the
    # ETen box-drawing characters (so the fixed-width frequency columns line up)
    # but has no HKSCS, so HKSCS-only characters became U+FFFD. cp950 reproduces
    # exactly that behavior. bsm_applet.dat was read as BIG5-HKSCS.
    convert(LEGACY / "BIAU1.TXT", DATA / "BIAU1.TXT", "cp950")
    convert(LEGACY / "bsm_applet.dat", DATA / "bsm_applet.dat", "big5hkscs")
    # extension.txt is authored in UTF-8; copy it through unchanged.
    (DATA / "extension.txt").write_text(
        (LEGACY / "extension.txt").read_text(encoding="utf-8"), encoding="utf-8"
    )
    print("extension.txt: copied (already UTF-8)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
