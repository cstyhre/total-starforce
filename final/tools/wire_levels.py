#!/usr/bin/env python3
"""Wire data/levels/level{1,2,3}.asm into arrays.asm wave tables (+ rush)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
arrays_path = ROOT / "arrays.asm"
arrays = arrays_path.read_text(encoding="utf-8")

TABLES = (
    "EnemyStartTick",
    "EnemyType",
    "EnemyStartX",
    "EnemyStartY",
    "EnemyColor",
    "EnemyLife",
)


def grab(level_text: str, name: str, label: str) -> str:
    m = re.search(
        rf"; {name}  \({label}\)\n((?:                        \.byte.*\n)+)",
        level_text,
    )
    if not m:
        raise SystemExit(f"missing {name} in {label}")
    return m.group(1).rstrip()


def count_bytes(block: str) -> int:
    return len(re.findall(r"\$[0-9a-fA-F]{2}", block))


def full_table(label: str, block: str) -> str:
    lines = block.splitlines()
    first = lines[0].replace("                        .byte", f"{label:<24}.byte", 1)
    rest = "\n".join(lines[1:])
    return first + ("\n" + rest if rest else "")


def load_level(path: Path, label: str) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    data = {n: grab(text, n, label) for n in TABLES}
    n = count_bytes(data["EnemyStartTick"])
    for name, block in data.items():
        c = count_bytes(block)
        if c != n:
            raise SystemExit(f"{label} {name} count {c} != {n}")
    data["_count"] = n  # type: ignore[assignment]
    return data


l1 = load_level(ROOT / "data/levels/level1.asm", "L1")
l2 = load_level(ROOT / "data/levels/level2.asm", "L2")
l3 = load_level(ROOT / "data/levels/level3.asm", "L3")
n1, n2, n3 = int(l1["_count"]), int(l2["_count"]), int(l3["_count"])  # type: ignore[arg-type]
rush_n = 8
i2, i3 = n1, n1 + n2
rush = n1 + n2 + n3
total = rush + rush_n

rush_tick = "                        .byte    $00,$00,$00,$00,$00,$00,$00,$00"
rush_type = "                        .byte    $04,$04,$04,$04,$04,$04,$04,$04"
rush_x = "                        .byte    $18,$28,$10,$38,$20,$30,$14,$40"
rush_y = "                        .byte    $00,$00,$00,$00,$00,$00,$00,$00"
rush_col = "                        .byte    $0f,$0f,$01,$0f,$0f,$01,$0f,$0f"
rush_life = "                        .byte    $03,$03,$03,$03,$03,$03,$03,$03"


def concat_table(name: str) -> str:
    b1 = full_table(name, l1[name])  # type: ignore[arg-type]
    b2 = l2[name]  # type: ignore[index]
    b3 = l3[name]  # type: ignore[index]
    return f"{b1}\n{b2}\n{b3}"


new_block = f"""; Wave tables: one flat list, sliced per level via levelEnemyStart/Count.
; L1/L2/L3 = refs/levels/level{{1,2,3}}.png ({n1}/{n2}/{n3}).
; Slots {rush}..{rush + rush_n - 1} = rush-only meteors (not in any level slice).
; Ticks restart per level (levelTickBase).
; --- L1 (0..{n1 - 1}) ---
{concat_table('EnemyStartTick').split(chr(10), 1)[0]}
{chr(10).join(concat_table('EnemyStartTick').split(chr(10))[1:])}
; --- L2 ({i2}..{i3 - 1}) / L3 ({i3}..{rush - 1}) included above ---
; --- rush meteors ({rush}..{rush + rush_n - 1}) ---
{rush_tick}
{concat_table('EnemyType')}
{rush_type}
{concat_table('EnemyStartX')}
{rush_x}
{concat_table('EnemyStartY')}
{rush_y}

; Per-level wave slices into tables above (rush slots are outside these)
levelEnemyStart         .byte    0,{i2},{i3}
levelEnemyCount         .byte    {n1},{n2},{n3}
levelBgColor            .byte    $06,$00,$02    ; blue / black / red
levelBorderColor        .byte    $08,$0b,$0a


EnemyFrameTable         .byte    $85,$86,$87,$88
AstroFrameTable         .byte    $9e,$9f,$a0    ; astro_1_1..3 tumble; astro_2=$a1 static
; Spawn dirs (signed dx): down-right, down-left, steep down, shallow down-left
AstroDirX               .byte    $02,$fe,$00,$fd
AstroDirY               .byte    $03,$03,$04,$02

; HP by type index: 0 unused, 01 medium=6, 02 kami=3, 03 tank=6, 04 astro=3
EnemyLifeByType         .byte    0,6,3,6,3

{concat_table('EnemyColor')}
{rush_col}
; Per-slot life matching EnemyType
{concat_table('EnemyLife')}
{rush_life}
"""

# Cleaner construction without the messy StartTick split
new_block = f"""; Wave tables: one flat list, sliced per level via levelEnemyStart/Count.
; L1/L2/L3 = refs/levels/level1.png ({n1}), level2.png ({n2}), level3.png ({n3}).
; Slots {rush}..{rush + rush_n - 1} = rush-only meteors (not in any level slice).
; Ticks restart per level (levelTickBase).
; --- L1 (0..{n1 - 1}), L2 ({i2}..{i3 - 1}), L3 ({i3}..{rush - 1}) ---
{concat_table('EnemyStartTick')}
; --- rush meteors ({rush}..{rush + rush_n - 1}) ---
{rush_tick}
{concat_table('EnemyType')}
{rush_type}
{concat_table('EnemyStartX')}
{rush_x}
{concat_table('EnemyStartY')}
{rush_y}

; Per-level wave slices into tables above (rush slots are outside these)
levelEnemyStart         .byte    0,{i2},{i3}
levelEnemyCount         .byte    {n1},{n2},{n3}
levelBgColor            .byte    $06,$00,$02    ; blue / black / red
levelBorderColor        .byte    $08,$0b,$0a


EnemyFrameTable         .byte    $85,$86,$87,$88
AstroFrameTable         .byte    $9e,$9f,$a0    ; astro_1_1..3 tumble; astro_2=$a1 static
; Spawn dirs (signed dx): down-right, down-left, steep down, shallow down-left
AstroDirX               .byte    $02,$fe,$00,$fd
AstroDirY               .byte    $03,$03,$04,$02

; HP by type index: 0 unused, 01 medium=6, 02 kami=3, 03 tank=6, 04 astro=3
EnemyLifeByType         .byte    0,6,3,6,3

{concat_table('EnemyColor')}
{rush_col}
; Per-slot life matching EnemyType
{concat_table('EnemyLife')}
{rush_life}
"""

start = arrays.find("; Wave tables: one flat list")
if start < 0:
    raise SystemExit("arrays wave block start not found")
end = arrays.find("explosionTableTopLeft", start)
if end < 0:
    raise SystemExit("arrays wave block end marker not found")
arrays_path.write_text(
    arrays[:start] + new_block + "\n\n" + arrays[end:],
    encoding="utf-8",
    newline="\n",
)
print(f"Wired L1={n1} L2={n2} L3={n3} totalEnemies={total} rushAstroSlotFirst={rush}")
