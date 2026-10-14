#!/usr/bin/env python3
"""
Parse a color-dot PNG into Total Star Force wave tables (64tass .asm).

Layout
------
  • Bottom of image = level start (tick 0); top = later ticks.
  • Horizontal pixel → EnemyStartX (scaled into playfield).
  • One PNG = one level. Concatenate fragments for the full Enemy* tables.

Width (C64)
-----------
  Playfield spawn X is roughly $20–$D0 (32–208). HUD sits on the right.
  Recommended: **32 px wide** (1 pixel ≈ 1 column). Any width works —
  columns are scaled to --xmin/--xmax. Height is free (longer = longer level).

Colors (exact RGB, nearest within --tolerance)
----------------------------------------------
  Red    (255,  0,  0)  → type $01 medium
  Green  (  0,255,  0)  → type $02 kami
  Blue   (  0,  0,255)  → type $03 tank
  Gray   (128,128,128)  → type $04 meteor/asteroid  (also cyan / magenta)
  Yellow (255,255,  0)  → boss marker (not emitted as a spawn)

Usage
-----
  python tools/level-from-png.py refs/levelexample.png -o data/levels/level1.asm
  python tools/level-from-png.py mylevel.png --name L2 --ticks-per-row 2
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Need Pillow: pip install Pillow", file=sys.stderr)
    sys.exit(1)

# Canonical RGB → enemy type (None = boss marker / skip)
COLOR_MAP: list[tuple[tuple[int, int, int], int | None, str]] = [
    ((255, 0, 0), 0x01, "medium"),
    ((0, 255, 0), 0x02, "kami"),
    ((0, 0, 255), 0x03, "tank"),
    ((128, 128, 128), 0x04, "meteor"),
    ((0, 255, 255), 0x04, "meteor"),  # cyan alias
    ((255, 0, 255), 0x04, "meteor"),  # magenta alias
    ((192, 192, 192), 0x04, "meteor"),  # light gray alias
    ((255, 255, 0), None, "boss"),
]

# Background-ish: skip
SKIP_NEAR_WHITE = (250, 250, 250)
SKIP_NEAR_BLACK = (8, 8, 8)

# Defaults matching EnemyLifeByType / typical EnemyColor
LIFE_BY_TYPE = {0x01: 6, 0x02: 3, 0x03: 6, 0x04: 3}
COLOR_BY_TYPE = {0x01: 0x04, 0x02: 0x02, 0x03: 0x08, 0x04: 0x0F}


def dist2(a: tuple[int, int, int], b: tuple[int, int, int]) -> int:
    return (a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2


def classify(
    rgb: tuple[int, int, int], tolerance: int
) -> tuple[int | None, str] | None:
    """Return (type_or_None, name) or None if background."""
    if rgb[0] >= SKIP_NEAR_WHITE[0] and rgb[1] >= SKIP_NEAR_WHITE[1] and rgb[2] >= SKIP_NEAR_WHITE[2]:
        return None
    if rgb[0] <= SKIP_NEAR_BLACK[0] and rgb[1] <= SKIP_NEAR_BLACK[1] and rgb[2] <= SKIP_NEAR_BLACK[2]:
        return None

    tol2 = tolerance * tolerance
    best = None
    best_d = tol2 + 1
    for canon, etype, name in COLOR_MAP:
        d = dist2(rgb, canon)
        if d < best_d:
            best_d = d
            best = (etype, name)
    if best is None or best_d > tol2:
        return None
    return best


def col_to_x(col: int, width: int, xmin: int, xmax: int) -> int:
    if width <= 1:
        return (xmin + xmax) // 2
    return xmin + (col * (xmax - xmin)) // (width - 1)


def row_to_tick(row: int, height: int, ticks_per_row: int) -> int:
    # Bottom row (height-1) → tick 0
    from_bottom = (height - 1) - row
    return from_bottom * ticks_per_row


def parse_image(
    path: Path, tolerance: int, xmin: int, xmax: int, ticks_per_row: int
) -> tuple[list[dict], list[dict], int, int]:
    im = Image.open(path).convert("RGB")
    w, h = im.size
    px = im.load()
    spawns: list[dict] = []
    bosses: list[dict] = []

    for y in range(h):
        for x in range(w):
            hit = classify(px[x, y], tolerance)
            if hit is None:
                continue
            etype, name = hit
            tick = row_to_tick(y, h, ticks_per_row)
            sx = col_to_x(x, w, xmin, xmax) & 0xFF
            entry = {
                "tick": tick,
                "type": etype,
                "x": sx,
                "y": 0,
                "col": x,
                "row": y,
                "name": name,
            }
            if etype is None:
                bosses.append(entry)
            else:
                spawns.append(entry)

    # Stable order: tick asc, then x
    spawns.sort(key=lambda e: (e["tick"], e["x"], e["col"]))
    return spawns, bosses, w, h


def fmt_bytes(vals: list[int], per_line: int = 16) -> str:
    lines = []
    for i in range(0, len(vals), per_line):
        chunk = vals[i : i + per_line]
        lines.append("                        .byte    " + ",".join(f"${v:02x}" for v in chunk))
    return "\n".join(lines)


def emit_asm(
    spawns: list[dict],
    bosses: list[dict],
    name: str,
    width: int,
    height: int,
    xmin: int,
    xmax: int,
    ticks_per_row: int,
    src: str,
) -> str:
    ticks = [e["tick"] for e in spawns]
    types = [e["type"] for e in spawns]
    xs = [e["x"] for e in spawns]
    ys = [e["y"] for e in spawns]
    colors = [COLOR_BY_TYPE[e["type"]] for e in spawns]
    lives = [LIFE_BY_TYPE[e["type"]] for e in spawns]
    n = len(spawns)
    max_tick = max(ticks) if ticks else 0

    counts: dict[str, int] = {}
    for e in spawns:
        counts[e["name"]] = counts.get(e["name"], 0) + 1
    count_str = ", ".join(f"{k}={v}" for k, v in sorted(counts.items()))

    boss_note = ""
    if bosses:
            boss_note = (
            f"; Boss markers (yellow, not spawned): {len(bosses)} - "
            + ", ".join(f"col{b['col']} row{b['row']} tick~{b['tick']}" for b in bosses)
            + "\n"
        )

    warn = ""
    if max_tick > 255:
        warn += f"; WARNING: max tick ${max_tick:x} > $ff — reduce height or --ticks-per-row\n"
    if n > 56:
        warn += f"; WARNING: {n} enemies — game totalEnemies is 56; enlarge tables or shorten level\n"

    return f"""; Auto-generated by tools/level-from-png.py - do not hand-edit lightly
