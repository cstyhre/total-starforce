#!/usr/bin/env python3
"""Wire data/levels/level1.asm into arrays.asm L1 slice (+ keep L2/L3/rush)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
level = (ROOT / "data/levels/level1.asm").read_text(encoding="utf-8")
arrays_path = ROOT / "arrays.asm"
arrays = arrays_path.read_text(encoding="utf-8")


def grab(name: str) -> str:
    m = re.search(
        rf"; {name}  \(L1\)\n((?:                        \.byte.*\n)+)", level
    )
    if not m:
        raise SystemExit(f"missing {name}")
    return m.group(1).rstrip()


def count_bytes(block: str) -> int:
    return len(re.findall(r"\$[0-9a-fA-F]{2}", block))


def full_table(label: str, block: str) -> str:
    lines = block.splitlines()
    first = lines[0].replace("                        .byte", f"{label:<24}.byte", 1)
    rest = "\n".join(lines[1:])
    return first + ("\n" + rest if rest else "")


l1 = {
    n: grab(n)
    for n in (
        "EnemyStartTick",
        "EnemyType",
        "EnemyStartX",
        "EnemyStartY",
        "EnemyColor",
        "EnemyLife",
    )
}
n = count_bytes(l1["EnemyStartTick"])
for name, block in l1.items():
    c = count_bytes(block)
    if c != n:
        raise SystemExit(f"{name} count {c} != {n}")

l2_n, l3_n, rush_n = 16, 16, 8
l2_start = n
l3_start = n + l2_n
rush_start = n + l2_n + l3_n
total = rush_start + rush_n

l2_tick = "                        .byte    $00,$01,$01,$02,$02,$03,$03,$04,$05,$05,$06,$07,$08,$08,$09,$0a"
l2_type = "                        .byte    $02,$03,$02,$01,$02,$03,$02,$01,$02,$03,$02,$01,$02,$03,$02,$01"
l2_x = "                        .byte    $20,$40,$60,$80,$a0,$c0,$38,$58,$78,$98,$b8,$d8,$30,$70,$b0,$50"
l2_y = "                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00"
l2_col = "                        .byte    $02,$08,$02,$04,$02,$08,$02,$04,$02,$08,$02,$04,$02,$08,$02,$04"
l2_life = "                        .byte    $03,$06,$03,$06,$03,$06,$03,$06,$03,$06,$03,$06,$03,$06,$03,$06"

l3_tick = l2_tick
l3_type = "                        .byte    $03,$02,$01,$02,$03,$02,$01,$02,$03,$02,$01,$02,$03,$02,$01,$02"
l3_x = "                        .byte    $28,$48,$68,$88,$a8,$c8,$35,$55,$75,$95,$b5,$d0,$40,$80,$c0,$60"
l3_y = l2_y
l3_col = "                        .byte    $08,$02,$04,$02,$08,$02,$04,$02,$08,$02,$04,$02,$08,$02,$04,$02"
l3_life = "                        .byte    $06,$03,$06,$03,$06,$03,$06,$03,$06,$03,$06,$03,$06,$03,$06,$03"

rush_tick = "                        .byte    $00,$00,$00,$00,$00,$00,$00,$00"
rush_type = "                        .byte    $04,$04,$04,$04,$04,$04,$04,$04"
rush_x = "                        .byte    $18,$28,$10,$38,$20,$30,$14,$40"
rush_y = "                        .byte    $00,$00,$00,$00,$00,$00,$00,$00"
rush_col = "                        .byte    $0f,$0f,$01,$0f,$0f,$01,$0f,$0f"
rush_life = "                        .byte    $03,$03,$03,$03,$03,$03,$03,$03"

new_block = f"""; Wave tables: one flat list, sliced per level via levelEnemyStart/Count.
; L1 = refs/levels/level1.png ({n}). L2/L3 = hand data (16 each).
; Slots {rush_start}..{rush_start + rush_n - 1} = rush-only meteors (not in any level slice).
; Ticks restart per level (levelTickBase).
; --- L1 (0..{n - 1}) from level-from-png ---
{full_table('EnemyStartTick', l1['EnemyStartTick'])}
; --- L2 ({l2_start}..{l3_start - 1}) ---
{l2_tick}
; --- L3 ({l3_start}..{rush_start - 1}) ---
{l3_tick}
; --- rush meteors ({rush_start}..{rush_start + rush_n - 1}) ---
{rush_tick}
{full_table('EnemyType', l1['EnemyType'])}
{l2_type}
{l3_type}
{rush_type}
{full_table('EnemyStartX', l1['EnemyStartX'])}
{l2_x}
{l3_x}
{rush_x}
{full_table('EnemyStartY', l1['EnemyStartY'])}
{l2_y}
{l3_y}
{rush_y}

; Per-level wave slices into tables above (rush slots are outside these)
levelEnemyStart         .byte    0,{l2_start},{l3_start}
levelEnemyCount         .byte    {n},{l2_n},{l3_n}
levelBgColor            .byte    $06,$00,$02    ; blue / black / red
levelBorderColor        .byte    $08,$0b,$0a


EnemyFrameTable         .byte    $85,$86,$87,$88
AstroFrameTable         .byte    $9e,$9f,$a0    ; astro_1_1..3 tumble; astro_2=$a1 static
; Spawn dirs (signed dx): down-right, down-left, steep down, shallow down-left
AstroDirX               .byte    $02,$fe,$00,$fd
AstroDirY               .byte    $03,$03,$04,$02

; HP by type index: 0 unused, 01 medium=6, 02 kami=3, 03 tank=6, 04 astro=3
EnemyLifeByType         .byte    0,6,3,6,3

{full_table('EnemyColor', l1['EnemyColor'])}
{l2_col}
{l3_col}
{rush_col}
; Per-slot life matching EnemyType
{full_table('EnemyLife', l1['EnemyLife'])}
{l2_life}
{l3_life}
{rush_life}
"""

start = arrays.find("; Wave tables: one flat list")
if start < 0:
    raise SystemExit("arrays wave block start not found")
end = arrays.find("explosionTableTopLeft", start)
if end < 0:
    raise SystemExit("arrays wave block end marker not found")
# Keep blank lines before explosion tables
arrays_path.write_text(
    arrays[:start] + new_block + "\n\n" + arrays[end:],
    encoding="utf-8",
    newline="\n",
)
print(f"Wired L1={n} totalEnemies should be {total}; rushAstroSlotFirst={rush_start}")
