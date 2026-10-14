# Total Star Force — Implementation Notes

> **Historical document.** Written during development (last updated 2026-09-21), before the itch.io release. Kept here as a snapshot of design intent, phasing, and technical decisions. Some “missing / unfinished” items were completed later (music, SFX, bosses, etc.) — treat this as history, not a status report for the shipped build.

Describes what existed, what was planned, and in what order.
Target: Commodore 64 (6502 ASM). Build: **64tass** (`build.ps1`). Real SID where music appears.

---

## 1. Vision and principles

- Keep C64 limits as part of the game’s identity (8 sprites, 3 SID voices, memory, CPU).
- Ask: *How would a skilled C64 developer solve this?*
- Separate conceptually: **game logic** · **level/boss data** · **music/SFX** · **tools (editors)**.
- Prefer a few finished, playtested phases over many half-done systems.

### Weapons (locked naming + balance)

Runtime IDs in code (`playerWeapon`): **1 / 2 / 3** (not 0-based).

| ID | Name in HUD / game | Code segment | Relative strength |
|----|--------------------|--------------|-------------------|
| 1 | **Bullets** | `InitBullets` / bullet segment | Strongest |
| 2 | **Homing** | `InitHomings` / homing segment | Weakest |
| 3 | **Laser** | `InitThunderBolt` / thunderbolt (piercing) | Middle |

**Level:** `playerWeaponLevel` 1..3 (cap ×3). Separate from damage — damage comes from a table, not by rewriting power every shot.

**Start:** on a new run (title → play) randomize starting weapon **1..3**, always **level ×1**.

**HUD:** e.g. `LASER X 1` … `LASER X 3` (PETSCII in the side panel; same pattern for `BULLETS` / `HOMING`).

**Damage table (v1 baseline, adjustable):**

| Weapon | ×1 | ×2 | ×3 |
|--------|----|----|-----|
| Homing | 1 | 2 | 3 |
| Laser | 2 | 4 | 6 |
| Bullets | 3 | 5 | 6 |

At ×3: Laser and Bullets **oneshot** medium/tank (HP 6). Homing ×3 needs **two hits** on medium/tank (damage 3). Kamikaze (HP 3) dies to homing ×3 in one hit — **kami HP/hits can be tuned later** after playtest.

Laser goes straight through enemies (existing thunderbolt behaviour) — therefore lower damage than bullets despite piercing.

**Score:** per **hit** (not only kills). Points this frame = **damage applied to the enemy** (same value as the damage table / what is added toward `enemyHitPoints`). Stronger weapon / higher level → more score per hit.

---

## 2. Status at the time of writing (short)

### Done / working core

- IRQ + main loop (`MainLoop`, `wait`)
- Player: movement, clamp, sprites, hit, invulnerability timer
- Force + ships (HUD)
- Collision player↔enemy / shot↔enemy
- Enemies: type 01 medium (anim), 02 kamikaze, 03 tank — **HP balance = Phase 2**
- Three weapons: bullets, laser (thunderbolt), homing — **level/HUD/drops = Phase 2**
- Drops, explosions, starfield (Phase 2: weapon drops done; **no Force pickups**)
- HUD: SCORE / FORCE / SHIPS (max 3) + weapon line under ships (`NAME X n`)
- Level cinematic + Get Psyched + crash/respawn (Phases 0–1b)
- Built `totalstarforce.prg` (64tass)

### Missing / unfinished (high level)

- **Phase 2:** done (Force pickup **skipped** — balance difficulty from starting weapon)
- Bosses + Warning banner + pattern data + editor (**Phase 3**)
- Warning PETSCII banner (center-expand) before boss — Get Psyched = blink text
- Audio (music + SFX) — no SID code in the game yet
- Screens: GO clear, scoreboard, credits
- Wave/drop editor (**late**, after data structures)
- Temp/debug left (`Deebug`, `TempDrawBounds`, etc.)

### Memory (orientation)

| Region | Use |
|--------|-----|
| `$0801` / `$0900`… | BASIC stub + game logic (+ `arrays.asm`) |
| ~`$2730`–`$5FFF` | Free gap (~14 KB) — exception: `$4800`–`$4FFF` title PETSCII |
| `$4800` | Title: temporary PETSCII charset (copy from ROM) |
| `$6000` | Sprites (`spritedata.asm`) |
| `$7000` | Charset (`totalchars.bin`) |
| Default GoatTracker export `$1000` | **Collides with game code** — must relocate on export |