; Source: {src}
; Size: {width}x{height}px  X=${xmin:02x}..${xmax:02x}  ticks/row={ticks_per_row}
; Level label: {name}   count={n}   maxTick=${max_tick:02x}   ({count_str})
{boss_note}{warn};
; WHERE THIS GOES
; ---------------
; The game does NOT read {name}_* labels. Runtime uses these symbols in arrays.asm:
;   EnemyStartTick, EnemyType, EnemyStartX, EnemyStartY, EnemyColor, EnemyLife
; All levels share those flat tables. Each level is a slice:
;   levelEnemyStart = index of first enemy for that level
;   levelEnemyCount = how many enemies (must match the .byte count below = {n})
; Also update totalEnemies in game.asm if the grand total changes.
; Bossrush meteors use a separate slot range (rushAstroSlotFirst) after all levels.
;
; Practical workflow: replace the .byte lines for THIS level's slice inside each
; Enemy* table (keep L2/L3/rush rows), then fix levelEnemyStart/Count.
; Or ask the agent to wire a new export into arrays.asm.
;
{name}_EnemyCount = {n}
; --- copy these .byte rows into the matching Enemy* tables ---
; EnemyStartTick  ({name})
{fmt_bytes(ticks)}
; EnemyType  ({name})
{fmt_bytes(types)}
; EnemyStartX  ({name})
{fmt_bytes(xs)}
; EnemyStartY  ({name})
{fmt_bytes(ys)}
; EnemyColor  ({name})
{fmt_bytes(colors)}
; EnemyLife  ({name})
{fmt_bytes(lives)}
"""


def main() -> int:
    ap = argparse.ArgumentParser(
        description="PNG color-dot level → Total Star Force ASM wave tables",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    ap.add_argument("png", type=Path, help="Level image (RGB)")
    ap.add_argument("-o", "--output", type=Path, help="Write .asm here (default: stdout)")
    ap.add_argument("--name", default="Level", help="Symbol prefix (default: Level)")
    ap.add_argument(
        "--xmin",
        type=lambda s: int(s, 0),
        default=0x20,
        help="Min EnemyStartX (default: $20)",
    )
    ap.add_argument(
        "--xmax",
        type=lambda s: int(s, 0),
        default=0xD0,
        help="Max EnemyStartX (default: $D0)",
    )
    ap.add_argument(
        "--ticks-per-row",
        type=int,
        default=1,
        help="EnemyStartTick step per image row from bottom (default: 1)",
    )
    ap.add_argument(
        "--tolerance",
        type=int,
        default=40,
        help="Max RGB distance to match a palette color (default: 40)",
    )
    ap.add_argument(
        "--max-enemies",
        type=int,
        default=56,
        help="Warn if spawn count exceeds this (default: 56)",
    )
    args = ap.parse_args()

    if not args.png.is_file():
        print(f"File not found: {args.png}", file=sys.stderr)
        return 1

    spawns, bosses, w, h = parse_image(
        args.png, args.tolerance, args.xmin, args.xmax, args.ticks_per_row
    )

    print(
        f"{args.png.name}: {w}x{h} -> {len(spawns)} spawns, {len(bosses)} boss markers",
        file=sys.stderr,
    )
    if w < 8:
        print("Note: very narrow image; X resolution will be coarse.", file=sys.stderr)
    elif w == 32:
        print("Width 32 — good match for playfield columns.", file=sys.stderr)
    elif w == 16:
        print("Width 16 — OK; consider 32 for finer X placement.", file=sys.stderr)
    else:
        print(
            f"Width {w} — scaled to X ${args.xmin:02x}..${args.xmax:02x}. "
            "Recommended canvas width: 32.",
            file=sys.stderr,
        )

    if len(spawns) > args.max_enemies:
        print(
            f"WARNING: {len(spawns)} > max {args.max_enemies} — enlarge totalEnemies or shorten level",
            file=sys.stderr,
        )
    if spawns and max(e["tick"] for e in spawns) > 255:
        print("WARNING: ticks exceed 255 — lower --ticks-per-row or image height", file=sys.stderr)

    asm = emit_asm(
        spawns,
        bosses,
        args.name,
        w,
        h,
        args.xmin,
        args.xmax,
        args.ticks_per_row,
        str(args.png).replace("\\", "/"),
    )

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(asm, encoding="utf-8", newline="\n")
        print(f"Wrote {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(asm)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
