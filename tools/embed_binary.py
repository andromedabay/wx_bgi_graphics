#!/usr/bin/env python3
"""Embed a binary file as a C++ byte array."""

from __future__ import annotations

import pathlib
import sys


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: embed_binary.py <input> <output.cpp> <symbol>", file=sys.stderr)
        return 1

    src = pathlib.Path(sys.argv[1])
    dst = pathlib.Path(sys.argv[2])
    symbol = sys.argv[3]

    data = src.read_bytes()
    dst.parent.mkdir(parents=True, exist_ok=True)

    with dst.open("w", encoding="ascii", newline="\n") as fp:
        fp.write("#include <cstddef>\n\n")
        fp.write("namespace bgi::embedded\n{\n")
        fp.write(f"extern const unsigned char {symbol}[] = {{\n")
        for offset in range(0, len(data), 12):
            chunk = ", ".join(f"0x{byte:02X}" for byte in data[offset:offset + 12])
            fp.write(f"    {chunk},\n")
        fp.write("};\n")
        fp.write(f"extern const std::size_t {symbol}Size = sizeof({symbol});\n")
        fp.write("} // namespace bgi::embedded\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