---

## 3. Game states

Introduce a clear state (e.g. `gameState`) that the main loop / IRQ respect.

```text
BOOT
  └─ TITLE
       ├─ (fire) ──► LEVEL_ENTER ──► GET_PSYCHED ──► PLAY
       ├─ scoreboard
       └─ credits

PLAY
  ├─ damage / drops / enemies / boss
  ├─ FORCE_CRASH ──► RESPAWN ──► PLAY   (if ships remain)
  ├─ FORCE_CRASH ──► GAMEOVER_DEAD      (if ships = 0)
  ├─ LEVEL_EXIT ──► TRANSITION ──► LEVEL_ENTER ──► GET_PSYCHED ──► PLAY
  ├─ (waves done + 0 enemies) ──► WARNING ──► boss spawn ──► PLAY
  └─ ALL_CLEAR ──► GAMEOVER_CLEAR ──► SCOREBOARD ──► CREDITS/TITLE

GAMEOVER_DEAD ──► SCOREBOARD ──► TITLE
```

Dev-only: from TITLE (or a const) `startAtBoss` can jump into boss mode.

`WARNING` uses a PETSCII banner (center-expand) — see §4.9. `GET_PSYCHED` is blinking text.

---

## 4. Features to implement

### 4.1 Screens

| Screen | Requirements |
|--------|--------------|
| **Title** | PETSCII logo (`petskii/`), fire starts, optional scoreboard/credits; music |
| **Game over (dead)** | At 0 ships; show score; fire → scoreboard/title; music |
| **Game over (clear)** | After final boss rush; victory text; fire continues |
| **Scoreboard** | Highscore list (RAM enough for v1; disk optional later) |
| **Credits** | Short text; back to title |

### 4.2 Level flow

**Count:** 3–4 levels + last = **boss rush**.

**No-damage bonus**

- `tookDamageThisLevel` cleared at level start.
- Set on actual damage (not while invulnerable).
- On level clear: if flag still clear → add bonus to score (constant or per level).

**Level-end cinematic**

1. `LEVEL_EXIT`: input off; ship steered upward until off-screen.
2. `TRANSITION`: short pause / fade / colour change (keep simple).
3. `LEVEL_ENTER`: ship enters **from below**, stops a bit up.
4. `GET_PSYCHED`: blinking text (`DisplayGetPsyched`), then `PLAY`.

**Boss intro (Phase 3)**

After the last wave: wait until **no active enemies** (same condition as level clear), *then*:

`PLAY` → `STATE_WARNING` (banner) → boss spawn / `bossActive` → `PLAY`

Player can steer during Warning; no new enemies/drops. Not the same fly-off as `LEVEL_EXIT`.

**Player jet trail (cinematic)**

There used to be (or was planned) a jet behind the ship; likely dropped for sprite budget. During cinematics the budget is freer — plan for it **already in Phase 1**; gfx can wait for polish.

- Reserve a **fixed sprite index** (suggestion: sprite 1 / `$47f9`) early so weapons/enemies do not “eat” the slot.
- Enable only in `LEVEL_EXIT` / `LEVEL_ENTER` (maybe respawn flight in 1b); **off in PLAY** (`$d015` bit + maybe Y off-screen).
- Position: `playerX` / `playerY` + constant offset (behind = **higher Y** in a vertical shmup); follow `$d010` if X ≥ 256.
- Stub OK without real gfx: pointer + colour + offset logic; swap in sprite data during polish.
- Turn off on state change to PLAY / title / GO so it does not linger.

**Background colour per level**

- Table `levelBgColor` → `$d021` (maybe border `$d020`).
- Must be playtested against starfield + HUD (contrast).

**Wave data**

- Build on tick/enemy tables; make them **per level** (pointers or banks of tables).
- Level clear when: waves done **and** no active enemies (boss separate).

### 4.3 Force, crash, respawn

**Status:** Implemented (`STATE_FORCE_CRASH` → `STATE_RESPAWN` → `PLAY`).

**Current behaviour** (`CheckPlayerIsHit`): force--; at force=0 → crash sequence (no longer immediate ships--/force reset in the same trampoline).

```text
Hit (not invuln)
  → force--
  → tookDamageThisLevel = 1
  → if force > 0: done (maybe short feedback)
  → if force = 0:
        gameState = FORCE_CRASH
        crash animation
        hide ship
        ships--
        if ships underflow → GAMEOVER_DEAD
        else:
          place ship below screen
          force = forceStart (or forceMax)
          invuln + blink
          fly up to start Y
          gameState = PLAY
```

