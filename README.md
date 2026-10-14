# Total Star Force (Commodore 64)

A free C64 space shooter. Pilot a star fighter through three stages of alien fleets, meteors, and bosses.

**Play the game:** [https://csdos.itch.io/total-starforce](https://csdos.itch.io/total-starforce)

---

## What's in this repository

Source only — no build binaries — in two folders:

| Folder | What it is |
|--------|------------|
| [`original/`](original/) | The 2018 base game — written by hand, no AI |
| [`final/`](final/) | The 2026 release source — finished with AI assistance (Cursor) |

The itch.io build matches **`final/`**.

`original/` is a historical snapshot from before the 2026 finish pass. Use **`final/`** if you want to rebuild the published game.

---

## Building (`final/`)

Requirements:

- [64tass](https://sourceforge.net/projects/tass64/) on `PATH` (or in a known install folder used by `build.ps1`)
- PowerShell (Windows), or adapt `build.ps1`
- [VICE](https://vice-emu.sourceforge.io/) (or another C64 emulator) to run the result

```powershell
cd final
.\build.ps1
```

This produces `totalstarforce.prg` (and `sfxlab.prg`). Load the game PRG in VICE.

Controls: keyboard or joystick (port 2).

---

## Project history

- **2018** — Core game programmed in CBM prg Studio
- **2026** — Migrated / finished for release with VS Code + 64tass, with AI-assisted coding and some AI-assisted graphics

Theme inspired by the announcement of a U.S. Space Force.

---

## Tools & resources

- Commodore 64 Programmer's Reference Guide
- CBM prg Studio; later VS Code with 64tass
- VICE
- Paint
- Petsciiator (web)
- ChatGPT Images (some graphics)

Special thanks to Ingvar.

---

## License

Source code is released under the [MIT License](LICENSE).
