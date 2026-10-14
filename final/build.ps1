# Build Total Star Force with 64tass
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

# GoatTracker music: relocate into sid/music.bin at $C000 (ZP $AE/$AF).
# $C000 keeps music clear of arrays ($5000+) / boss paths ($5d00) / sprites ($6000).
$gtPrg = Join-Path $root "sid\generated-810277959.prg"
$musicBin = Join-Path $root "sid\music.bin"
$musicLoad = 0xC000
if (-not (Test-Path $gtPrg)) { throw "Missing $gtPrg" }
$bytes = [System.IO.File]::ReadAllBytes($gtPrg)
$srcLoad = [int]$bytes[0] + ([int]$bytes[1] * 256)
$payload = New-Object byte[] ($bytes.Length - 2)
[Array]::Copy($bytes, 2, $payload, 0, $payload.Length)
if ($srcLoad -ne $musicLoad) {
    Write-Host ("WARNING: relocating music ${0:X4} -> ${1:X4} (can corrupt data; re-export GT at `$C000)" -f $srcLoad, $musicLoad)
    $end = $srcLoad + $payload.Length
    $delta = $musicLoad - $srcLoad
    $i = 0
    while ($i -lt $payload.Length - 1) {
        $addr = [int]$payload[$i] + ([int]$payload[$i + 1] * 256)
        if ($addr -ge $srcLoad -and $addr -lt $end) {
            $addr += $delta
            $payload[$i] = $addr -band 0xff
            $payload[$i + 1] = ($addr -shr 8) -band 0xff
            $i += 2
        } else {
            $i += 1
        }
    }
} else {
    Write-Host ("Music already at `${0:X4} - copy as-is (no relocate)" -f $srcLoad)
}
[System.IO.File]::WriteAllBytes($musicBin, $payload)
Write-Host ("Music: `${0:X4} ({1} bytes) -> sid/music.bin" -f $srcLoad, $payload.Length)

$tass = Get-Command 64tass.exe -ErrorAction SilentlyContinue
if (-not $tass) {
    $candidates = @(
        "C:\asm\64tass\64tass.exe",
        "C:\Tools\64tass\64tass.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $tass = $c; break }
    }
}
if (-not $tass) {
    throw "64tass.exe not found in PATH or known install folders."
}

& $tass --cbm-prg --labels=totalstarforce.lbl -o totalstarforce.prg game.asm
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Built totalstarforce.prg + totalstarforce.lbl"

& $tass --cbm-prg --labels=sfxlab.lbl -o sfxlab.prg sfxlab.asm
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Built sfxlab.prg + sfxlab.lbl"