Constants already exist: `forceStart`, `forceMax`, `invulnerableTime`, `shipsStart`.

### 4.4 Enemy types and HP

Three types in waves (`EnemyType` `$01` / `$02` / `$03`).

| Type | Role | Behaviour (short) | HP (v1, adjustable) |
|------|------|-------------------|---------------------|
| **$02** | Weak — **kamikaze** | Align → dive (below) | 3 |
| **$01** | Medium — more sprite frames | Downward + 4-frame anim (`UpdateEnemyType01`) | 6 |
| **$03** | Strong — **tank** | One frame / heavier (`UpdateEnemyType03`) | 6 |

`EnemyLife` should mirror the table (not the same `$18` for all). Damage is compared against `EnemyLife` as today (`UpdateEnemyIsHit`).

#### Type 02 — tracker → kamikaze

**Status:** Implemented (`UpdateEnemyType02`).

```text
PHASE_ALIGN (enemyPhase = 0)
  → Sideways toward player X + slow Y (enemy02AlignSpeedY)
  → When X-overlap with player bounds **and** enemyY >= enemy02KamikazeMinY (~20% down)
    → PHASE_KAMIKAZE
  → Else (X-overlap but too high): hold X, keep drifting down

PHASE_KAMIKAZE (enemyPhase = 1)
  → X locked (enemyMoveX = 0)
  → High speed downward (enemy02DiveSpeed)
```

Constants: `enemy02AlignSpeedY`, `enemy02DiveSpeed`, `enemy02KamikazeMinY`. State: `enemyPhase`.

> **Later (after stable data structures):** PC editor for wave spawn (tick, type, X/Y) **and** which enemies drop power-ups. Hand-edited tables in `arrays.asm` are enough for now — see §6.

### 4.5 Drops / power-ups

**Status:** Phase 2 implemented — weapon drops; Force pickup skipped.

Existing: `drops`, `dropType`, `maxDrops`, `playerWeapon`, `playerWeaponLevel`.

| dropType (= weapon ID) | Colour (color RAM) | Effect |
|------------------------|--------------------|--------|
| 1 Bullets | yellow `$07` (same family as the weapon) | Same weapon → level++; other → switch to bullets, level = 1 |
| 2 Homing | green `$05` | Same / switch by the same rule |
| 3 Laser | cyan `$03` | Same / switch by the same rule |
| Force | — | **Skipped** — no Force pickup; balance difficulty from starting weapon/level |

**Rules (locked)**

1. **Random drop type** on spawn (1..3 via existing RNG) — not cycling the current weapon.
2. **Same weapon as the player** → `playerWeaponLevel++` (cap 3).
3. **Other weapon** → `playerWeapon = dropType`, `playerWeaponLevel = 1`.
4. Drop shown in the **weapon’s colour** (not just the same char).
5. HUD updates on pickup: `NAME X n`.

**Later editor:** which enemy kills drop *at all* (and maybe weights per type) — not in Phase 2; hand table / “all kills drop” OK for now.

### 4.6 Bosses

- 3–4 bosses with **predetermined patterns** (not AI).
- Large bosses via **several sprites in a row** / frame hacks — always account for the **8-sprite budget** (player + shots + enemy shots).
- Last level: **boss rush** (sequence, maybe faster/tougher parameters).
- Boss has HP, phases (optional), own update in PLAY when `bossActive`.
- **Before each boss:** `STATE_WARNING` + PETSCII banner (see §4.9) when the last enemy has left the screen.

**Dev tools**

1. **Pattern editor** (PC): create movement/attack keyframes → export binary/table as `incbin` or generated `.asm`.
2. **`startAtBoss`**: const or title code that jumps to a given boss (skip waves) for fast iteration.

Suggested pattern record (example, can be simplified):

```text
time, x, y, spriteFrame, attackId, flags
```

### 4.7 Audio

**Music**

- GoatTracker 2 (or similar) → **PRG with player**, relocated e.g. to `$2800` / `$3000` (not `$1000`).
- At minimum: title + game over (dead). Then clear/ending and maybe one gameplay tune.
- Calls: `jsr musicInit` once on state change; `jsr musicPlay` every frame/IRQ.

**SFX during gameplay**

Minimum: shot, explosion, player hit, crash, pickup, level clear.
Decide early which SID voice SFX temporarily takes (or a simple dedicated SFX routine).

