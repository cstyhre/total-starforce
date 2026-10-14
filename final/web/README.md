# Web playtest

Enkel sida som kör `totalstarforce.prg` i [VirtualC64 Web](https://vc64web.github.io/)-playern.

## Starta lokalt

Från projektroten (kräver Node/npx) eller valfri statisk server:

```bash
npx --yes serve web
```

Öppna URL:en som skrivs ut (t.ex. `http://localhost:3000`).

**Funkar inte med `file://`** — webbläsaren blockerar då laddning av `.prg`.

## Efter ny build i CBM Prg Studio

Kopiera den nya binären till web-mappen:

```powershell
Copy-Item -Force .\totalstarforce.prg .\web\totalstarforce.prg
```

## Styrning

Piltangenter + Space = joystick port 2.

Autostart kör `SYS 2304` (inte `RUN`) eftersom `RUN` ger syntax error på den här PRG:n i VirtualC64 Web.