Real SID playback — not MP3/WAV with an “8-bit filter”.

### 4.8 Score / stats / polish

- Implement `UpdateStats` / `IncreaseScore`: **+damage per hit**; bonuses (no-damage, clear) separate.
- Wire scoreboard to a saved list.
- Player idle animation: `updatePlayerNoMove ; ToDo: Animate back!`
- Clean temp/debug before release feel.
- Ending can be thin: text + music + credits.
- Optional light transitions between game screens (title ↔ play ↔ GO / scoreboard / credits) — fade, wipe, etc.; keep cheap on CPU/memory.
- Player jet trail: real sprite gfx + maybe simple anim (2–3 frames); logic/slot already reserved in cinematic (see §4.2).

### 4.9 PETSCII banner (Warning) + Get Psyched text

**Get Psyched (level intro)** — simple blinking text on the playfield (game charset). Starfield/things may run. PetMate variant (`GetPsyched2`) saved but **unused**.

**Warning! (before boss)** — PetMate banner with **center-expand** (§ Phase 3).

| Banner | When | Form |
|--------|------|------|
| Get Psyched | After `LEVEL_ENTER`, before PLAY | Blink text |
| Warning! | After last enemy off-screen, before boss (`STATE_WARNING`) | PETSCII center-expand |

**Warning — API (suggestion)**

| Routines | Role |
|----------|------|
| `ShowBanner` / `UpdateBanner` / `HideBanner` | Materialize, hold, clear |

**Warning — PetMate / assets**

- Asset: `petskii/Warning2_*.seq` (design on 40×25, art in the mid strip).
- Runtime window: ~**col 0–31**, **3–5+ rows** (Warning2 is taller — OK).
- During PLAY: temporary **ROM charset** (`$4800` / `$d018=$12`) like title, restore `$1c` after.
- Center-expand from the middle; starfield must not poke holes (pause or redraw).

---

## 5. Implementation phases

### Phase 0 — State machine + screens (skeleton)

**Status:** Basics in place — `STATE_TITLE` / `STATE_PLAY` / `STATE_GAMEOVER`.

1. ~~Introduce `gameState` and branch in `MainLoop`~~
2. ~~Title (minimal) → starts PLAY~~ (`EnterTitle` / `StartGame`, fire with edge-detect)
3. ~~Game over → title~~ (`EnterGameOver`, fire → `EnterTitle`)
4. ~~Title PETSCII logo~~ (`petskii/logo_*.seq`, ROM charset → `$4800`, `$d018=$12`; restore `$1c` in `StartGame`)
5. Stubs for clear / scoreboard / credits (later)

**Done when:** start → play → die → back to title works.

### Phase 1 — Level loop + cinematic

**Status:** In place — 3 levels, clear → exit/transition/enter/Get Psyched, bg table, no-damage bonus, jet-slot stub.

1. ~~Level index + wave tables per level~~ (`levelEnemyStart` / `levelEnemyCount`)
2. ~~Level clear detection~~ (`CheckLevelClear`)
3. ~~`LEVEL_EXIT` → `TRANSITION` → `LEVEL_ENTER` → `GET_PSYCHED` → `PLAY`~~ (jet sprite 1 reserved, stub gfx)
4. ~~`tookDamageThisLevel` + no-damage bonus~~
5. ~~`levelBgColor` table + border~~ (contrast playtested)

**Done when:** three levels can be played in sequence with fly-off/on and Get Psyched.

After level 3 → `EnterGameOver` (ALL_CLEAR / scoreboard comes in a later phase).

### Phase 1b — Crash / respawn *(can run in parallel)*

**Status:** In place — `STATE_FORCE_CRASH` / `STATE_RESPAWN`, invuln blink.

1. ~~State `FORCE_CRASH` + animation~~ (explosion + timer, hide ship)
2. ~~Respawn from below + invuln/blink~~ (`respawnInvulnerableTime`, blink in `PositionPlayerSprite`)
3. ~~Wire ships=0 → `GAMEOVER_DEAD`~~ (after crash anim when `ships=$ff`)
4. ~~Damage sets the no-damage flag~~ (already via `tookDamageThisLevel`)

**Done when:** empty force feels like a life lost, not just a HUD glitch.

### Phase 2 — Drops & weapon balance

**Status:** Implemented (2026-09-20).

1. ~~Introduce `playerWeaponLevel` (1..3); damage from table~~
2. ~~Start: **random weapon** 1..3, level ×1~~
3. ~~`EnemyLife` per type: kami 3, medium 6, tank 6~~
4. ~~Random `dropType` 1..3; colour per type; pickup = same→level++ / other→switch + level 1~~
5. ~~HUD: `BULLETS` / `HOMING` / `LASER` + `X` + level~~
6. ~~Score: per hit = damage (`scoreAdd`)~~
7. Force pickup — **skipped** (balance from starting weapon; see §4.5)
8. **Not in Phase 2:** spawn editor / “which enemies drop” — see §4.4 / §6

**Done when:** weapon name×level shows in HUD, drops have correct colour, switch/upgrade works, Homing feels weakest / Bullets strongest / Laser piercing in the middle, and score mirrors damage per hit.

### Phase 3 — Bosses + tools

**In progress:** Three bosses — Warning → fly-in → figure-8 + attack script; editor/rush later.

1. ~~Boss entity + multi-sprite fly-in~~ — boss1 2×2, boss2 3×2, boss3 2×2 (`BossSpriteBase` / `BossOff*`)
2. ~~Warning banner (center-expand)~~ — `Warning2`, ROM charset under banner
3. ~~Boss HP + hits~~ — per-level HP; bullets/homing/laser + player collision (bottom-half-first); clear on death
4. ~~Pattern format + runtime~~ — `PAT_WAIT` / `PAT_VOLLEY` (dx,dy,type) / `PAT_LOOP`; reuse enemy shots
5. Mini-editor (PC) that exports data
6. ~~`startAtBoss`~~ — const `0`=normal, `1..3`=skip waves → that boss
7. Boss-rush level
8. `GAMEOVER_CLEAR` + simple ending

**Done when:** playthrough title → levels → Warning → bosses → rush → clear screen.

### Phase 4 — Audio

1. ~~Relocated GT player included in build~~ — export `$2800` → build relocates to `$5800` (`sid/music.bin`)
2. ~~Title + GO music~~ — same tune; silent during PLAY
3. SFX core + voice policy (weapons×3, explosion, enemy shot)
4. (Later) gameplay/ending tunes if desired

**Done when:** title and death have sound; shots/explosions heard in PLAY.

### Phase 5 — Scoreboard, credits, ship-it

1. Scoreboard + credits finished.
2. `UpdateStats` complete.
3. Clean debug/temp.
4. Optional transition effects between game screens (polish).
5. Player jet-trail gfx (slot/logic from Phase 1).
6. VICE playthrough (PAL or NTSC — pick one).
7. CPU/memory check with music + boss + SFX.
8. (Optional) `.d64`, real hardware.

---

## 6. Data and file layout (proposal)

```text
game.asm              # Core, states, integration
arrays.asm            # Variables / tables (waves, HP, weapon tables)
spritedata.asm        # Sprites
petskii/              # Title logo + Warning banner (GetPsyched2 reserved/unused)
sid/                  # Exported players + sources (.sng etc.)
data/levels/          # (Later) Wave tables per level
data/bosses/          # Pattern binaries / generated asm
tools/boss-editor/    # PC editor → export (Phase 3)
tools/wave-editor/    # (Late) spawn ticks, enemy type, drop flags
implementation/       # This document (historical)
build.ps1             # 64tass → totalstarforce.prg
```

**Build:** `.\build.ps1` (64tass). CBM Prg Studio is no longer required for the PRG.

**Editor order:** first stable runtime fields (weapon level, `EnemyLife`, `dropType`, wave rows) → then wave/drop editor → boss pattern editor. Hand data in `arrays.asm` until then.

---

## 7. Technical checklists

### Sprite budget (reminder)

Max 8 hardware sprites. With a boss: plan multiplex or limit concurrent enemy bullets/homing.

**Jet trail:** reserve a slot (suggestion sprite 1) that is **not** shared with bullets in PLAY. Enable-mask during cinematic ≠ enable-mask during PLAY — document which bits are “owned” by player / jet / weapons / enemies so Phases 2–3 do not overwrite them.

### Music integration

```asm
; On state change to TITLE / PLAY / GO:
lda #tuneId
jsr musicInit        ; former $1000 vector, new address after relocate

; In IRQ (or synced frame):
jsr musicPlay
```

Stop/mute SID on state change (zero `$d400`–`$d418` or player mute).

### Restart / reset

On a new run from title: ticks, enemies, bullets, drops, score (unless highscore submit), force, ships, weapon, **weapon level**, level index, damage flag.

### startAtBoss (dev)

```asm
startAtBoss = 0    ; 0 = normal, 1..n = jump to boss n
```

Or hold fire+direction on title. Remove or hide in release build.

---

## 8. Acceptance criteria for “v1 done”

- [ ] Title → full run → clear **or** dead → scoreboard → title
- [ ] 3 levels with exit/enter + Get Psyched (blink text) + bg colour
- [ ] No-damage bonus works
- [ ] Force=0 gives crash, respawn, or game over dead
- [ ] Drops: random type, correct colour; same weapon → level++ / other → switch + ×1; HUD `NAME X n` (no Force pickups)
- [ ] Damage: Homing weakest, Laser middle (piercing), Bullets strongest; HP kami/medium/tank; ×3 laser/bullets oneshot medium+
- [ ] Warning banner before each boss (after last enemy off-screen)
- [ ] 3 bosses + boss rush
- [ ] Pattern editor can feed at least one boss
- [ ] Wave/drop editor (late) — or hand data enough for v1
- [ ] Title + GO music; basic SFX
- [ ] Credits exist
- [ ] No remaining critical temp hooks on the main path

**Out of v1:** disk highscore, pause, dynamic music, more enemy types, Force pickups, perfect colour palette.

---

## 9. Open decisions (locked recommendations)

| Question | Recommendation |
|----------|----------------|
| Starting weapon | **Random** 1..3, always level ×1 |
| Power/level on weapon switch (other weapon drop) | **Reset to ×1** |
| Same weapon drop | level++ (cap 3) |
| Weapon strength | Homing weakest, Laser middle (piercing), Bullets strongest |
| Enemy HP | Kami 3 / medium 6 / tank 6 — **tune after playtest** |
| Score | Per hit = **damage dealt** |
| Drop type | Random 1..3; colour = weapon colour |
| Force pickup | **No** — balance from starting weapon |
| Boss intro | Warning banner (center-expand) after last enemy off-screen |
| Banner assets | Warning = PetMate (`Warning2`); Get Psyched = blink text (§4.9) |
| Spawn/drop editor | **Late** — after stable data structures |
| Number of levels | 3 + boss rush |
| Number of bosses | 3 (rush = all three) |
| Highscore | RAM list v1 |
| PAL vs NTSC | PAL (unless something else is required) |
| SFX vs music | One voice briefly “stolen” for SFX |

Update this document when decisions change.

---

## 10. Reference: existing code anchors

| Symbol / area | File | Role |
|---------------|------|------|
| `MainLoop` | `game.asm` | Frame logic |
| `irq` | `game.asm` | Set `wait`; future `musicPlay` |
| `Init` / `InitEntities` / `InitThings` | `game.asm` | Restart chain |
| `GameOver` | `game.asm` | Replace with states |
| `DisplayGetPsyched` / `HideGetPsyched` | `game.asm` | Level intro, blink text |
| Warning banner / `STATE_WARNING` | `game.asm` + `petskii/Warning2_*` | Center-expand before boss (§4.9) |
| `CheckLevelClear` / `EnterLevelExit` | `game.asm` | Level loop + cinematic |
| `levelEnemyStart` / `levelBgColor` | `arrays.asm` | Per-level waves + colours |
| `EnableJet` / `PositionJet` | `game.asm` | Sprite 1 stub (polish: gfx) |
| `CheckPlayerIsHit` / `EnterForceCrash` / `EnterRespawn` | `game.asm` | Force empty → crash → respawn / GO |
| `UpdateEnemyType01` / `02` / `03` | `game.asm` | Medium / kamikaze / tank (§4.4) |
| `UpdateTick` / enemy tick | `game.asm` | Wave timing |
| `IncreaseScore` / `UpdateStats` | `game.asm` | Score; Phase 2: +damage per hit |
| `playerWeapon` / (new) `playerWeaponLevel` | `arrays.asm` | Weapon ID 1..3 + level 1..3 |
| `playerWeaponPower` | `arrays.asm` | Legacy/damage per shot — replaced by damage table in Phase 2 |
| `dropType` | `arrays.asm` | Drop = weapon ID 1..3 |
| `EnemyLife` / `EnemyType` | `arrays.asm` | HP per type (kami/medium/tank) |
| `sid/generated-*.prg` | `sid/` | GT2 export (relocate before include) |

---

*Originally last updated: 2026-09-21 — music (GT @ $5800) title/GO; SFX later. English translation archived in `final/implementation/` for the public source release.*
