; 10 SYS (2304)

*=$0801

        .byte    $0E, $08, $0A, $00, $9E, $20, $28
        .byte    $32, $33, $30, $34, $29, $00, $00, $00

wait .fill 1
modulus .fill 1
rng24 .fill 1
rng30 .fill 1
tickHalt .fill 1
ticks .fill 1
tickCounter .fill 1

tmp1 =$fb
tmp2 =$fc
warnSrc1 =$fd
warnSrc2 =$fe
credSrc1 =$f7                ; credits draw source (ZP for ,Y)
credSrc2 =$f8
tmp3 .fill 1
tmpColor1 .fill 1
tmpColor2 .fill 1

testTick .fill 1
testDir .fill 1
gameState .fill 1
fireArmed .fill 1
menuIndex .fill 1               ; title: 0=Start Game, 1=Credits
menuJoyArmed .fill 1            ; edge for joy up/down on title
levelIndex .fill 1
levelEnemyEnd .fill 1
levelTickBase .fill 1
tookDamageThisLevel .fill 1
cinematicTimer .fill 1
jetAnimFrame .fill 1
jetAnimCounter .fill 1
musicEnabled .fill 1
sfxTimer .fill 1
sfxFreqL .fill 1
sfxFreqH .fill 1
sfxSweep .fill 1
sfxWobble .fill 1
sfxThresh .fill 1
inBossRush .fill 1
rushBossIndex .fill 1
rushMeteorTimer .fill 1
rushSpawnCounter .fill 1
hiscoreMade .fill 1
hiscoreInsert .fill 1
godMode .fill 1                   ; 1 = invincible (toggle with P)
godKeyArmed .fill 1
godModeUsed .fill 1               ; sticky: scored voided after any god use
dropKillCount .fill 1             ; non-meteor kills toward next drop
weaponDecayCount .fill 1          ; kills toward weapon level decay
extraLifeAwarded .fill 1          ; 1 = already got 10000-point ship

; GoatTracker player (relocated to $C000 by build.ps1; ZP $AE/$AF)
musicInit = $c000
musicPlay = $c003
musicTune = 0                   ; single song for title / GO / credits

; SID voice 3 for gameplay SFX (music silent in PLAY)
sfxVoiceFreqL = $d40e
sfxVoiceFreqH = $d40f
sfxVoicePwL = $d410
sfxVoicePwH = $d411
sfxVoiceWave = $d412
sfxVoiceAD = $d413
sfxVoiceSR = $d414
sfxVolume = $d418

; Game states
STATE_TITLE = 0
STATE_PLAY = 1
STATE_GAMEOVER = 2
STATE_LEVEL_EXIT = 3
STATE_TRANSITION = 4
STATE_LEVEL_ENTER = 5
STATE_GET_PSYCHED = 6
STATE_LEVEL_CLEARING = 7
STATE_FORCE_CRASH = 8
STATE_RESPAWN = 9
STATE_CREDITS = 10

; Title menu (PETSCII screen): bullet cursor + two choices
titleMenuCursorChar = $51       ; ● (graphics ball ≈ bullet)
titleMenuRow0 = 21
titleMenuRow1 = 22
titleMenuColCursor = 14
titleMenuColText = 16

; Consts
tickDelayTime = 32
shipsMax = 03
shipsStart = 03
forceStart = 06
forceMax = 06
invulnerableTime = 40
respawnInvulnerableTime = 80
crashFrames = 48
playerFrameTime = 04
playerFrameMin = 01
playerFrameMax = 05
playerFrameCenter = 03

playerXMin = 20
playerXMax = 250
playerYMin = 52
playerYMax = 233

maxLevels = 3
rushBossCount = 3
; Rush meteor interlude (frames @ ~50Hz); dedicated slots after L1–L3
rushMeteorFrames = 160
rushMeteorSpawnEvery = 18
; Dedicated asteroid pool after all level slices (not part of wave data)
rushAstroSlotFirst = 216
rushAstroSlotCount = 8
; Enter/Get Psyched: max ~30% up from bottom of playfield
playerEnterY = 179
playerExitY = 20
cinematicMoveSpeed = 3
transitionFrames = 48
getPsychedFrames = 72
bossClearDelayFrames = 50      ; ~1s pause after boss before fly-out (free sprite lines)
getPsychedBlinkMask = $08          ; bit 3 → ~8 frames on / 8 off
noDamageBonusHits = 5
jetYOffset = 18
jetAnimSpeed = 4
maxWeaponLevel = 3
jetColor = $03                ; cyan (sprite-egen färg via $d028)

; Boss — per level: 0=2x2 ($90), 1=3x2 ($94), 2=2x2 ($9a)
BOSS_STATE_OFF = 0
BOSS_STATE_WARNING = 1
BOSS_STATE_ENTER = 2
BOSS_STATE_IDLE = 3
BOSS_STATE_DONE = 4
bossTileW = 24
bossTileH = 21
maxBossParts = 6
bossStartY = $00
bossEnterSpeed = 2
; Path speed: add to 8-bit frac each frame; overflow → next of 64 table steps.
; Smooth lerp between steps. Lap ≈ 64*256/bossPathSpeed/50 sec (PAL).
; $80≈2.5s  $40≈5s  $20≈10s  $10≈20s
bossPathSpeed = $20

; Dev playtest (remove / set 0 before release):
;   startAtBoss 0 = normal, 1..3 = skip waves → that boss (also after L3 → rush)
;   P key toggles godMode (invincible) during play
startAtBoss = 0
; (P scanned via CIA in PollGodMode — not $cb)

; Boss attack script opcodes (editor-friendly; dx/dy = signed velocity)
PAT_WAIT = 1            ; .byte PAT_WAIT, frames
PAT_VOLLEY = 2          ; .byte PAT_VOLLEY, count, then count×(dx,dy,type)
PAT_LOOP = 3            ; restart script for this boss

; Shot spawn: bossX/Y + BossShotOriginX/Y (per-boss center in data)

; Warning banner (PetMate Warning2, center-expand)
warningRowFirst = 8
warningRowLast = 20
warningCenterCol = 16
warningMaxExpand = 16           ; covers cols 0–31
warningHoldFrames = 48
warningExpandFrames = 17        ; radius 0..16
warningBgColor = $01            ; white — asset designed for this (black glyphs)

maxStars = 08

maxBullets = 4
thunderBoltCoolDownTime = $0d
playerWeaponXOffset = 16
playerWeaponYOffset = 44
bulletSpeed = 08
homingSpeed = 04
fireDelayTime = 10
thunderBoltDelayTime = 30

enemyWidth= 28
enemyHeight= 48

maxActiveEnemies = 6
totalEnemies = 224             ; L1=55 + L2=77 + L3=84 + 8 rush meteors

maxEnemyWeapons = 16

maxDrops = 01                  ; only one powerup on screen
dropEveryKills = 05            ; spawn after this many non-meteor kills
dropCycleFrames = 50           ; 1s @50Hz per weapon
dropMaxCycles = 06             ; 6s total life (6 × 1s periods)
weaponDecayKills = 25          ; after this many kills, level-- if >1x

explosionFrameMax = 06
explosionFrameTime = 06
explosionXOffset = 20
explosionYOffset = 42
maxExplosions = 08

; Enemy type 02 (tracker): align then kamikaze dive
enemy02AlignSpeedY = 01
enemy02DiveSpeed = 06
enemy02KamikazeMinY = 47   ; ~20% ner i bild (av ~playerYMax) innan dyk

; Enemy type 04 (asteroid): random diagonal (L/R/down); tumble or static
astroAnimSpeed = 05
astroAnimFrames = 03
astroFrameStatic = $a1         ; astro_2 (no tumble)
astroXDespawnL = $10           ; left leave
astroXDespawnR = $f0           ; right leave


;#######################################;
DrawStraightCol .macro xpos, char, color
        ldx     \xpos
        lda     \char     
        sta     $4400,x
        sta     $4428,x
        sta     $4450,x
        sta     $4478,x
        sta     $44a0,x
        sta     $44c8,x
        sta     $44f0,x
        sta     $4518,x
        sta     $4540,x
        sta     $4568,x
        sta     $4590,x
        sta     $45b8,x
        sta     $45e0,x
        sta     $4608,x
        sta     $4630,x
        sta     $4658,x
        sta     $4680,x
        sta     $46a8,x
        sta     $46d0,x
        sta     $46f8,x
        sta     $4720,x
        sta     $4748,x
        sta     $4770,x
        sta     $4798,x
        sta     $47c0,x

        ;Color
        lda     \color
        sta     55296,x
        sta     55336,x
        sta     55376,x
        sta     55416,x
        sta     55456,x
        sta     55496,x
        sta     55536,x
        sta     55576,x
        sta     55616,x
        sta     55656,x
        sta     55696,x
        sta     55736,x
        sta     55776,x
        sta     55816,x
        sta     55856,x
        sta     55896,x
        sta     55936,x
        sta     55976,x
        sta     56016,x
        sta     56056,x
        sta     56096,x
        sta     56136,x
        sta     56176,x
        sta     56216,x
        sta     56256,x
.endm

*=$0900
        
; Switch to VIC-2 bank 2
        lda     #%00000010
        sta     $DD00
; Set charset
        lda     #$1c
        sta     $d018
; Init IRQ
        sei
        lda     #$7f
        sta     $dc0d
        sta     $dd0d
        lda     #$01
        sta     $d01a

        lda     #<irq
        ldx     #>irq
        sta     $0314
        stx     $0315

        ldy     #$00
        sty     $d012

        lda     $dc0d
        lda     $dd0d
        asl     $d019
        cli

        jsr     EnterTitle

MainLoop

        ldx     wait
        cpx     #$00
        bne     MainLoop
        ldx     #$01
        stx     wait

        jsr     MusicUpdate
        jsr     SfxUpdate
        jsr     PollGodMode             ; DEV: P toggles invincibility

        lda     gameState
        cmp     #STATE_TITLE
        beq     mainLoopTitle
        cmp     #STATE_GAMEOVER
        beq     mainLoopGameOver
        cmp     #STATE_LEVEL_EXIT
        beq     mainLoopLevelExit
        cmp     #STATE_TRANSITION
        beq     mainLoopTransition
        cmp     #STATE_LEVEL_ENTER
        beq     mainLoopLevelEnter
        cmp     #STATE_GET_PSYCHED
        beq     mainLoopGetPsyched
        cmp     #STATE_LEVEL_CLEARING
        beq     mainLoopLevelClearing
        cmp     #STATE_FORCE_CRASH
        beq     mainLoopForceCrash
        cmp     #STATE_RESPAWN
        beq     mainLoopRespawn
        cmp     #STATE_CREDITS
        beq     mainLoopCredits

        ; --- PLAY ---
        jsr     UpdateEntities
        jsr     UpdateStats

        lda     testDir
        cmp     #07
        bcc     dontResetTestDir
        ldx     #$00
        stx     testDir
dontResetTestDir
endTemp
        jsr     UpdateModulus
        jsr     UpdateTick
        jsr     CheckLevelClear
        jsr     UpdateBossRush
        jmp     MainLoop

mainLoopTitle
        jsr     UpdateTitle
        jmp     MainLoop

mainLoopCredits
        jsr     UpdateCredits
        jmp     MainLoop

mainLoopGameOver
        jsr     UpdateGameOver
        jmp     MainLoop

mainLoopLevelExit
        jsr     UpdateLevelExit
        jmp     MainLoop

mainLoopTransition
        jsr     UpdateTransition
        jmp     MainLoop

mainLoopLevelEnter
        jsr     UpdateLevelEnter
        jmp     MainLoop

mainLoopGetPsyched
        jsr     UpdateGetPsyched
        jmp     MainLoop

mainLoopLevelClearing
        jsr     UpdateLevelClearing
        jmp     MainLoop

mainLoopForceCrash
        jsr     UpdateForceCrash
        jmp     MainLoop

mainLoopRespawn
        jsr     UpdateRespawn
        jmp     MainLoop

;
;
;       GAME STATES
;
;

EnterTitle
        lda     #STATE_TITLE
        sta     gameState
        lda     #$00
        sta     fireArmed
        sta     menuIndex           ; default: Start Game
        sta     $d015               ; sprites off
        lda     #$01
        sta     menuJoyArmed
        jsr     DisableJet
        lda     #$00                ; black border/bg (logo_bgcolor)
        sta     $d020
        sta     $d021
        jsr     CopyPetsciiCharset  ; ROM chars → $4800 (bank 1 has no char ROM)
        lda     #$12                ; screen $4400, charset $4800
        sta     $d018
        jsr     DrawTitleScreen
        jsr     MusicStart
        rts

EnterCredits
        lda     #STATE_CREDITS
        sta     gameState
        lda     #$00
        sta     fireArmed
        sta     $d015
        jsr     DisableJet
        lda     #$00
        sta     $d020
        sta     $d021
        lda     #$12                ; keep PETSCII charset
        sta     $d018
        jsr     ClearScreen
        jsr     DrawCreditsScreen
        rts

StartGame
        jsr     MusicStop
        lda     #$1c                ; restore game charset $7000
        sta     $d018
        lda     #$00
        sta     fireArmed
        ; startAtBoss 1..3 → begin at that level (0-based index)
        lda     #startAtBoss
        beq     startGameLevel0
        sec
        sbc     #$01
        sta     levelIndex
        jmp     startGameGo
startGameLevel0
        lda     #$00
        sta     levelIndex
startGameGo
        lda     #$00
        sta     inBossRush
        sta     rushBossIndex
        sta     rushMeteorTimer
        sta     rushSpawnCounter
        sta     godMode
        sta     godModeUsed
        lda     #$01
        sta     godKeyArmed
        jsr     Init
        jsr     EnterLevelEnter
        rts

EnterGameOver
        lda     #STATE_GAMEOVER
        sta     gameState
        lda     #$00
        sta     fireArmed
        sta     $d015               ; sprites off
        jsr     DisableJet
        lda     #$1c                ; game charset
        sta     $d018
        jsr     SubmitHiscore
        jsr     ClearScreen
        jsr     ColorizeScreen
        jsr     DrawGameOverScreen
        jsr     MusicStart
        rts

UpdateTitle
        jsr     PollTitleMenuJoy
        jsr     DrawTitleMenuCursor
        jsr     PollFireArm
        beq     endUpdateTitle      ; Z=1 → not armed+pressed
        lda     menuIndex
        bne     titleSelectCredits
        jsr     StartGame
        rts
titleSelectCredits
        jsr     EnterCredits
endUpdateTitle
        rts

UpdateCredits
        jsr     PollFireArm
        beq     endUpdateCredits
        jsr     EnterTitle
endUpdateCredits
        rts

UpdateGameOver
        jsr     PollFireArm
        beq     endUpdateGameOver
        jsr     EnterTitle
endUpdateGameOver
        rts

; Joy up/down edge → toggle menuIndex (0/1)
PollTitleMenuJoy
        lda     $dc00
        and     #$03                ; bit0=up, bit1=down (0=pressed)
        cmp     #$03
        beq     titleMenuJoyIdle
        lda     menuJoyArmed
        beq     endPollTitleMenuJoy
        lda     #$00
        sta     menuJoyArmed
        lda     $dc00
        and     #$01                ; up?
        beq     titleMenuSelect0
        lda     $dc00
        and     #$02                ; down?
        beq     titleMenuSelect1
        rts
titleMenuSelect0
        lda     #$00
        sta     menuIndex
        rts
titleMenuSelect1
        lda     #$01
        sta     menuIndex
        rts
titleMenuJoyIdle
        lda     #$01
        sta     menuJoyArmed
endPollTitleMenuJoy
        rts

;
;
;       LEVEL FLOW / CINEMATIC
;
;

ApplyLevelBackground
        ldx     levelIndex
        lda     levelBgColor,x
        sta     $d021
        lda     levelBorderColor,x
        sta     $d020
        jsr     UpdateGodModeHud        ; CHEAT label / invuln border
        rts

SetupLevel
        jsr     InitEnemies
        ldx     levelIndex
        lda     levelEnemyStart,x
        sta     enemyTickPointer
        tay
        lda     EnemyStartTick,y    ; ticks relative to first enemy in level
        sta     levelTickBase
        tya
        clc
        adc     levelEnemyCount,x
        sta     levelEnemyEnd
        lda     #$00
        sta     ticks
        sta     tickHalt
        sta     tookDamageThisLevel
        jsr     InitBoss
        ; Dev skip: startAtBoss matching this level → wave pointer at end
        lda     #startAtBoss
        beq     setupLevelTickReady
        sec
        sbc     #$01
        cmp     levelIndex
        bne     setupLevelTickReady
        lda     levelEnemyEnd
        sta     enemyTickPointer
setupLevelTickReady
        lda     #tickDelayTime      ; first tick ASAP after PLAY
        sta     tickCounter
        jsr     ApplyLevelBackground
        rts

EnterLevelEnter
        lda     #STATE_LEVEL_ENTER
        sta     gameState
        jsr     SetupLevel
        lda     #$80
        sta     playerX
        lda     #playerYMax
        sta     playerY
        lda     $d015
        ora     #%00000001          ; player sprite on
        sta     $d015
        jsr     PositionPlayerSprite
        jsr     EnableJet
        jsr     PositionJet
        rts

EnterLevelClearing
        lda     #STATE_LEVEL_CLEARING
        sta     gameState
        lda     #$01
        sta     tickHalt            ; no new spawns
        lda     #$00
        sta     shouldFirePlayerWeapon
        lda     #bossClearDelayFrames
        sta     cinematicTimer      ; hold before fly-out
        ; Drop boss sprite enables (slots 2–7) so player isn't stolen on shared rasters
        lda     $d015
        and     #%00000011          ; keep player (+ jet if on)
        sta     $d015
        rts

EnterLevelExit
        jsr     TryNoDamageBonus
        jsr     ClearDrops          ; remove leftover power-ups on fly-out
        jsr     HideBoss
        lda     #STATE_LEVEL_EXIT
        sta     gameState
        lda     #$01
        sta     tickHalt
        jsr     EnableJet
        jsr     PositionJet
        rts

EnterTransition
        jsr     DisableJet
        lda     #STATE_TRANSITION
        sta     gameState
        lda     #transitionFrames
        sta     cinematicTimer
        lda     #$00
        sta     $d001               ; hide player
        rts

EnterGetPsyched
        jsr     DisableJet
        lda     #STATE_GET_PSYCHED
        sta     gameState
        lda     #getPsychedFrames
        sta     cinematicTimer
        jsr     DisplayGetPsyched
        rts

EnterPlay
        jsr     DisableJet
        jsr     HideGetPsyched
        ; Re-enable enemy sprite slots (cleared after boss via $d015 mask)
        lda     #%11111101          ; player on, jet off, slots 2–7 on
        sta     $d015
        lda     #STATE_PLAY
        sta     gameState
        jsr     ApplyLevelBackground
        rts

;
;
;       FORCE CRASH / RESPAWN (Fas 1b)
;
;

EnterForceCrash
        ; Double KO: boss already won — don't overwrite LEVEL_CLEARING (levels + rush)
        lda     bossState
        cmp     #BOSS_STATE_DONE
        beq     endEnterForceCrash
        lda     gameState
        cmp     #STATE_LEVEL_CLEARING
        beq     endEnterForceCrash

        lda     #STATE_FORCE_CRASH
        sta     gameState
        lda     #crashFrames
        sta     cinematicTimer
        jsr     SfxPlayCrash
        jsr     DisableJet
        lda     $d015
        and     #%11111110          ; hide player sprite
        sta     $d015
        lda     #$00
        sta     $d001
        sta     shouldFirePlayerWeapon
        ; Unstick fire if death ate the shot before ActivatePlayerWeapon
        lda     #$01
        sta     canFire
        lda     #fireDelayTime
        sta     fireDelay
        lda     ships
        sec
        sbc     #$01
        sta     ships
        jsr     UpdateHudShips
        ; Reset weapon level on life lost
        lda     #$01
        sta     playerWeaponLevel
        jsr     RefreshWeaponPower
        jsr     RestorePlayerSpriteColors
        jsr     UpdateHudWeapon
endEnterForceCrash
        rts

UpdateForceCrash
        jsr     UpdateEnemies
        jsr     UpdateThings
        jsr     UpdatePlayerWeaponFrame
        jsr     UpdatePlayerWeapon
        jsr     DrawPlayerWeapon
        jsr     UpdateModulus
        jsr     UpdateTick
        ldx     cinematicTimer
        dex
        stx     cinematicTimer
        bne     endUpdateForceCrash
        lda     ships
        cmp     #$ff
        bne     forceCrashRespawn
        jsr     EnterGameOver
        rts
forceCrashRespawn
        jsr     EnterRespawn
endUpdateForceCrash
        rts

EnterRespawn
        lda     #STATE_RESPAWN
        sta     gameState
        lda     #forceStart
        sta     force
        jsr     UpdateHudForce
        lda     #$80
        sta     playerX
        lda     #playerYMax
        sta     playerY
        lda     $d015
        ora     #%00000001
        sta     $d015
        lda     #respawnInvulnerableTime
        sta     invulnerableCounter
        lda     #$01
        sta     isInvulnerable
        lda     #$00
        sta     playerIsHit
        sta     shouldFirePlayerWeapon
        lda     #$01
        sta     canFire
        lda     #fireDelayTime
        sta     fireDelay
        jsr     RestorePlayerSpriteColors
        jsr     EnableJet
        jsr     PositionJet
        jsr     PositionPlayerSprite
        rts

UpdateRespawn
        jsr     UpdateEnemies
        jsr     UpdateThings
        jsr     CheckForCollision
        jsr     UpdatePlayerWeaponFrame
        jsr     UpdatePlayerWeapon
        jsr     DrawPlayerWeapon
        jsr     UpdatePlayerBounds
        jsr     CheckPlayerIsHit
        jsr     UpdateModulus
        jsr     UpdateTick
        jsr     CheckLevelClear
        lda     playerY
        sec
        sbc     #cinematicMoveSpeed
        cmp     #playerEnterY
        bcc     respawnArrived
        beq     respawnArrived
        sta     playerY
        jsr     PositionPlayerSprite
        jsr     PositionJet
        rts
respawnArrived
        lda     #playerEnterY
        sta     playerY
        jsr     DisableJet
        jsr     RestorePlayerSpriteColors
        jsr     ApplyBossSharedColors      ; boss fight may still own $d026
        jsr     PositionPlayerSprite
        lda     #STATE_PLAY
        sta     gameState
        rts

; Wave/boss done → drain shots/explosions + short hold, then fly out
UpdateLevelClearing
        lda     #$00
        sta     shouldFirePlayerWeapon
        jsr     UpdateEnemies
        jsr     UpdateThings
        jsr     CheckForCollision
        jsr     UpdatePlayerWeaponFrame
        jsr     UpdatePlayerWeapon
        jsr     DrawPlayerWeapon
        jsr     PositionPlayerSprite
        jsr     UpdatePlayerBounds
        jsr     CheckPlayerIsHit
        ldx     cinematicTimer
        beq     clearingCheckHazards
        dex
        stx     cinematicTimer
        rts
clearingCheckHazards
        jsr     CheckHazardsClear
        bne     endUpdateLevelClearing
        lda     inBossRush
        bne     clearingRushNext
        jsr     EnterLevelExit
        rts
clearingRushNext
        ldx     rushBossIndex
        inx
        stx     rushBossIndex
        cpx     #rushBossCount
        bcs     clearingRushDone
        jsr     StartRushMeteor
        jsr     EnterPlay
        rts
clearingRushDone
        lda     #$00
        sta     inBossRush
        jsr     EnterGameOver
endUpdateLevelClearing
        rts

UpdateLevelExit
        jsr     UpdateThings
        lda     playerY
        sec
        sbc     #cinematicMoveSpeed
        bcc     levelExitDone
        cmp     #playerExitY
        bcc     levelExitDone
        sta     playerY
        jsr     PositionPlayerSprite
        jsr     PositionJet
        rts
levelExitDone
        jsr     EnterTransition
        rts

UpdateTransition
        jsr     UpdateThings
        ldx     cinematicTimer
        dex
        stx     cinematicTimer
        bne     endUpdateTransition
        ldx     levelIndex
        inx
        stx     levelIndex
        cpx     #maxLevels
        bcs     transitionAllClear
        jsr     EnterLevelEnter
        rts
transitionAllClear
        jsr     EnterBossRush
endUpdateTransition
        rts

UpdateLevelEnter
        jsr     UpdateThings
        lda     playerY
        sec
        sbc     #cinematicMoveSpeed
        cmp     #playerEnterY
        bcc     levelEnterArrived
        beq     levelEnterArrived
        sta     playerY
        jsr     PositionPlayerSprite
        jsr     PositionJet
        rts
levelEnterArrived
        lda     #playerEnterY
        sta     playerY
        jsr     PositionPlayerSprite
        jsr     EnterGetPsyched
        rts

UpdateGetPsyched
        jsr     UpdateThings
        lda     cinematicTimer
        and     #getPsychedBlinkMask
        beq     getPsychedBlinkOff
        jsr     DisplayGetPsyched
        jmp     getPsychedTick
getPsychedBlinkOff
        jsr     HideGetPsyched
getPsychedTick
        ldx     cinematicTimer
        dex
        stx     cinematicTimer
        bne     endUpdateGetPsyched
        jsr     EnterPlay
endUpdateGetPsyched
        rts

; Wave spawn complete AND no enemies left → Warning → boss; clear only when boss dead
; Bossrush owns Warning starts via UpdateBossRush (skip here).
CheckLevelClear
        lda     inBossRush
        bne     endCheckLevelClear
        lda     enemyTickPointer
        cmp     levelEnemyEnd
        bcc     endCheckLevelClear
        ldx     #$00
checkLevelClearEnemies
        lda     activeEnemies,x
        cmp     #$ff
        bne     endCheckLevelClear
        inx
        cpx     #maxActiveEnemies
        bcc     checkLevelClearEnemies

        lda     bossState
        cmp     #BOSS_STATE_OFF
        bne     endCheckLevelClear
        jsr     StartWarning
endCheckLevelClear
        rts

;
;       BOSSRUSH — after level 3: meteors → boss ×3 → game over
;
EnterBossRush
        lda     #$01
        sta     inBossRush
        lda     #$00
        sta     rushBossIndex
        sta     levelIndex
        jsr     HideBoss
        jsr     InitEnemies
        jsr     InitBoss
        jsr     ClearDrops
        lda     #$00
        sta     enemyTickPointer
        sta     levelEnemyEnd
        sta     ticks
        sta     tickHalt
        lda     #$80
        sta     playerX
        lda     #playerYMax
        sta     playerY
        lda     #%11111101
        sta     $d015
        jsr     PositionPlayerSprite
        jsr     ApplyLevelBackground
        jsr     StartRushMeteor
        jsr     EnterPlay
        rts

StartRushMeteor
        jsr     HideBoss
        jsr     InitEnemies
        jsr     InitBoss
        lda     #$00
        sta     enemyTickPointer
        sta     levelEnemyEnd
        sta     ticks
        sta     tickHalt
        lda     #rushMeteorFrames
        sta     rushMeteorTimer
        lda     #rushMeteorSpawnEvery
        sta     rushSpawnCounter
        lda     #%11111101
        sta     $d015
        rts

UpdateBossRush
        lda     inBossRush
        beq     endUpdateBossRush
        lda     bossState
        bne     endUpdateBossRush          ; warning / enter / idle / done
        lda     rushMeteorTimer
        beq     rushMeteorDrain
        sec
        sbc     #$01
        sta     rushMeteorTimer
        ldx     rushSpawnCounter
        dex
        stx     rushSpawnCounter
        bne     endUpdateBossRush
        lda     #rushMeteorSpawnEvery
        sta     rushSpawnCounter
        jsr     SpawnRushMeteor
        rts
rushMeteorDrain
        ldx     #$00
rushDrainLoop
        lda     activeEnemies,x
        cmp     #$ff
        bne     endUpdateBossRush
        inx
        cpx     #maxActiveEnemies
        bcc     rushDrainLoop
        lda     rushBossIndex
        sta     levelIndex
        jsr     ApplyLevelBackground
        jsr     InitBoss
        jsr     StartWarning
endUpdateBossRush
        rts

; Spawn one type-$04 asteroid into free rush slot.
; X from end-of-L2 meteor rain (same spread as stage 2 finale).
SpawnRushMeteor
        ldy     #rushAstroSlotFirst
spawnRushSlotLoop
        lda     enemies,y
        beq     spawnRushGotSlot
        iny
        cpy     #(rushAstroSlotFirst + rushAstroSlotCount)
        bcc     spawnRushSlotLoop
        rts
spawnRushGotSlot
        sty     enemyToActivate
        jsr     ActivateEnemy
        bcs     endSpawnRushMeteor
        jsr     UpdateRNG24
        lda     rng24              ; 0..28
pickRushXIdx
        cmp     #RushMeteorXCount
        bcc     gotRushXIdx
        sbc     #RushMeteorXCount  ; C=1
        bcs     pickRushXIdx
gotRushXIdx
        tax
        lda     RushMeteorXTbl,x
        ldy     enemyToActivate
        sta     enemyX,y
endSpawnRushMeteor
        rts

; L2 EnemyStartX meteor cluster (last 18 of stage 2)
RushMeteorXCount = 18
RushMeteorXTbl
        .byte   $31,$b3,$53,$97,$3c,$91,$69,$25
        .byte   $4d,$80,$b9,$53,$42,$a2,$ca,$6f
        .byte   $4d,$97

; Z=1 if board clean (ready for fly-out). Z=0 if something still active.
CheckHazardsClear
        ldx     #$00
checkHazardsEnemies
        lda     activeEnemies,x
        cmp     #$ff
        bne     hazardsNotClear
        inx
        cpx     #maxActiveEnemies
        bcc     checkHazardsEnemies

        ldx     #$00
checkHazardsBullets
        lda     bullets,x
        bne     hazardsNotClear
        lda     homings,x
        bne     hazardsNotClear
        inx
        cpx     #maxBullets
        bcc     checkHazardsBullets

        lda     thunderBoltCoolDown
        bne     hazardsNotClear

        ldx     #$00
checkHazardsEnemyWeapons
        lda     enemyWeapons,x
        bne     hazardsNotClear
        inx
        cpx     #maxEnemyWeapons
        bcc     checkHazardsEnemyWeapons

        ldx     #$00
checkHazardsExplosions
        lda     explosions,x
        bne     hazardsNotClear
        inx
        cpx     #maxExplosions
        bcc     checkHazardsExplosions

        lda     #$00                ; Z=1 clear
        rts
hazardsNotClear
        lda     #$01                ; Z=0 still busy
        rts

TryNoDamageBonus
        lda     tookDamageThisLevel
        bne     endTryNoDamageBonus
        ldx     #noDamageBonusHits
noDamageBonusLoop
        txa
        pha
        lda     #$01
        sta     scoreAdd
        jsr     IncreaseScore
        pla
        tax
        dex
        bne     noDamageBonusLoop
endTryNoDamageBonus
        rts

;
; Jet sprite 1 ($47f9 / $d002-$d003) — jet01..03 ($8d..$8f)
;
EnableJet
        lda     $d015
        ora     #%00000010
        sta     $d015
        lda     #$00
        sta     jetAnimFrame
        sta     jetAnimCounter
        lda     JetFrameTable
        sta     $47f9
        lda     #jetColor
        sta     $d028
        rts

DisableJet
        lda     $d015
        and     #%11111101
        sta     $d015
        lda     #$00
        sta     $d003
        rts

; Player MC shared + individual (boss may temporarily own $d026)
RestorePlayerSpriteColors
        lda     #$0b
        sta     $d025
        lda     #$0c
        sta     $d026
        ldx     playerWeapon
        lda     PlayerColor,x
        sta     $d027
        rts

; Re-apply boss mcolour2 while ENTER/IDLE (after respawn etc.)
ApplyBossSharedColors
        lda     bossState
        cmp     #BOSS_STATE_ENTER
        beq     applyBossMc2
        cmp     #BOSS_STATE_IDLE
        bne     endApplyBossSharedColors
applyBossMc2
        ldx     levelIndex
        lda     BossMc2Tbl,x
        sta     $d026
endApplyBossSharedColors
        rts

PositionJet
        lda     playerX
        sta     $d002
        lda     playerY
        clc
        adc     #jetYOffset
        sta     $d003
        ; Animate jet01..03
        ldx     jetAnimCounter
        inx
        stx     jetAnimCounter
        cpx     #jetAnimSpeed
        bcc     endPositionJet
        lda     #$00
        sta     jetAnimCounter
        ldx     jetAnimFrame
        inx
        cpx     #$03
        bcc     jetAnimStore
        ldx     #$00
jetAnimStore
        stx     jetAnimFrame
        lda     JetFrameTable,x
        sta     $47f9
endPositionJet
        rts

; Returns Z=0 if fire pressed while armed (edge after release).
; Otherwise Z=1. Uses $dc00 bit4 (joystick 2 fire).
PollFireArm
        lda     $dc00
        and     #$10
        beq     pollFirePressed     ; 0 = pressed
        lda     #$01
        sta     fireArmed
        lda     #$00                ; Z=1
        rts
pollFirePressed
        lda     fireArmed
        beq     pollFireNotReady    ; still held from before
        lda     #$00
        sta     fireArmed
        lda     #$01                ; Z=0 → trigger
        rts
pollFireNotReady
        lda     #$00                ; Z=1
        rts

; Copy uppercase/graphics charset from ROM ($D000) into bank-1 RAM ($4800).
CopyPetsciiCharset
        sei
        lda     $01
        pha
        and     #$fb                ; char ROM visible at $D000
        sta     $01
        ldx     #$00
copyPetsciiLoop
        lda     $d000,x
        sta     $4800,x
        lda     $d100,x
        sta     $4900,x
        lda     $d200,x
        sta     $4a00,x
        lda     $d300,x
        sta     $4b00,x
        lda     $d400,x
        sta     $4c00,x
        lda     $d500,x
        sta     $4d00,x
        lda     $d600,x
        sta     $4e00,x
        lda     $d700,x
        sta     $4f00,x
        inx
        bne     copyPetsciiLoop
        pla
        sta     $01
        cli
        rts

DrawTitleScreen
        ; Blit PETSCII logo (1000 screen + 1000 color)
        ldx     #$00
drawLogoLoop
        lda     titleLogoScreen,x
        sta     $4400,x
        lda     titleLogoScreen+$100,x
        sta     $4500,x
        lda     titleLogoScreen+$200,x
        sta     $4600,x
        lda     titleLogoColor,x
        sta     $d800,x
        lda     titleLogoColor+$100,x
        sta     $d900,x
        lda     titleLogoColor+$200,x
        sta     $da00,x
        cpx     #$e8                ; last 232 bytes of page 3
        bcs     drawLogoNext
        lda     titleLogoScreen+$300,x
        sta     $4700,x
        lda     titleLogoColor+$300,x
        sta     $db00,x
drawLogoNext
        inx
        bne     drawLogoLoop
        jsr     DrawTitleMenuLabels
        jsr     DrawTitleMenuCursor
        jsr     DrawTitleCorners
endDrawTitleScreen
        rts

; Title menu + credits draw/data live after drops (*=$c500+) — keep under screen $4400
titlePrompt
        .byte    $10,$12,$05,$13,$13,$20,$06,$09,$12,$05,$00
        ; PRESS FIRE (game over / credits)

titleLogoScreen
        .binary  "petskii/logo_screen.seq"
titleLogoColor
        .binary  "petskii/logo_color.seq"

; Text-only GO = hiscore board (no initials). Screen $4400, game charset.
; Row5 GAME OVER | Row7 YOUR SCORE | Row9 NEW HISCORE? | Row11-15 list | Row18 PRESS FIRE
DrawGameOverScreen
        ldx     #$00
drawGoTitleLoop
        lda     gameOverText,x
        beq     drawGoYourScore
        sta     $44d7,x             ; row 5 col 15
        inx
        jmp     drawGoTitleLoop
drawGoYourScore
        ldx     #$00
drawGoYourLoop
        lda     goYourScoreText,x
        beq     drawGoYourDigits
        sta     $4521,x             ; row 7 col 9
        inx
        jmp     drawGoYourLoop
drawGoYourDigits
        lda     #<$452c             ; row 7 col 20
        sta     tmp1
        lda     #>$452c
        sta     tmp2
        ldx     #$00                ; playerScore
        jsr     DrawScoreDigits
        lda     godModeUsed
        beq     drawGoAfterDigits
        lda     #$02                ; red zeros on cheat run
        sta     $d92c
        sta     $d92d
        sta     $d92e
        sta     $d92f
        sta     $d930
        sta     $d931
drawGoAfterDigits
        lda     hiscoreMade
        beq     drawGoList
        ldx     #$00
drawGoNewLoop
        lda     goNewHiscoreText,x
        beq     drawGoList
        sta     $4575,x             ; row 9 col 13
        inx
        jmp     drawGoNewLoop
drawGoList
        ldx     #$00                ; entry 0..4
drawGoListLoop
        txa
        pha
        ; rank char '1'+x at row 11+x, col 14
        clc
        adc     #$31
        sta     goRankChar
        ; screen = $4400 + (11+x)*40 + 14 = $45C6 + x*40
        lda     #$c6
        sta     tmp1
        lda     #$45
        sta     tmp2
        txa
        beq     drawGoRankPut
        tay
drawGoRowAdd
        lda     tmp1
        clc
        adc     #40
        sta     tmp1
        bcc     drawGoRowAddNoC
        inc     tmp2
drawGoRowAddNoC
        dey
        bne     drawGoRowAdd
drawGoRankPut
        ldy     #$00
        lda     goRankChar
        sta     (tmp1),y
        iny
        lda     #$20
        sta     (tmp1),y
        iny
        ; digits at +2
        lda     tmp1
        clc
        adc     #$02
        sta     tmp1
        bcc     drawGoDigitsPtrOk
        inc     tmp2
drawGoDigitsPtrOk
        pla
        tax                         ; entry index
        jsr     DrawHiscoreDigits
        inx
        cpx     #hiscoreCount
        bcc     drawGoListLoop
        ldx     #$00
drawGoPromptLoop
        lda     titlePrompt,x
        beq     endDrawGameOverScreen
        sta     $46de,x             ; row 18 col 14
        inx
        jmp     drawGoPromptLoop
endDrawGameOverScreen
        rts

goRankChar
        .byte   0

gameOverText
        .byte    $07,$01,$0d,$05,$20,$0f,$16,$05,$12,$00
        ; GAME OVER
goYourScoreText
        .byte    $19,$0f,$15,$12,$20,$13,$03,$0f,$12,$05,$20,$00
        ; YOUR SCORE_
goNewHiscoreText
        .byte    $0e,$05,$17,$20,$08,$09,$13,$03,$0f,$12,$05,$00
        ; NEW HISCORE

; Write 6 digits (MSD left) from playerScore to (tmp1)
; X unused; uses Y
DrawScoreDigits
        ldy     #$00
        ldx     #$05
drawScoreDigitsLoop
        lda     #$30
        clc
        adc     playerScore,x
        sta     (tmp1),y
        iny
        dex
        bpl     drawScoreDigitsLoop
        rts

; Write Hiscores entry X (6 digits) to (tmp1)
DrawHiscoreDigits
        txa
        pha
        jsr     HiscoreEntryOffset  ; A = X*6
        clc
        adc     #$05
        tax                         ; MSD index
        ldy     #$00
        lda     #$06
        sta     tmp3
drawHiscoreDigitsLoop
        lda     #$30
        clc
        adc     Hiscores,x
        sta     (tmp1),y
        iny
        dex
        dec     tmp3
        bne     drawHiscoreDigitsLoop
        pla
        tax
        rts

; A = entry index → A = entry*6
HiscoreEntryOffset
        sta     tmp3
        asl                         ; *2
        sta     tmp3
        asl                         ; *4
        asl                         ; *8
        sec
        sbc     tmp3                ; *8 - *2 = *6
        rts

; Compare playerScore to Hiscores[X]. C=1 if player > entry, else C=0.
ComparePlayerToHiscore
        txa
        pha
        jsr     HiscoreEntryOffset
        sta     tmp3                ; base offset into Hiscores
        ldy     #$05                ; MSD first
cmpHiscoreLoop
        tya
        clc
        adc     tmp3
        tax
        lda     playerScore,y
        cmp     Hiscores,x
        beq     cmpHiscoreNext
        pla
        tax
        rts
cmpHiscoreNext
        dey
        bpl     cmpHiscoreLoop
        pla
        tax
        clc
        rts

; Insert playerScore into Hiscores if it ranks. Sets hiscoreMade.
SubmitHiscore
        lda     #$00
        sta     hiscoreMade
        lda     godModeUsed         ; cheat run → keep board clean (score already 0)
        bne     endSubmitHiscore
        ldx     #$00
submitFindLoop
        cpx     #hiscoreCount
        bcs     endSubmitHiscore
        jsr     ComparePlayerToHiscore
        bcs     submitFound
        inx
        bne     submitFindLoop
submitFound
        stx     hiscoreInsert
        ; Shift slots downward: source = 3..insert → dest = source+1
        lda     #hiscoreCount-2
        sta     tmp2                ; source entry index
submitShiftLoop
        lda     tmp2
        cmp     hiscoreInsert
        bcc     submitWrite
        jsr     HiscoreEntryOffset
        pha                         ; source byte base (HiscoreEntryOffset trashes tmp3)
        lda     tmp2
        clc
        adc     #$01
        jsr     HiscoreEntryOffset
        tax                         ; dest byte base
        pla
        sta     tmp3                ; restore source base
        ldy     #$00
submitCopy6
        tya
        clc
        adc     tmp3
        sty     tmp1
        tay
        lda     Hiscores,y
        ldy     tmp1
        sta     Hiscores,x
        inx
        iny
        cpy     #$06
        bcc     submitCopy6
        dec     tmp2
        lda     tmp2
        cmp     #$ff
        bne     submitShiftLoop
submitWrite
        lda     hiscoreInsert
        jsr     HiscoreEntryOffset
        tax
        ldy     #$00
submitStoreLoop
        lda     playerScore,y
        sta     Hiscores,x
        inx
        iny
        cpy     #$06
        bcc     submitStoreLoop
        lda     #$01
        sta     hiscoreMade
endSubmitHiscore
        rts

GameOver
        jsr     EnterGameOver
        rts

;
;
;       IRQ
;
;
irq
        lda     #$00
        sta     wait

        lda     #<irq
        ldx     #>irq
        sta     $0314
        stx     $0315

        ldy     #$00
        sty     $d012

        asl     $d019
        jmp     $ea81

;
;       MUSIC (GoatTracker @ $C000, ZP $AE/$AF)
;
MusicStart
        ; Skip re-init if already playing (credits → title)
        lda     musicEnabled
        bne     endMusicStart
        lda     #musicTune
        jsr     musicInit
        lda     #$01
        sta     musicEnabled
endMusicStart
        rts

MusicStop
        lda     #$00
        sta     musicEnabled
        ldx     #$18
        lda     #$00
musicSilenceLoop
        sta     $d400,x
        dex
        bpl     musicSilenceLoop
        rts

MusicUpdate
        lda     musicEnabled
        beq     endMusicUpdate
        jsr     musicPlay
endMusicUpdate
        rts

;
;       SFX — voice 3 one-shots (tweak in sfxlab.asm, keys 1–7)
;
SfxResetVoice
        lda     #$00
        sta     sfxVoiceWave
        sta     sfxVoiceFreqL
        sta     sfxVoiceFreqH
        sta     sfxVoiceAD
        sta     sfxVoiceSR
        rts

; Shared loader: X = offset into SfxPresets (11 bytes + volume last)
SfxPlayPreset
        lda     #$00
        sta     sfxVoiceWave        ; gate off first
        lda     SfxPresets,x        ; FREQ LO
        sta     sfxFreqL
        sta     sfxVoiceFreqL
        inx
        lda     SfxPresets,x        ; FREQ HI
        sta     sfxFreqH
        sta     sfxVoiceFreqH
        inx
        lda     SfxPresets,x        ; PW LO
        sta     sfxVoicePwL
        inx
        lda     SfxPresets,x        ; PW HI
        sta     sfxVoicePwH
        inx
        lda     SfxPresets,x        ; WAVE (no gate yet)
        sta     tmp3
        inx
        lda     SfxPresets,x        ; AD
        sta     sfxVoiceAD
        inx
        lda     SfxPresets,x        ; SR
        sta     sfxVoiceSR
        inx
        lda     SfxPresets,x        ; TIMER
        sta     sfxTimer
        inx
        lda     SfxPresets,x        ; SWEEP
        sta     sfxSweep
        inx
        lda     SfxPresets,x        ; WOBBLE
        sta     sfxWobble
        inx
        lda     SfxPresets,x        ; VOLUME
        sta     sfxVolume
        inx
        lda     SfxPresets,x        ; THRESH
        sta     sfxThresh
        lda     tmp3
        sta     sfxVoiceWave        ; gate on
        rts

; Preset rows: FL FH PL PH WV AD SR TM SW WB VL TH  (12 bytes)
SfxPresets
sfxPresBullets
        .byte   $02,$03,$87,$2f,$81,$07,$28,$0a,$11,$a7,$2f,$03
sfxPresHoming
        .byte   $00,$3f,$03,$0b,$13,$01,$ee,$08,$06,$61,$1f,$04
sfxPresLaser
        .byte   $10,$cd,$08,$09,$65,$01,$fc,$14,$0b,$63,$1b,$05
sfxPresExplosion
        .byte   $0c,$cb,$08,$11,$81,$08,$fd,$1b,$4c,$66,$0f,$04
; Placeholders — tweak in sfxlab (5=HIT 6=CRASH 7=ALARM)
sfxPresHit
        .byte   $20,$18,$00,$08,$81,$02,$48,$06,$08,$44,$0c,$08
sfxPresCrash
        .byte   $10,$40,$00,$10,$81,$06,$8a,$28,$18,$55,$12,$10
sfxPresAlarm
        .byte   $00,$30,$80,$0c,$41,$02,$a8,$2c,$02,$90,$0e,$18

SfxPlayBullets
        ldx     #0
        jmp     SfxPlayPreset
SfxPlayHoming
        ldx     #12
        jmp     SfxPlayPreset
SfxPlayLaser
        ldx     #24
        jmp     SfxPlayPreset
SfxPlayExplosion
        ldx     #36
        jmp     SfxPlayPreset
SfxPlayHit
        ldx     #48
        jmp     SfxPlayPreset
SfxPlayCrash
        ldx     #60
        jmp     SfxPlayPreset
SfxPlayAlarm
        ldx     #72
        jmp     SfxPlayPreset

SfxUpdate
        lda     sfxTimer
        beq     endSfxUpdate
        sec
        sbc     #$01
        sta     sfxTimer
        beq     sfxDone
        ; Sweep: if FREQ HI >= THRESH then -= SWEEP, else FREQ LO ^= WOBBLE
        lda     sfxFreqH
        cmp     sfxThresh
        bcc     sfxBulletsWobble
        sec
        sbc     sfxSweep
        sta     sfxFreqH
        sta     sfxVoiceFreqH
        rts
sfxBulletsWobble
        lda     sfxFreqL
        eor     sfxWobble
        sta     sfxFreqL
        sta     sfxVoiceFreqL
        rts
sfxDone
        jsr     SfxResetVoice
endSfxUpdate
        rts

;
;
;       HANDLE MODULUS
;
;
UpdateModulus
        ; Handle modulus
        ldx     modulus
        cpx     #$01
        beq     setModulusToZero
        ldx     #$01
        stx     modulus
        jmp     endUpdateModulus
setModulusToZero
        ldx     #$00
        stx     modulus
endUpdateModulus

        rts

;
;
;
;
;
UpdateRNG

        ldx     modulus
        cpx     #$00
        beq     doUpdateRng30

        jsr     UpdateRNG24
        rts
doUpdateRng30

        jsr     UpdateRNG30
        rts

;
;
;
;
;
UpdateRNG30
        lda     rng30
        clc
        adc     #$01
        sta     rng30
        cmp     #30
        bcc     skipResetRng30

        lda     #$00
        sta     rng30
skipResetRng30
        rts

;
;
;
;
;
UpdateRNG24
        lda     rng24
        clc
        adc     #$01
        sta     rng24
        cmp     #29
        bcc     skipResetRng24

        lda     #$00
        sta     rng24
skipResetRng24
        rts
;
;
;       TICK UPDATE
;
;
TickUpdate

;Temp
        ldx     playerWeapon
        inx
      ;  stx     playerWeapon
        ; Temp sortof
        ldx     playerWeapon
        lda     PlayerColor,x
        sta     $d027

        jsr     TickEnemies

        rts

;
;
;       UPDATE TICK
;
;
UpdateTick
        ldx     tickHalt
        cpx     #$00
        bne     CheckEnemyList
        ldx     tickCounter
        inx
        stx     tickCounter
        cpx     #tickDelayTime
        bcc     endUpdateTick
        ldy     ticks
        iny
        sty     ticks
        lda     #$00
        sta     tickCounter
        jsr     TickUpdate
endUpdateTick
        rts


CheckEnemyList
        ldx     #$ff
checkEnemyListLoop
        inx
        cpx     #maxActiveEnemies
        bcs     continueHaltTick

        lda     activeEnemies,x
        cmp     #$ff
        bne     checkEnemyListLoop

        lda     #$00
        sta     tickHalt
        jmp     UpdateTick

continueHaltTick
        jmp     endUpdateTick


;#######################;
;                       ;
;       SEGINIT         ;
;                       ;
;#######################;

;
;
;
;
;
Init
        lda     #$00
        sta     playerIsHit
        sta     modulus
        sta     ticks
        sta     tickCounter
        sta     tickHalt
        sta     testDir
        lda     #$01
        sta     wait
        sta     testTick;Temp
        jsr     ApplyLevelBackground
        jsr     ClearScreen
        jsr     ColorizeScreen

        ; Entities
        jsr     InitEntities

        rts

;
;
;
;
;
ClearScreen
        ldx     #$00
clearScreenOutherLoop
        lda     ScreenRowsL,x
        sta     tmp1
        lda     ScreenRowsH,x
        sta     tmp2
        ldy     #$00
clearScreeInnerLoop
        lda     #$20
        sta     (tmp1),y
        iny
        clc
        cpy     #40
        bcc     clearScreeInnerLoop
        inx
        clc
        cpx     #25
        bcc     clearScreenOutherLoop
        rts

;
;
;
;
;
ColorizeScreen
        ldx     #$00
        ldy     #$01
colorizeScreenLoop

        lda     #$01
        sta     $d800,x
        sta     $d900,x
        sta     $da00,x
        sta     $dae8,x
        iny
        clc
        cpy     #$0f
        bcc     colorizeScreenNext
        ldy     #$01
colorizeScreenNext
        inx
        bne     colorizeScreenLoop
endColorizeScreen
        rts


;#######################;
;                       ;
;      SEGSTATS         ;
;                       ;
;#######################;

;
;
;
;
;
UpdateStats
        rts


;#######################;
;                       ;
;        SEGHUD         ;
;                       ;
;#######################;

;
;
;
;
;



InitHud
        ;DrawStraightCol #31,#$7b,#$01
endinitColorHud

; "SCORE"
        ldx     #33
        lda     #$13    ;S
        sta     $4428,x
        inx
        lda     #$03
        sta     $4428,x
        inx
        lda     #$0f
        sta     $4428,x
        inx
        lda     #$12
        sta     $4428,x
        inx
        lda     #$05
        sta     $4428,x
        inx
        lda     #$3a
        sta     $4428,x
; And the "000000"
        jsr     UpdateScore
;"FORCE"
        ldx     #33
        lda     #$06
        sta     $44a0,x
        inx
        lda     #$0f
        sta     $44a0,x
        inx
        lda     #$12
        sta     $44a0,x
        inx
        lda     #$03
        sta     $44a0,x
        inx
        lda     #$05
        sta     $44a0,x
        inx
        lda     #$3a
        sta     $44a0,x
; And the bar
        jsr     UpdateHudForce
;"SHIPS:"
        ldx     #33
        lda     #$13
        sta     $4518,x
        inx
        lda     #$08
        sta     $4518,x
        inx
        lda     #$09
        sta     $4518,x
        inx
        lda     #$10
        sta     $4518,x
        inx
        lda     #$13
        sta     $4518,x
        inx
        lda     #$3a
        sta     $4518,x
; Ships
        jsr     UpdateHudShips
; Weapon name + level
        jsr     UpdateHudWeapon
        jsr     UpdateGodModeHud        ; CHEAT label if voided

        rts

;
;
;       Increases score by scoreAdd×10 (BCD digits; add into tens place)
;
;
IncreaseScore
        lda     godModeUsed
        bne     endIncreaseScore    ; void after cheat
        ldx     #$01                ; ones digit unused → ×10 vs damage value
        lda     playerScore,x
        clc
        adc     scoreAdd
        sta     playerScore,x
increaseScoreCarryLoop
        cmp     #$0a
        bcc     endIncreaseScore
        sec
        sbc     #$0a
        sta     playerScore,x
        inx
        cpx     #$06
        bcs     endIncreaseScore
        lda     playerScore,x
        clc
        adc     #$01
        sta     playerScore,x
        jmp     increaseScoreCarryLoop

endIncreaseScore
        jsr     UpdateScore
        jsr     CheckExtraLife
        rts

; One-shot: +1 ship at 10000 if ships < shipsMax
CheckExtraLife
        lda     godModeUsed
        bne     endCheckExtraLife
        lda     extraLifeAwarded
        bne     endCheckExtraLife
        lda     playerScore+5       ; 100000s
        bne     awardExtraLife
        lda     playerScore+4       ; 10000s
        beq     endCheckExtraLife
awardExtraLife
        lda     #$01
        sta     extraLifeAwarded
        lda     ships
        cmp     #shipsMax
        bcs     endCheckExtraLife
        clc
        adc     #$01
        sta     ships
        jsr     UpdateHudShips
endCheckExtraLife
        rts

UpdateScore
        ldx     #$00
        lda     #$30
        clc
        adc     playerScore,x
        sta     $4476;1137;$4450,x

        inx
        lda     #$30
        clc
        adc     playerScore,x
        sta     $4475;1138;$4450,x
        inx
        lda     #$30
        clc
        adc     playerScore,x
        sta     $4474
        inx
        lda     #$30
        clc
        adc     playerScore,x
        sta     $4473
        inx
        lda     #$30
        clc
        adc     playerScore,x
        sta     $4472
        inx
        lda     #$30
        clc
        adc     playerScore,x
        sta     $4471

        ; Cheat run → red digits; else white
        lda     godModeUsed
        beq     updateScoreWhite
        lda     #$02                ; red
        jmp     updateScorePaint
updateScoreWhite
        lda     #$01                ; white
updateScorePaint
        sta     $d871
        sta     $d872
        sta     $d873
        sta     $d874
        sta     $d875
        sta     $d876
        rts

; Clear playerScore to 000000 and refresh HUD (cheat void)
ZeroPlayerScore
        lda     #$00
        ldx     #$00
zeroPlayerScoreLoop
        sta     playerScore,x
        inx
        cpx     #$06
        bcc     zeroPlayerScoreLoop
        jmp     UpdateScore

;
;
;       UPDATE FORCE BAR
;
;
UpdateHudForce
        ; reset
        ldx     #33
        lda     #$78
        sta     $44c8,x
        inx
        lda     #$79
        sta     $44c8,x
        inx
        lda     #$79
        sta     $44c8,x
        inx
        lda     #$79
        sta     $44c8,x
        inx
        lda     #$79
        sta     $44c8,x
        inx
        lda     #$7a
        sta     $44c8,x
        ; Draw force
        ldx     #$00
        ldy     #33
        lda     #$77
updateForceLoop
        cpx     force
        beq     endUpdateForce
        sta     $44c8,y
        inx
        iny
        jmp     updateForceLoop
endUpdateForce        
        rts

;
;
;       DISPLAY GET PSYCHED — simple blink text (row 7); Warning keeps PetMate idea
;
;
DisplayGetPsyched
        ldx     #$0a
        lda     #$07
        sta     $4518,x
        inx
        lda     #$05
        sta     $4518,x
        inx
        lda     #$14
        sta     $4518,x
        inx
        inx
        lda     #$10
        sta     $4518,x
        inx
        lda     #$13
        sta     $4518,x
        inx
        lda     #$19
        sta     $4518,x
        inx
        lda     #$03
        sta     $4518,x
        inx
        lda     #$08
        sta     $4518,x
        inx
        lda     #$05
        sta     $4518,x
        inx
        lda     #$04
        sta     $4518,x
        inx
        lda     #$41
        sta     $4518,x
        rts

;
;
;       HIDE GET PSYCHED
;
;
HideGetPsyched
        ldx     #$0a
        lda     #$20
        sta     $4518,x
        inx
        sta     $4518,x
        inx
        sta     $4518,x
        inx
        inx
        sta     $4518,x
        inx
        sta     $4518,x
        inx
        sta     $4518,x
        inx
        sta     $4518,x
        inx
        sta     $4518,x
        inx
        sta     $4518,x
        inx
        sta     $4518,x
        inx
        sta     $4518,x
        rts

;
;
;
;
;
UpdateHudShips
        jsr     ClearHubShips
        ldy     #$00
        cpy     ships
        beq     endUpdateHudShips
        jsr     AddShip1

        iny
        cpy     ships
        bcs     endUpdateHudShips
        jsr     AddShip2

        iny
        cpy     ships
        bcs     endUpdateHudShips
        jsr     AddShip3
endUpdateHudShips
        rts

;
;
;       HUD: weapon name + "X n" below ship icons (rows 10–11, col 33+)
;
;
UpdateHudWeapon
        lda     #$20
        ldx     #$00
clearHudWeaponNameLoop
        sta     $45b1,x             ; row 10 col 33
        inx
        cpx     #$07
        bcc     clearHudWeaponNameLoop
        sta     $45d9               ; row 11 col 33
        sta     $45da
        sta     $45db

        lda     playerWeapon
        cmp     #$02
        beq     hudWeaponHoming
        cmp     #$03
        beq     hudWeaponLaser
        ldx     #$00
hudCopyBullets
        lda     HudNameBullets,x
        cmp     #$ff
        beq     hudWeaponNameDone
        sta     $45b1,x
        inx
        bne     hudCopyBullets
hudWeaponHoming
        ldx     #$00
hudCopyHoming
        lda     HudNameHoming,x
        cmp     #$ff
        beq     hudWeaponNameDone
        sta     $45b1,x
        inx
        bne     hudCopyHoming
hudWeaponLaser
        ldx     #$00
hudCopyLaser
        lda     HudNameLaser,x
        cmp     #$ff
        beq     hudWeaponNameDone
        sta     $45b1,x
        inx
        bne     hudCopyLaser

hudWeaponNameDone
        lda     #$18                ; X
        sta     $45d9
        lda     playerWeaponLevel
        clc
        adc     #$30
        sta     $45da

        ; Color name + Xn with weapon color
        ldx     playerWeapon
        lda     WeaponColor,x
        ldx     #$00
hudWeaponColorLoop
        sta     $d9b1,x
        inx
        cpx     #$07
        bcc     hudWeaponColorLoop
        sta     $d9d9
        sta     $d9da
        rts
;
;
;       CLEAR SHIPS (max 3 — rows 8–9; rows 10–11 reserved for weapon HUD)
;
;
ClearHubShips
        lda     #$20
        ldx     #33
        sta     $4540,x
        sta     $4568,x
        inx
        sta     $4540,x
        sta     $4568,x
        inx
        sta     $4540,x
        sta     $4568,x
        inx
        sta     $4540,x
        sta     $4568,x
        inx
        sta     $4540,x
        sta     $4568,x
        inx
        sta     $4540,x
        sta     $4568,x

        rts

AddShip1
        ldx     #33
        lda     #$7c
        sta     $4540,x
        inx
        lda     #$7d
        sta     $4540,x
        ldx     #33
        lda     #$7e
        sta     $4568,x
        inx
        lda     #$7f
        sta     $4568,x

        rts

AddShip2
        ldx     #35
        lda     #$7c
        sta     $4540,x
        inx
        lda     #$7d
        sta     $4540,x
        ldx     #35
        lda     #$7e
        sta     $4568,x
        inx
        lda     #$7f
        sta     $4568,x

        rts

AddShip3
        ldx     #37
        lda     #$7c
        sta     $4540,x
        inx
        lda     #$7d
        sta     $4540,x
        ldx     #37
        lda     #$7e
        sta     $4568,x
        inx
        lda     #$7f
        sta     $4568,x

        rts

AddShip4
        ldx     #33
        lda     #$7c
        sta     $4590,x
        inx
        lda     #$7d
        sta     $4590,x
        ldx     #33
        lda     #$7e
        sta     $45b8,x
        inx
        lda     #$7f
        sta     $45b8,x

        rts

AddShip5
        ldx     #35
        lda     #$7c
        sta     $4590,x
        inx
        lda     #$7d
        sta     $4590,x
        ldx     #35
        lda     #$7e
        sta     $45b8,x
        inx
        lda     #$7f
        sta     $45b8,x

        rts

AddShip6
        ldx     #37
        lda     #$7c
        sta     $4590,x
        inx
        lda     #$7d
        sta     $4590,x
        ldx     #37
        lda     #$7e
        sta     $45b8,x
        inx
        lda     #$7f
        sta     $45b8,x

        rts



;#######################;
;                       ;
;      SEGENTITIES      ;
;                       ;
;#######################;

;
;
;
;
;
InitEntities
        jsr     InitPlayer
        jsr     InitEnemies
        jsr     InitThings
        rts

;
;
;
;
;
UpdateEntities
        lda     bossState
        cmp     #BOSS_STATE_WARNING
        beq     updateEntitiesWarning
        jsr     UpdatePlayer
        jsr     UpdateEnemies
        jsr     UpdateBoss          ; after enemies (reclaim sprite slots 2–7)
        jsr     UpdateThings
        jsr     CheckForCollision
        rts
updateEntitiesWarning
        ; Move OK; no weapons (char-based) — would punch the PETSCII banner
        lda     #$00
        sta     shouldFirePlayerWeapon
        jsr     HandleInputWarning
        jsr     UpdatePlayerSpriteFrame
        jsr     PositionPlayerSprite
        jsr     UpdatePlayerBounds
        jsr     CheckPlayerIsHit
        jsr     UpdateBoss
        rts

;#######################;
;                       ;
;      SEGPLAYER        ;
;                       ;
;#######################;

;
;
;
;
;
InitPlayer
        ; Set vars
        lda     #playerFrameCenter
        sta     playerFrame

        lda     #$00
        sta     isInvulnerable
        sta     invulnerableCounter
        sta     shouldFirePlayerWeapon
        sta     canFire

        ; Random start weapon 1..3, level x1
        jsr     UpdateRNG24
        lda     rng24
        and     #$03
        tax
        lda     RandomWeaponTable,x
        sta     playerWeapon
        lda     #$01
        sta     playerWeaponLevel
        jsr     RefreshWeaponPower

        lda     #$02
        sta     playerMoveSpeed


        ; Add sprite (player bit0; jet bit1 reserved — off in PLAY)
        lda     #%11111101
        sta     $d015
        lda     #%11111111
        sta     $d01c
        sta     $d01b
        lda     #$0b
        sta     $d025
        lda     #$0c
        sta     $d026
        ldx     playerWeapon
        lda     PlayerColor,x
        sta     $d027
        ldx     playerFrame
        lda     PlayerFrameTable,x
        sta     $47f8

        lda     #$80
        sta     playerX
        sta     $d000
        lda     #$80
        sta     playerY
        sta     $d001
        jsr     DisableJet

        ; Init player weapon
        jsr     InitPlayerWeapon

        lda     #shipsStart
        sta     ships
        lda     #forceStart
        sta     force

        lda     #$01
        sta     scoreMultiplier
        sta     scoreAdd

        lda     #$00
        sta     extraLifeAwarded
        ldx     #$00
initScoreLoop
        sta     playerScore,x
        inx
        cpx     #$06
        bcc     initScoreLoop


        rts
;
;
;
;
;
UpdatePlayer
        jsr     HandleInput
        jsr     UpdatePlayerSpriteFrame
        jsr     PositionPlayerSprite
        jsr     UpdatePlayerBounds
        jsr     UpdatePlayerWeaponFrame
        jsr     UpdatePlayerWeapon
        jsr     CheckPlayerIsHit

        ldx     shouldFirePlayerWeapon
        cpx     #$01
        bne     continueUpdatePlayer
        lda     #$00
        sta     shouldFirePlayerWeapon
        jsr     ActivatePlayerWeapon

continueUpdatePlayer
        jsr     DrawPlayerWeapon

endUpdatePlayer
        rts

;
;
;
;
;
CheckPlayerIsHit
        lda     godMode                 ; DEV: P-key god mode
        bne     endCheckPlayerIsHit

        ldx     invulnerableCounter
        cpx     #$00
        beq     dontDecreaseInvulnerableCounter
        dex
        stx     invulnerableCounter
        jmp     startCheckPlayerIsHit
dontDecreaseInvulnerableCounter

        lda     #$00
        sta     isInvulnerable
startCheckPlayerIsHit
        lda     invulnerableCounter
        cmp     #$00
        bne     endCheckPlayerIsHit

        lda     playerIsHit
        cmp     #$01
        bne     endCheckPlayerIsHit

        lda     #$01
        sta     tookDamageThisLevel

        lda     playerX
        sta     explosionStartX
        lda     playerY
        sta     explosionStartY
        jsr     ActivateExplosion

        lda     force
        sec
        sbc     #$01
        sta     force
        cmp     #$ff
        beq     playerForceEmpty
        cmp     #$00
        beq     playerForceEmpty

        ; Still have force — short invuln + hit blip (replaces explosion SFX)
        jsr     SfxPlayHit
        lda     #invulnerableTime
        sta     invulnerableCounter
        lda     #$01
        sta     isInvulnerable
        jsr     UpdateHudForce
        jmp     endCheckPlayerIsHit

playerForceEmpty
        lda     #$00
        sta     force
        jsr     UpdateHudForce
        lda     #$00
        sta     playerIsHit
        jsr     EnterForceCrash
        rts

endCheckPlayerIsHit
        lda     #$00
        sta     playerIsHit
        rts


;
;
;
;
;
UpdatePlayerSpriteFrame

        ldx     xMoveAmount
        cpx     #$00
        beq     updatePlayerNoMove
        
        cpx     #$01
        beq     updatePlayerMoveRight

        cpx     #$ff
        beq     updatePlayerMoveLeft
        rts
        
updatePlayerMoveLeft
        ldx     playerFrameCounter
        inx
        stx     playerFrameCounter
        cpx     #playerFrameTime
        bcc     updatePlayerCheckPlayerFrame
        lda     #$00
        sta     playerFrameCounter
        ldx     playerFrame
        dex
        stx     playerFrame
        cpx     #playerFrameMin
        bcs     updatePlayerCheckPlayerFrame
        lda     #playerFrameMin
        sta     playerFrame
        jmp     updatePlayerCheckPlayerFrame

updatePlayerMoveRight
        ldx     playerFrameCounter
        inx
        stx     playerFrameCounter
        cpx     #playerFrameTime
        bcc     updatePlayerCheckPlayerFrame
        lda     #$00
        sta     playerFrameCounter
        ldx     playerFrame
        inx
        stx     playerFrame
        cpx     #playerFrameMax
        bcc     updatePlayerCheckPlayerFrame
        lda     #playerFrameMax
        sta     playerFrame
        jmp     updatePlayerCheckPlayerFrame

updatePlayerNoMove      ; ToDo: Animate back!
        lda     #$00
        sta     playerFrameCounter
        ldx     playerFrame
        cpx     #playerFrameCenter
        beq     endUpdatePlayerFrame
        ldx     #playerFrameCenter
        stx     playerFrame
        lda     PlayerFrameTable,x
        sta     $47f8
        jmp     endUpdatePlayerFrame

updatePlayerCheckPlayerFrame
        ldx     playerFrame
        cpx     #playerFrameCenter
        beq     endUpdatePlayerFrame
        lda     PlayerFrameTable,x
        sta     $47f8

endUpdatePlayerFrame

        rts
;
;
;
;
;
PositionPlayerSprite
        lda     playerX
        sta     $d000
        lda     isInvulnerable
        beq     positionPlayerVisible
        lda     invulnerableCounter
        and     #$04
        beq     positionPlayerVisible
        lda     #$00                ; blink off
        sta     $d001
        rts
positionPlayerVisible
        lda     playerY
        sta     $d001
        rts
;
;
;
;
;
UpdatePlayerBounds
        lda     playerY
        sec
        sbc     #32
        sta     playerBoundY2
        sec
        sbc     #16
        sta     playerBoundY1

        lda     playerX
        sec
        sbc     #$06
        sta     playerBoundX2
        sec
        sbc     #24
        sta     playerBoundX1
        rts




;#######################;
;                       ;
;    SEGPLAYERWEAPON    ;
;                       ;
;#######################;

;
;
;
;
;
InitPlayerWeapon
        jsr     InitBullets
        jsr     InitHomings
        jsr     InitThunderBolt

        lda     #fireDelayTime
        sta     fireDelay
        rts

;
;
;
;
ActivatePlayerWeapon

        jsr     RefreshWeaponPower
        ldx     playerWeapon
        cpx     #$03
        beq     startActivateThunderBolt
        cpx     #$02
        beq     startActivateHoming
        jsr     ActivateBullet
        jmp     endActivatePlayerWeapon
startActivateThunderBolt
        jsr     ActivateThunderBolt
        jmp     endActivatePlayerWeapon
startActivateHoming
        jsr     ActivateHoming

endActivatePlayerWeapon

        rts

;
;
;       A = damage for current weapon + level
;
;
RefreshWeaponPower
        jsr     GetWeaponDamage
        sta     playerWeaponPower
        rts

GetWeaponDamage
        ldx     playerWeaponLevel
        dex                     ; 0..2
        lda     bossState
        cmp     #BOSS_STATE_ENTER
        bcc     getDamageWave       ; OFF / WARNING → wave tables
        lda     playerWeapon
        cmp     #$02
        beq     getDamageBossHoming
        cmp     #$03
        beq     getDamageBossLaser
        lda     BossDamageBullets,x
        rts
getDamageBossHoming
        lda     BossDamageHoming,x
        rts
getDamageBossLaser
        lda     BossDamageLaser,x
        rts
getDamageWave
        lda     playerWeapon
        cmp     #$02
        beq     getDamageHoming
        cmp     #$03
        beq     getDamageLaser
        lda     WeaponDamageBullets,x
        rts
getDamageHoming
        lda     WeaponDamageHoming,x
        rts
getDamageLaser
        lda     WeaponDamageLaser,x
        rts

; After weaponDecayKills kills: level-- if above 1x. X must be saved by caller (storedX).
TickWeaponDecay
        lda     weaponDecayCount
        clc
        adc     #$01
        sta     weaponDecayCount
        cmp     #weaponDecayKills
        bcc     endTickWeaponDecay
        lda     #$00
        sta     weaponDecayCount
        lda     playerWeaponLevel
        cmp     #$02
        bcc     endTickWeaponDecay  ; already 1x
        sec
        sbc     #$01
        sta     playerWeaponLevel
        jsr     RefreshWeaponPower
        jsr     UpdateHudWeapon
endTickWeaponDecay
        rts

;
;
;       Pick random weapon id 1..3 → A
;
;
PickRandomWeaponType
        jsr     UpdateRNG24
        lda     rng24
        and     #$03
        tax
        lda     RandomWeaponTable,x
        rts

;
;
;
;
UpdatePlayerWeaponFrame

        ldx     #$ff
updateWeaponFrameLoop
        inx
        cpx     #maxBullets
        bcs     endUpdateBulletFrame

        lda     bullets,x
        cmp     #$00
        bne     updateWeaponFrameLoop
        ; Got first inactive
        lda     playerX
        clc
        lsr
        lsr
        lsr
        clc
        asl
        asl
        asl
        sta     tmpBulletFrame
        lda     playerX
        sec
        sbc     tmpBulletFrame
        sta     bulletFrame,x
        sta     thunderBoltFrame

endUpdateBulletFrame
        rts

;
;
;
;
;
UpdatePlayerWeapon

        ldx     playerWeapon
        cpx     #$04
        bcs     wrapPlayerWeapon1
        cpx     #$01
        bcc     wrapPlayerWeapon2
        jmp     continueUpdatePlayerWeapon
wrapPlayerWeapon1
        lda     #$01
        sta     playerWeapon
        jmp     continueUpdatePlayerWeapon
wrapPlayerWeapon2
        lda     #$03
        sta     playerWeapon
        jmp     continueUpdatePlayerWeapon

continueUpdatePlayerWeapon

        jsr     UpdateWeaponsDelays

        jsr     UpdateBullets
        jsr     UpdateHomings
        jsr     UpdateThunderBolt
        rts

;
;
;
;
;
UpdateWeaponsDelays
        lda     canFire
        cmp     #$01
        beq     endUpdateWeaponsDelays

        ldx     fireDelay
        beq     setCanFiretoTrue
        dex
        stx     fireDelay
        bne     endUpdateWeaponsDelays
setCanFiretoTrue
        lda     #$01
        sta     canFire
endUpdateWeaponsDelays
        rts

;
;
;
;
;
DrawPlayerWeapon
        jsr     DrawBullets
        jsr     DrawHomings
        jsr     DrawThunderBolt
        rts


;#######################;
;                       ;
;       SEGBULLET       ;
;                       ;
;#######################;


;
;
;
;
;
InitBullets
        lda     #$00
        ldx     #$00
initBulletsLoop
        sta     bullets,x
        sta     bulletX,x
        sta     bulletY,x
        sta     bulletsToRemove,x
        inx
        cpx     #maxBullets
        bcc     initBulletsLoop

        rts

;
;
;
;
;
ActivateBullet
        ldx     #$ff
findInactiveBulletLoop
        inx
        cpx     #maxBullets
        bcs     endActivateBullet

        lda     bullets,x
        cmp     #$00
        bne     findInactiveBulletLoop

        lda     #$01
        sta     bullets,x

        lda     playerX
        sec
        sbc     #playerWeaponXOffset
        sta     bulletX,x

        lda     playerY
        sec
        sbc     #playerWeaponYOffset
        sta     bulletY,x

        lda     #fireDelayTime
        sta     fireDelay
        jsr     SfxPlayBullets

endActivateBullet
        rts

;
;
;
;
;
UpdateBullets
        ldx     #$ff
updateBulletsLoop
        inx
        cpx     #maxBullets
        bcs     endUpdateBullets

        lda     bulletsToRemove,x
        cmp     #$01
        bne     updateBulletsLoop

        ; Reset last position
        lda     bulletY,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     bulletX,x
        clc
        lsr
        lsr
        lsr
        tay

        ; Char
        lda     #$20
        sta     (tmp1),y
        iny
        sta     (tmp1),y
        iny
        sta     (tmp1),y

        ; Color
        lda     tmpColor1
        sta     tmp1
        lda     tmpColor2
        sta     tmp2
        lda     #$01
        sta     (tmp1),y
        dey
        sta     (tmp1),y
        dey
        sta     (tmp1),y

        lda     #$00
        sta     bullets,x
        sta     bulletsToRemove,x

        jmp     updateBulletsLoop
endUpdateBullets
        rts

;
;
;
;
;
DrawBullets
        ldx     #$ff
drawBulletsLoop
        inx
        cpx     #maxBullets
        bcs     jumpToEndDrawBullets
        jmp     continueDrawBullets
jumpToEndDrawBullets
        jmp     endDrawBullets
continueDrawBullets

        lda     bullets,x
        cmp     #$01
        bne     drawBulletsLoop

        ; Reset last position
        lda     bulletY,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     bulletX,x
        clc
        lsr
        lsr
        lsr
        tay

        ; Char
        lda     #$20
        sta     (tmp1),y
        iny
        sta     (tmp1),y
        iny
        cpy     #31
        beq     skipResetBulletRight
        sta     (tmp1),y
skipResetBulletRight
        ; Color
        lda     tmpColor1
        sta     tmp1
        lda     tmpColor2
        sta     tmp2
        lda     #$01
        sta     (tmp1),y
        dey
        sta     (tmp1),y
        dey
        sta     (tmp1),y

        ; Increase position
        lda     bulletY,x
        sec
        sbc     #bulletSpeed
        sta     bulletY,x

        ; Check new positon
        cmp     #$ff
        bcc     checkBulletBound

        jmp     drawBulletCurrentPosition
checkBulletBound
        cmp     #$b9
        bcc     drawBulletCurrentPosition
        ; Bullet is offscreen
        lda     #$00
        sta     bullets,x

        jmp     drawBulletsLoop

drawBulletCurrentPosition
        ; Draw Current position
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     bulletX,x
        clc
        lsr
        lsr
        lsr
        tay

        stx     storedX

        ; Char
        lda     bulletFrame,x
        tax
        lda     BulletLeftFrameTable,x
        sta     (tmp1),y
        iny
        lda     BulletCenterFrameTable,x
        sta     (tmp1),y
        iny
        cpy     #31
        beq     skipDrawBulletRight
        lda     BulletRightFrameTable,x
        sta     (tmp1),y
skipDrawBulletRight

        ; Color
        lda     tmpColor1
        sta     tmp1
        lda     tmpColor2
        sta     tmp2
        lda     #$07
        cpy     #31
        beq     skipColorizeBulletRight
        sta     (tmp1),y
skipColorizeBulletRight
        dey
        sta     (tmp1),y
        dey
        sta     (tmp1),y


        ldx     storedX
        jmp     drawBulletsLoop
endDrawBullets
        rts



;#######################;
;                       ;
;      SEGHOMING        ;
;                       ;
;#######################;

;
;
;
;
;
InitHomings
        lda     #$00
        ldx     #$00
initHomingLoop
        sta     homings,x
        sta     homingsToRemove,x
        sta     homingX,x
        sta     homingY,x
        sta     homingXMoveR,x
        sta     homingXMoveL,x
        inx
        cpx     #maxBullets
        bcc     initHomingLoop

        rts

;
;
;
;
;
ActivateHoming
        ldx     #$ff
findInactiveHomingLoop
        inx
        cpx     #maxBullets
        bcs     endActivateHoming

        lda     homings,x
        cmp     #$00
        bne     findInactiveHomingLoop

        lda     #$01
        sta     homings,x

        lda     #$00
        sta     homingXMoveR,x
        sta     homingXMoveL,x

        lda     playerX
        sec
        sbc     #playerWeaponXOffset
        sta     homingX,x

        lda     playerY
        sec
        sbc     #playerWeaponYOffset
        sta     homingY,x

        lda     #fireDelayTime
        sta     fireDelay
        jsr     SfxPlayHoming

endActivateHoming
        rts

;
;
;
;
;
UpdateHomings
        ldx     #$ff
updateHomingsLoop
        inx
        cpx     #maxBullets
        bcs     endUpdateHomings

        lda     homingX,x
        cmp     #$02
        bcs     homingCheckRightBound
        lda     #$01
        sta     homingsToRemove,x
        jmp     homingCheckRemove
homingCheckRightBound
        cmp     #$ef
        bcc     homingCheckRemove
        lda     #$01
        sta     homingsToRemove,x
homingCheckRemove
        lda     homingsToRemove,x
        cmp     #$01
        bne     updateHomingsLoop

        ; Reset last position (homing to remove)
        lda     homingY,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     homingX,x
        clc
        lsr
        lsr
        lsr
        tay

        ; Char
        lda     #$20
        sta     (tmp1),y

        ; Color
        lda     tmpColor1
        sta     tmp1
        lda     tmpColor2
        sta     tmp2
        lda     #$01
        sta     (tmp1),y

        lda     #$00
        sta     homings,x
        sta     homingsToRemove,x

        jmp     updateHomingsLoop
endUpdateHomings
        rts

;
;
;
;
;
DrawHomings
        ldx     #$ff
drawHomingsLoop
        inx
        cpx     #maxBullets
        bcs     jumpToEndDrawHomings
        jmp     continueDrawHomings
jumpToEndDrawHomings
        jmp     endDrawHomings
continueDrawHomings

        lda     homings,x
        cmp     #$01
        bne     drawHomingsLoop

        ; Reset last position
        lda     homingY,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     homingX,x
        clc
        lsr
        lsr
        lsr
        tay

        ; Char
        lda     #$20
        sta     (tmp1),y

        ; Color
        lda     tmpColor1
        sta     tmp1
        lda     tmpColor2
        sta     tmp2
        lda     #$01
        sta     (tmp1),y

        lda     tempShortestDistanceX
        cmp     #$ff
        beq     continueUpdateHomingY
        ; Dir at closest enemy
        ldy     closestEnemyIndex
        lda     homingX,x
        clc
        adc     #12
        cmp     enemyX,y
        bcc     updateHomingEnemyToTheRight

        lda     #$00
        sta     homingXMoveR,x
        lda     homingXMoveL,x
        sec
        sbc     #$01
        sta     homingXMoveL,x
        jmp     continueUpdateHomingY

updateHomingEnemyToTheRight

        lda     #$00
        sta     homingXMoveL,x
        lda     homingXMoveR,x
        clc
        adc     #$01
        sta     homingXMoveR,x
        jmp     continueUpdateHomingY


continueUpdateHomingY

        lda     homingX,x
        clc
        adc     homingXMoveR,x
        clc
        adc     homingXMoveL,x
        sta     homingX,x


        ; Increase Y position
        lda     homingY,x
        sec
        sbc     #bulletSpeed
        sta     homingY,x

        ; Check new positon
        cmp     #$ff
        bcc     checkHomingBound

        jmp     drawHomingCurrentPosition
checkHomingBound
        cmp     #$b9
        bcc     drawHomingCurrentPosition
        ; Homing is offscreen
        lda     #$00
        sta     homings,x

        jmp     drawHomingsLoop

drawHomingCurrentPosition
        ; Draw Current position
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     homingX,x
        clc
        lsr
        lsr
        lsr
        tay



        ; Char
        lda     #$a5
        sta     (tmp1),y

        ; Color
        lda     tmpColor1
        sta     tmp1
        lda     tmpColor2
        sta     tmp2
        lda     #$05
        sta     (tmp1),y

        jmp     drawHomingsLoop
endDrawHomings
        rts

;#######################;
;                       ;
;     SEGTHUNDERBOLT    ;
;                       ;
;#######################;


;
;
;
;
;
InitThunderBolt
        lda     #$00
        sta     thunderBoltCoolDown
        sta     savedThunderBoltX
        sta     savedThunderBoltY
        sta     thunderBoltColorFrame
        rts

;
;
;
;
;
ActivateThunderBolt

        ldx     thunderBoltCoolDown
        cpx     #$00
        bne     endFireThunderBolt

        lda     playerX
        sec
        sbc     #playerWeaponXOffset
        lsr
        lsr
        lsr
        sta     thunderBoltX
        sta     savedThunderBoltX
        lda     playerY
        sec
        sbc     #playerWeaponYOffset
        lsr
        lsr
        lsr
        sta     thunderBoltY

        lda     #thunderBoltCoolDownTime
        sta     thunderBoltCoolDown
        jsr     SfxPlayLaser

endFireThunderBolt
        lda     #thunderBoltDelayTime
        sta     fireDelay

        rts

;
;
;
;
UpdateThunderBolt

        ldx     thunderBoltCoolDown
        cpx     #$00
        beq     dontDecreaseThunderBoltCoolDown
        dex
        stx     thunderBoltCoolDown
dontDecreaseThunderBoltCoolDown

        rts

;
;
;
;
;
DrawThunderBolt
        ldx     thunderBoltCoolDown
        cpx     #$08
        bcs     continueDrawThunderBolt
        cpx     #$07
        bcc     endDrawThunderbolt
        jsr     ResetThunderBolt
        rts

continueDrawThunderBolt
        jsr     ResetThunderBolt

        ldx     thunderBoltColorFrame
        inx
        stx     thunderBoltColorFrame
        cpx     #$10
        bcc     skipResetThunderBoltColorFrame
        ldx     #$00
        stx     thunderBoltColorFrame
skipResetThunderBoltColorFrame

        ldy     thunderBoltY
drawThunderBoltLoop
        sty     savedThunderBoltY

        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     thunderBoltX
        tay
        ldx     thunderBoltFrame
        lda     ThunderBoltLeftFrameTable,x
        sta     (tmp1),y
        iny
        lda     ThunderBoltCenterFrameTable,x
        sta     (tmp1),y
        iny
        cpy     #31
        beq     skipDrawThunderBoltRight
        lda     ThunderBoltRightFrameTable,x
        sta     (tmp1),y

skipDrawThunderBoltRight
        ldy     savedThunderBoltY

        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2

        ldx     thunderBoltColorFrame
        lda     ThunderBoltColorTable,x

        ldy     thunderBoltX
        sta     (tmp1),y
        iny
        sta     (tmp1),y
        iny
        cpy     #31
        beq     skipColorizeThunderBoltRight

        sta     (tmp1),y
skipColorizeThunderBoltRight
        ldy     savedThunderBoltY
        dey
        cpy     #$ff
        bne     drawThunderBoltLoop

        lda     thunderBoltX
        sta     savedThunderBoltX

endDrawThunderbolt
        rts

;
;
;
;
;
ResetThunderBolt
        DrawStraightCol savedThunderBoltX, #$20, #$01
        ldx     savedThunderBoltX
        inx
        stx     savedThunderBoltX
        DrawStraightCol savedThunderBoltX, #$20, #$01
        ldx     savedThunderBoltX
        inx
        cpx     #31
        stx     savedThunderBoltX
        beq     jumpToEndResetThunderBolt
        jmp     resetThunderboltRight
jumpToEndResetThunderBolt
        jmp     endResetThunderBolt
resetThunderboltRight
        DrawStraightCol savedThunderBoltX, #$20, #$01
endResetThunderBolt
        rts



;#######################;
;                       ;
;        SEGBOSS        ;
;                       ;
;#######################;

;
; Per-level boss (levelIndex): boss1 2x2 ($90), boss2 3x2 ($94), boss3 2x2 ($9a).
; Hardware sprites slots 2–7 / $47fa–$47ff (up to 6 parts). Jet stays on slot 1.
; Flow: Warning → fly-in → figure-8 + attack script (PAT_WAIT/VOLLEY/LOOP) → death.
; Shots reuse ActivateEnemyWeapons (dx/dy); set startAtBoss=1..3 to skip waves.
;

InitBoss
        lda     #BOSS_STATE_OFF
        sta     bossState
        lda     #$00
        sta     bossX
        sta     bossY
        sta     bossHp
        sta     bossIsHit
        sta     bossHitPart
        sta     bossMovePhase
        sta     bossPathFrac
        sta     bannerExpand
        sta     bannerHoldTimer
        sta     bossFireTimer
        sta     bossPatPtrL
        sta     bossPatPtrH
        rts

StartWarning
        lda     #BOSS_STATE_WARNING
        sta     bossState
        lda     #$00
        sta     bannerExpand
        sta     bannerHoldTimer
        sta     shouldFirePlayerWeapon
        jsr     SfxPlayAlarm
        ; Banner glyphs are mostly black — use asset bgcolor so they stay visible
        lda     $d021
        sta     savedBgColor
        lda     $d020
        sta     savedBorderColor
        lda     #warningBgColor
        sta     $d021
        sta     $d020
        jsr     CopyPetsciiCharset
        lda     #$12                ; screen $4400, ROM PETSCII @$4800
        sta     $d018
        jsr     DrawWarningExpand
        rts

UpdateBoss
        lda     bossState
        cmp     #BOSS_STATE_WARNING
        beq     updateBossWarning
        cmp     #BOSS_STATE_ENTER
        bne     updateBossCheckIdle
        jmp     updateBossEnter
updateBossCheckIdle
        cmp     #BOSS_STATE_IDLE
        bne     endUpdateBossDispatch
        jmp     updateBossIdle
endUpdateBossDispatch
        rts

updateBossWarning
        lda     bannerHoldTimer
        bne     warnHoldPhase
        lda     bannerExpand
        cmp     #warningMaxExpand
        bcs     warnStartHold
        clc
        adc     #$01
        sta     bannerExpand
        jsr     DrawWarningExpand
        rts
warnStartHold
        lda     #warningHoldFrames
        sta     bannerHoldTimer
        rts
warnHoldPhase
        sec
        sbc     #$01
        sta     bannerHoldTimer
        bne     endUpdateBossWarning
        jsr     HideWarningBanner
        lda     #$1c                ; restore game charset
        sta     $d018
        lda     savedBgColor
        sta     $d021
        lda     savedBorderColor
        sta     $d020
        jsr     InitHud
        jsr     StartBoss
endUpdateBossWarning
        rts

; Center-expand blit of Warning2 rows 8–20, cols within radius of col 16 (clip 0–31)
DrawWarningExpand
        lda     #warningCenterCol
        sec
        sbc     bannerExpand
        bcs     warnLeftOk
        lda     #$00
warnLeftOk
        sta     warnColLeft
        lda     #warningCenterCol
        clc
        adc     bannerExpand
        cmp     #$20
        bcc     warnRightOk
        lda     #$1f
warnRightOk
        sta     warnColRight

        lda     #<(warningRowFirst * 40)
        sta     storedX             ; 16-bit asset offset
        lda     #>(warningRowFirst * 40)
        sta     storedY

        lda     #warningRowFirst
        sta     warnRow
warnRowLoop
        ldy     warnRow
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     #<warningScreen
        clc
        adc     storedX
        sta     warnSrc1
        lda     #>warningScreen
        adc     storedY
        sta     warnSrc2

        ldx     warnColLeft
warnColCharLoop
        txa
        tay
        lda     (warnSrc1),y
        sta     (tmp1),y
        inx
        cpx     warnColRight
        bcc     warnColCharLoop
        beq     warnColCharLoop

        ldy     warnRow
        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2

        lda     #<warningColor
        clc
        adc     storedX
        sta     warnSrc1
        lda     #>warningColor
        adc     storedY
        sta     warnSrc2

        ldx     warnColLeft
warnColColorLoop
        txa
        tay
        lda     (warnSrc1),y
        sta     (tmp1),y
        inx
        cpx     warnColRight
        bcc     warnColColorLoop
        beq     warnColColorLoop

        lda     storedX
        clc
        adc     #40
        sta     storedX
        lda     storedY
        adc     #$00
        sta     storedY

        inc     warnRow
        lda     warnRow
        cmp     #warningRowLast+1
        bcc     warnRowLoop
        rts

HideWarningBanner
        lda     #warningRowFirst
        sta     warnRow
hideWarnRowLoop
        ldy     warnRow
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2
        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2
        ldx     #$00
hideWarnColLoop
        txa
        tay
        lda     #$20
        sta     (tmp1),y
        lda     tmpColor1
        sta     warnSrc1
        lda     tmpColor2
        sta     warnSrc2
        lda     #$01
        sta     (warnSrc1),y
        inx
        cpx     #$20
        bcc     hideWarnColLoop
        inc     warnRow
        lda     warnRow
        cmp     #warningRowLast+1
        bcc     hideWarnRowLoop
        rts

StartBoss
        lda     #BOSS_STATE_ENTER
        sta     bossState

        ldx     levelIndex
        lda     BossNumParts,x
        sta     bossPartCount
        lda     BossCenterXTbl,x
        sta     bossCenterX
        sta     bossX
        lda     BossCenterYTbl,x
        sta     bossCenterY
        lda     #bossStartY
        sta     bossY
        lda     BossMaxHpTbl,x
        sta     bossHp

        ; offBase = levelIndex * 6
        txa
        asl
        asl
        sta     bossOffBase
        txa
        asl
        clc
        adc     bossOffBase
        sta     bossOffBase

        lda     #$00
        sta     bossIsHit
        sta     bossHitPart
        sta     bossMovePhase

        ; Sprite pointers $47fa.. for each part
        lda     BossSpriteBase,x
        ldx     #$00
setBossPtrLoop
        sta     $47fa,x
        clc
        adc     #$01
        inx
        cpx     bossPartCount
        bcc     setBossPtrLoop

        ; Individual sprite colors $d029.. + shared MC2 from editor
        ldx     levelIndex
        lda     BossMc2Tbl,x
        sta     $d026
        lda     BossColorTbl,x
        ldx     #$00
setBossColorLoop
        sta     $d029,x
        inx
        cpx     #maxBossParts
        bcc     setBossColorLoop

        jsr     PositionBoss
        jsr     UpdateBossBounds
        jsr     ResetBossPattern
        rts

updateBossEnter
        lda     bossY
        clc
        adc     #bossEnterSpeed
        bcs     bossEnterArrived
        cmp     bossCenterY
        bcc     bossEnterStoreY
        beq     bossEnterArrived
bossEnterArrived
        lda     bossCenterY
        sta     bossY
        lda     bossCenterX
        sta     bossX
        lda     #$00
        sta     bossMovePhase
        sta     bossPathFrac
        lda     #BOSS_STATE_IDLE
        sta     bossState
        jmp     updateBossPosition
bossEnterStoreY
        sta     bossY
updateBossPosition
        jsr     PositionBoss
        jsr     UpdateBossBounds
        rts

updateBossIdle
        jsr     UpdateBossFigure8
        jsr     UpdateBossPattern
        jsr     PositionBoss
        jsr     UpdateBossBounds
        jsr     UpdateBossIsHit
        rts

; Path follow: per-boss table (levelIndex) + lerp by bossPathFrac
UpdateBossFigure8
        jsr     BossPathLerpX
        clc
        adc     bossCenterX
        sta     bossX
        jsr     BossPathLerpY
        clc
        adc     bossCenterY
        sta     bossY
        lda     bossPathFrac
        clc
        adc     #bossPathSpeed
        sta     bossPathFrac
        bcc     endUpdateBossFigure8
        ldx     bossMovePhase
        inx
        txa
        and     #$3f
        sta     bossMovePhase
endUpdateBossFigure8
        rts

; base = levelIndex * 64 (boss 0/1/2 path bank)
BossPathBase
        lda     levelIndex
        asl
        asl
        asl
        asl
        asl
        asl                             ; *64
        rts

; A = lerp(pathX[i], pathX[i+1], frac/256) for current boss
BossPathLerpX
        jsr     BossPathBase
        sta     tmp3                    ; bank base
        clc
        adc     bossMovePhase
        tax
        lda     BossPathXAll,x
        sta     tmp1                    ; a
        lda     bossMovePhase
        clc
        adc     #$01
        and     #$3f
        clc
        adc     tmp3
        tax
        lda     BossPathXAll,x          ; b
        jmp     BossPathLerpFinish
BossPathLerpY
        jsr     BossPathBase
        sta     tmp3
        clc
        adc     bossMovePhase
        tax
        lda     BossPathYAll,x
        sta     tmp1
        lda     bossMovePhase
        clc
        adc     #$01
        and     #$3f
        clc
        adc     tmp3
        tax
        lda     BossPathYAll,x
BossPathLerpFinish
        sec
        sbc     tmp1                    ; delta = b-a (signed)
        sta     tmp2
        lda     tmp1
        sta     storedX                 ; preserve a across mul
        jsr     BossPathMulFrac         ; A = (delta * frac) >> 8
        clc
        adc     storedX
        rts

; A = high byte of signed tmp2 * unsigned bossPathFrac
BossPathMulFrac
        lda     tmp2
        bmi     bossPathMulNeg
        sta     tmp3
        jmp     bossPathMulU
bossPathMulNeg
        eor     #$ff
        clc
        adc     #$01
        sta     tmp3
        jsr     bossPathMulU
        eor     #$ff
        clc
        adc     #$01
        rts
bossPathMulU
        ; unsigned 8x8 → 16, return hi (tmp3 * bossPathFrac)
        lda     #$00
        sta     tmp1                    ; prodL
        sta     storedY                 ; prodH
        lda     tmp3
        sta     tmpColor1               ; mulA lo
        lda     #$00
        sta     tmpColor2               ; mulA hi
        ldx     #$08
        lda     bossPathFrac
bossPathMulLoop
        lsr
        bcc     bossPathMulSkip
        tay
        lda     tmp1
        clc
        adc     tmpColor1
        sta     tmp1
        lda     storedY
        adc     tmpColor2
        sta     storedY
        tya
bossPathMulSkip
        asl     tmpColor1
        rol     tmpColor2
        dex
        bne     bossPathMulLoop
        lda     storedY
        rts

; Path tables at *=$5d00 (BossPath0/1/2 X+Y) — see end of file.

;---------------------------------------------------------------
; Boss attack scripts — same shot pipeline as enemy type 03
; (ActivateEnemyWeapons + dx/dy). Future angles = more volley rows.
;---------------------------------------------------------------

ResetBossPattern
        ldx     levelIndex
        lda     BossPatStartL,x
        sta     bossPatPtrL
        lda     BossPatStartH,x
        sta     bossPatPtrH
        lda     #$00
        sta     bossFireTimer
        rts

UpdateBossPattern
        lda     bossFireTimer
        beq     bossPatExec
        dec     bossFireTimer
        rts
bossPatExec
        lda     bossPatPtrL
        sta     tmp1
        lda     bossPatPtrH
        sta     tmp2
        ldy     #$00
        lda     (tmp1),y
        cmp     #PAT_WAIT
        beq     bossPatWait
        cmp     #PAT_VOLLEY
        beq     bossPatVolley
        cmp     #PAT_LOOP
        beq     bossPatLoop
        rts                             ; unknown → stop
bossPatWait
        iny
        lda     (tmp1),y
        sta     bossFireTimer
        lda     #$02
        jmp     BossPatAdvance
bossPatLoop
        jmp     ResetBossPattern
bossPatVolley
        iny
        lda     (tmp1),y
        sta     tmp3                    ; shot count
        lda     #$02
        jsr     BossPatAdvance
bossPatVolleyLoop
        lda     tmp3
        beq     endBossPatVolley
        lda     bossPatPtrL
        sta     tmp1
        lda     bossPatPtrH
        sta     tmp2
        ldy     #$00
        lda     (tmp1),y
        sta     enemyWeaponStartXSpeed
        iny
        lda     (tmp1),y
        sta     enemyWeaponStartYSpeed
        iny
        lda     (tmp1),y
        sta     enemyWeaponStartType
        ldx     levelIndex
        lda     bossX
        clc
        adc     BossShotOriginX,x
        sta     enemyWeaponStartX
        lda     bossY
        clc
        adc     BossShotOriginY,x
        sta     enemyWeaponStartY
        jsr     ActivateEnemyWeapons
        lda     #$03
        jsr     BossPatAdvance
        dec     tmp3
        bne     bossPatVolleyLoop
endBossPatVolley
        rts

; A = bytes to skip in bossPatPtr
BossPatAdvance
        clc
        adc     bossPatPtrL
        sta     bossPatPtrL
        bcc     endBossPatAdvance
        inc     bossPatPtrH
endBossPatAdvance
        rts

BossPatStartL
        .byte   <BossPat0,<BossPat1,<BossPat2
BossPatStartH
        .byte   >BossPat0,>BossPat1,>BossPat2

; Boss 1: 3-way like type-03, every ~48 frames
BossPat0
        .byte   PAT_WAIT,48
        .byte   PAT_VOLLEY,3
        .byte   $fe,$02,$97
        .byte   $00,$03,$97
        .byte   $02,$02,$97
        .byte   PAT_LOOP

; Boss 2: 5-way fan, slightly faster
BossPat1
        .byte   PAT_WAIT,40
        .byte   PAT_VOLLEY,5
        .byte   $fc,$02,$97
        .byte   $fe,$03,$97
        .byte   $00,$04,$97
        .byte   $02,$03,$97
        .byte   $04,$02,$97
        .byte   PAT_LOOP

; Boss 3: 4-way, faster cadence
BossPat2
        .byte   PAT_WAIT,36
        .byte   PAT_VOLLEY,4
        .byte   $fd,$02,$97
        .byte   $ff,$03,$97
        .byte   $01,$03,$97
        .byte   $03,$02,$97
        .byte   PAT_LOOP

PositionBoss
        ldx     #$00
positionBossLoop
        cpx     bossPartCount
        bcs     positionBossClearRest
        txa
        asl                             ; Y = part * 2 (xy register index)
        tay
        stx     storedX
        lda     bossOffBase
        clc
        adc     storedX
        tax
        lda     bossX
        clc
        adc     BossOffX,x
        bcc     positionBossXOk
        lda     #$ff                ; clamp — avoid 8-bit wrap to left edge
positionBossXOk
        sta     $d004,y
        lda     bossY
        clc
        adc     BossOffY,x
        sta     $d005,y
        ldx     storedX
        inx
        bne     positionBossLoop
positionBossClearRest
        cpx     #maxBossParts
        bcs     endPositionBoss
        txa
        asl
        tay
        lda     #$00
        sta     $d004,y
        sta     $d005,y
        inx
        bne     positionBossClearRest
endPositionBoss
        rts

UpdateBossBounds
        ldx     #$00
updateBossBoundsLoop
        cpx     bossPartCount
        bcs     endUpdateBossBounds
        stx     storedX
        lda     bossOffBase
        clc
        adc     storedX
        tay
        lda     bossY
        clc
        adc     BossOffY,y
        sec
        sbc     #32
        sta     bossBoundY2,x
        sec
        sbc     #16
        sta     bossBoundY1,x
        lda     bossX
        clc
        adc     BossOffX,y
        sec
        sbc     #$06
        sta     bossBoundX2,x
        sec
        sbc     #24
        sta     bossBoundX1,x
        inx
        bne     updateBossBoundsLoop
endUpdateBossBounds
        rts

UpdateBossIsHit
        lda     bossIsHit
        beq     endUpdateBossIsHit
        lda     #$00
        sta     bossIsHit

        lda     bossOffBase
        clc
        adc     bossHitPart
        tax
        lda     bossX
        clc
        adc     BossOffX,x
        sta     explosionStartX
        lda     bossY
        clc
        adc     BossOffY,x
        sta     explosionStartY
        jsr     ActivateExplosion

        jsr     GetWeaponDamage
        sta     scoreAdd
        jsr     IncreaseScore

        lda     bossHp
        sec
        sbc     scoreAdd
        bcs     bossHpStore
        lda     #$00
bossHpStore
        sta     bossHp
        beq     bossKilled
        rts
bossKilled
        lda     #BOSS_STATE_DONE
        sta     bossState
        lda     #$00
        sta     bossIsHit
        jsr     ClearBossSprites
        jsr     EnterLevelClearing
endUpdateBossIsHit
        rts

HideBoss
        lda     #BOSS_STATE_OFF
        sta     bossState
        lda     #$00
        sta     bossHp
        sta     bossIsHit
ClearBossSprites
        lda     #$00
        sta     $d004
        sta     $d005
        sta     $d006
        sta     $d007
        sta     $d008
        sta     $d009
        sta     $d00a
        sta     $d00b
        sta     $d00c
        sta     $d00d
        sta     $d00e
        sta     $d00f
        ; Restore player MC2 (boss temporarily owns $d026)
        lda     #$0c
        sta     $d026
        rts

warningScreen
        .binary "petskii/Warning2_screen.seq"
warningColor
        .binary "petskii/Warning2_color.seq"

;#######################;
;                       ;
;       SEGENEMY        ;
;                       ;
;#######################;



;
;
;
;
;
InitEnemies

        ldx     #$00
        lda     #$ff
iniEnemiesLoop1
        sta     activeEnemies,x
        sta     enemyBoundX1,x
        sta     enemyBoundY1,x
        sta     enemyBoundX2,x
        sta     enemyBoundY2,x

        inx
        cpx     #maxActiveEnemies
        bcc     iniEnemiesLoop1

        ldx     #$00
        lda     #$00
initEnemiesLoop2
        sta     enemies,x
        sta     enemyX,x
        sta     enemyY,x
        sta     enemyIsHit,x
        sta     enemyHitPoints,x
        sta     enemySpriteFrameCounter,x
        sta     enemySpriteFrame,x
        sta     enemyMoveX,x
        sta     enemyMoveY,x
        sta     enemyPhase,x
        inx
        cpx     #totalEnemies
        bcc     initEnemiesLoop2

;        lda     #$08
;        ldx     #$00
;initEnemiesLoop3
;        inx
;        cpx     #totalEnemies
;        bcc     initEnemiesLoop3

        lda     #$00
        sta     enemyTickPointer
        sta     activeEnemyPointer
        sta     tmpActiveEnemiesPointer
        sta     enemyToActivate

        jsr     InitEnemyWeapons


; Sprites
        ; Enemy Sprite1
        lda     #$86
        sta     $47fa
        ; Enemy Sprite2
        lda     #$85
        sta     $47fb
        ; Enemy Sprite3
        lda     #$86
        sta     $47fc
        ; Enemy Sprite4
        lda     #$85
        sta     $47fd
        ; Enemy Sprite5
        lda     #$86
        sta     $47fe
        ; Enemy Sprite6
        lda     #$85
        sta     $47ff

        ; Default enemy slot colors (overwritten per-spawn via EnemyColor)
        lda     #$02
        ldx     #$00
initEnemyColorLoop
        sta     $d029,x
        inx
        cpx     #maxBossParts
        bcc     initEnemyColorLoop

        rts

;
;
;
;
;
UpdateEnemies
        jsr     UpdateEnemyType
        jsr     PositionEnemySprite
        jsr     UpdateEnemyBounds
        jsr     UpdateEnemyWeapons
        jsr     DrawEnemyWeapons
        jsr     UpdateEnemyIsHit
        jsr     UpdateClosestEnemy
        rts

;
;
;
;
;
UpdateEnemyType
        ldx     #$ff
updateEnemyTypeLoop
        inx
        cpx     #maxActiveEnemies
        bcs     endUpdateEnemyType

        lda     activeEnemies,x
        cmp     #$ff
        beq     updateEnemyTypeLoop

        tay

        lda     enemies,y
        cmp     #$01
        bne     updateEnemyTypeLoop

; General enemy update
        lda     enemyX,y
        clc
        adc     enemyMoveX,y
        sta     enemyX,y

        lda     enemyY,y
        clc
        adc     enemyMoveY,y
        sta     enemyY,y


        lda     enemyY,y
        cmp     #playerYMax
        bcc     enemyAboveYMax

        lda     #$00
        sta     enemies,y
        sta     enemyX,y
        sta     enemyY,y
        sta     enemyBoundX1,x
        sta     enemyBoundY1,x
        sta     enemyBoundX2,x
        sta     enemyBoundY2,x
        sta     enemyMoveY,y
        sta     enemyMoveY,y
        lda     #$ff
        sta     activeEnemies,x
enemyAboveYMax


        ; Get the enemy type and update depending on that

        lda     EnemyType,y
        cmp     #$01
        beq     startUpdateEnemyType01
        cmp     #$02
        beq     startUpdateEnemyType02
        cmp     #$03
        beq     startUpdateEnemyType03
        cmp     #$04
        beq     startUpdateEnemyType04
        jmp     doneUpdateEnemyType

startUpdateEnemyType01
        jsr     UpdateEnemyType01
        jmp     doneUpdateEnemyType

startUpdateEnemyType02
        jsr     UpdateEnemyType02
        jmp     doneUpdateEnemyType

startUpdateEnemyType03
        jsr     UpdateEnemyType03
        jmp     doneUpdateEnemyType

startUpdateEnemyType04
        jsr     UpdateEnemyType04
        jmp     doneUpdateEnemyType

doneUpdateEnemyType


        jmp     updateEnemyTypeLoop
endUpdateEnemyType
        rts


;###################################;
; Individual enemy types depends on ;
;  X being index in activeEnemies   ;
;  and Y being totalEnemies index   ;
; Afterwards x == x but y != y      ;
;###################################;


;
;
;
;
;
UpdateEnemyType01

        lda     #$01
        sta     enemyMoveY,y

        lda     enemySpriteFrameCounter,y
        clc
        adc     #$01
        sta     enemySpriteFrameCounter,y
        cmp     #$06 ; enemyFrameTime??
        bcc     doneUpdateEnemy01Sprite

        lda     #$00
        sta     enemySpriteFrameCounter,y

        lda     enemySpriteFrame,y
        clc
        adc     #$01
        sta     enemySpriteFrame,y
        cmp     #$04; Enemy01TotalFrames??
        bcc     doneUpdateEnemy01Sprite

        lda     #$00
        sta     enemySpriteFrame,y
doneUpdateEnemy01Sprite

        lda     enemySpriteFrame,y
        tay
        lda     EnemyFrameTable,y
        sta     $47fa,x
        rts

;
;
;
;
;
UpdateEnemyType02

        lda     enemyPhase,y
        cmp     #$01
        beq     enemy02Kamikaze

        ; --- PHASE_ALIGN: sidledes mot spelaren ---
        lda     #$89
        sta     $47fa,x
        lda     #$00
        sta     enemyMoveX,y
        lda     #enemy02AlignSpeedY
        sta     enemyMoveY,y

        ; Skippa sidtracking om redan under/vid spelarens Y
        lda     enemyY,y
        cmp     playerBoundY2
        bcs     doneUpdateEnemy02Pos

        ; Fiende till höger om spelaren → rör vänster
        lda     enemyBoundX1,x
        cmp     playerBoundX2
        bcc     enemy02CheckLeft

        lda     #$fe
        sta     enemyMoveX,y
        lda     #$8a
        sta     $47fa,x
        jmp     doneUpdateEnemy02Pos

enemy02CheckLeft
        ; Fiende till vänster om spelaren → rör höger
        lda     enemyBoundX2,x
        cmp     playerBoundX1
        bcs     enemy02TriggerKamikaze

        lda     #$02
        sta     enemyMoveX,y
        lda     #$8b
        sta     $47fa,x
        jmp     doneUpdateEnemy02Pos

        ; X-overlap = framför spelaren → kamikaze (kräver ~20% ner i Y)
enemy02TriggerKamikaze
        lda     enemyY,y
        cmp     #enemy02KamikazeMinY
        bcc     doneUpdateEnemy02Pos    ; för högt upp — fortsätt align (X redan 0)

        lda     #$01
        sta     enemyPhase,y
        ; fall through till dyk denna frame

enemy02Kamikaze
        lda     #$00
        sta     enemyMoveX,y
        lda     #enemy02DiveSpeed
        sta     enemyMoveY,y
        lda     #$89            ; neutral dive-frame (byt om ni har egen)
        sta     $47fa,x

doneUpdateEnemy02Pos
        rts


;
;
;
;
;
UpdateEnemyType03

        lda     enemyY,y
        cmp     #$40
        bne     enemyMoveDown03
        ; Shoot a bullet in the players general direction
        stx     storedX

        lda     enemyY,y
        sec
        sbc     #$16
        sta     enemyWeaponStartY
        lda     enemyX,y
        sec
        sbc     #$08
        sta     enemyWeaponStartX

        lda     #$fe
        sta     enemyWeaponStartXSpeed
        lda     #$02
        sta     enemyWeaponStartYSpeed
        lda     #$97
        sta     enemyWeaponStartType
        jsr     ActivateEnemyWeapons

        lda     #$00
        sta     enemyWeaponStartXSpeed
        lda     #$04
        sta     enemyWeaponStartYSpeed
        lda     #$97
        sta     enemyWeaponStartType
        jsr     ActivateEnemyWeapons

        lda     #$02
        sta     enemyWeaponStartXSpeed
        lda     #$02
        sta     enemyWeaponStartYSpeed
        lda     #$97
        sta     enemyWeaponStartType
        jsr     ActivateEnemyWeapons
        ldx     storedX

enemyMoveDown03
        lda     #$01
        sta     enemyMoveY,y

endUpdateEnemy03Move
        lda     #$8c
        sta     $47fa,x

        rts

;
; Asteroid — diagonal down-right; phase0=tumble astro_1, phase1=static astro_2
;
UpdateEnemyType04
        ; Velocity set once at ActivateEnemy (AstroDir*)

        lda     enemyPhase,y
        bne     astroStaticSprite

        lda     enemySpriteFrameCounter,y
        clc
        adc     #$01
        sta     enemySpriteFrameCounter,y
        cmp     #astroAnimSpeed
        bcc     astroSetSprite
        lda     #$00
        sta     enemySpriteFrameCounter,y
        lda     enemySpriteFrame,y
        clc
        adc     #$01
        sta     enemySpriteFrame,y
        cmp     #astroAnimFrames
        bcc     astroSetSprite
        lda     #$00
        sta     enemySpriteFrame,y
astroSetSprite
        lda     enemySpriteFrame,y
        stx     storedX
        tax
        lda     AstroFrameTable,x
        ldx     storedX
        sta     $47fa,x
        jmp     astroCheckDespawn

astroStaticSprite
        lda     #astroFrameStatic
        sta     $47fa,x

astroCheckDespawn
        ; Despawn off left or right edge (Y handled by playerYMax above)
        lda     enemyX,y
        cmp     #astroXDespawnL
        bcc     astroDespawn
        cmp     #astroXDespawnR
        bcc     endUpdateEnemyType04
astroDespawn
        lda     #$00
        sta     enemies,y
        sta     enemyX,y
        sta     enemyY,y
        sta     enemyBoundX1,x
        sta     enemyBoundY1,x
        sta     enemyBoundX2,x
        sta     enemyBoundY2,x
        sta     enemyMoveX,y
        sta     enemyMoveY,y
        lda     #$ff
        sta     activeEnemies,x
endUpdateEnemyType04
        rts

;
;
;
;
;
PositionEnemySprite
        
        ldx     #$ff

        inx
        lda     activeEnemies,x
        cmp     #$ff
        beq     dontSetEnemySpriteNext1
        tay
        lda     enemies,y
        cmp     #$01
        bne     dontSetEnemySpriteNext1
        lda     enemyX,y
        sta     $d004
        lda     enemyY,y
        sta     $d005
        jmp     setEnemySpriteNext1     
dontSetEnemySpriteNext1
        lda     #$00
        sta     $d004
        sta     $d005
setEnemySpriteNext1
        inx
        lda     activeEnemies,x
        cmp     #$ff
        beq     dontSetEnemySpriteNext2
        tay
        lda     enemies,y
        cmp     #$01
        bne     dontSetEnemySpriteNext2
        lda     enemyX,y
        sta     $d006
        lda     enemyY,y
        sta     $d007
        jmp     setEnemySpriteNext2 
dontSetEnemySpriteNext2
        lda     #$00
        sta     $d006
        sta     $d007
setEnemySpriteNext2
        inx
        lda     activeEnemies,x
        cmp     #$ff
        beq     dontSetEnemySpriteNext3
        tay
        lda     enemies,y
        cmp     #$01
        bne     dontSetEnemySpriteNext3
        lda     enemyX,y
        sta     $d008
        lda     enemyY,y
        sta     $d009
        jmp     setEnemySpriteNext3 
dontSetEnemySpriteNext3
        lda     #$00
        sta     $d008
        sta     $d009
setEnemySpriteNext3
        inx
        lda     activeEnemies,x
        cmp     #$ff
        beq     dontSetEnemySpriteNext4
        tay
        lda     enemies,y
        cmp     #$01
        bne     dontSetEnemySpriteNext4
        lda     enemyX,y
        sta     $d00a
        lda     enemyY,y
        sta     $d00b
        jmp     setEnemySpriteNext4 
dontSetEnemySpriteNext4
        lda     #$00
        sta     $d00a
        sta     $d00b
setEnemySpriteNext4
        inx
        lda     activeEnemies,x
        cmp     #$ff
        beq     dontSetEnemySpriteNext5
        tay
        lda     enemies,y
        cmp     #$01
        bne     dontSetEnemySpriteNext5
        lda     enemyX,y
        sta     $d00c
        lda     enemyY,y
        sta     $d00d
        jmp     setEnemySpriteNext5 
dontSetEnemySpriteNext5
        lda     #$00
        sta     $d00c
        sta     $d00d
setEnemySpriteNext5
        inx
        lda     activeEnemies,x
        cmp     #$ff
        beq     dontSetEnemySpriteNext6
        tay
        lda     enemies,y
        cmp     #$01
        bne     dontSetEnemySpriteNext6
        lda     enemyX,y
        sta     $d00e
        lda     enemyY,y
        sta     $d00f
        jmp     setEnemySpriteNext6 
dontSetEnemySpriteNext6
        lda     #$00
        sta     $d00e
        sta     $d00f
setEnemySpriteNext6

        rts

;
;
;
;
;
UpdateEnemyBounds
        ldx     #$ff
updateEnemyBoundsLoop
        inx
        cpx     #maxActiveEnemies
        bcs     endUpdateEnemyBounds

        lda     activeEnemies,x
        cmp     #$ff
        beq     updateEnemyBoundsLoop

        tay
        lda     enemies,y
        cmp     #$01
        bne     updateEnemyBoundsLoop

        lda     enemyY,y
        sec
        sbc     #32
        sta     enemyBoundY2,x
        sec
        sbc     #16
        sta     enemyBoundY1,x

        lda     enemyX,y
        sec
        sbc     #$06
        sta     enemyBoundX2,x
        sec
        sbc     #24
        sta     enemyBoundX1,x

        jmp     updateEnemyBoundsLoop
endUpdateEnemyBounds
        rts

;
;
;
;
;
UpdateEnemyIsHit

        ldx     #$ff
updateEnemyIsHitLoop
        inx
        cpx     #maxActiveEnemies
        bcc     updateEnemyIsHitContinue
        jmp     endUpdateEnemyIsHit
updateEnemyIsHitContinue

        lda     activeEnemies,x
        cmp     #$ff
        beq     updateEnemyIsHitLoop

        tay
        lda     enemies,y
        cmp     #$01
        bne     updateEnemyIsHitLoop

        lda     enemyIsHit,y
        cmp     #$01
        bne     updateEnemyIsHitLoop

        stx     storedX

        lda     enemyX,y
        sta     explosionStartX
        lda     enemyY,y
        sta     explosionStartY
        jsr     ActivateExplosion

        jsr     GetWeaponDamage
        sta     playerWeaponPower
        sta     scoreAdd
        jsr     IncreaseScore
        ldx     storedX

        lda     #$00
        sta     enemyIsHit,y

        lda     enemyHitPoints,y
        clc
        adc     playerWeaponPower
        sta     enemyHitPoints,y
        cmp     EnemyLife,y
        bcc     updateEnemyIsHitLoop
        ; Enemy is dead — decay level; drops skip asteroids
        stx     storedX
        jsr     TickWeaponDecay
        ldx     storedX
        lda     EnemyType,y
        cmp     #$04
        beq     enemyDeadNoDrop
        lda     dropKillCount
        clc
        adc     #$01
        sta     dropKillCount
        cmp     #dropEveryKills
        bcc     enemyDeadDropDone
        lda     #$00
        sta     dropKillCount
        lda     drops                  ; max 1 — skip if already live
        bne     enemyDeadDropDone
        lda     enemyX,y
        sta     dropStartX
        lda     enemyY,y
        sta     dropStartY
        jsr     ActivateDrop
enemyDeadDropDone
        ldx     storedX
enemyDeadNoDrop
        lda     #$00
        sta     enemyX,y
        sta     enemyY,y
        sta     enemies,y
        sta     enemyBoundX1,x
        sta     enemyBoundY1,x
        sta     enemyBoundX2,x
        sta     enemyBoundY2,x
        lda     #$ff
        sta     activeEnemies,x
        
        jmp     updateEnemyIsHitLoop
endUpdateEnemyIsHit
        rts


;
;
;       Sets closestEnemyIndex
;
;
UpdateClosestEnemy

        ldx     #$ff
        stx     tempShortestDistanceX
        ;stx     tempShortestDistanceY
updateClosestEnemyLoop
        inx
        cpx     #maxActiveEnemies
        bcs     endUpdateClosestEnemy
        lda     activeEnemies,x
        tay
        lda     enemies,y
        cmp     #$01
        bne     updateClosestEnemyLoop

        lda     enemyX,y
        cmp     playerX
        bcc     checkEnemyXSmaller
        ; Enemy is at the right of player
        sec
        sbc     playerX
        cmp     tempShortestDistanceX
        bcs     updateClosestEnemyLoop
        sta     tempShortestDistanceX
        sty     closestEnemyIndex
        jmp     updateClosestEnemyLoop

checkEnemyXSmaller
        lda     playerX
        sec
        sbc     enemyX,y
        cmp     tempShortestDistanceX
        bcs     updateClosestEnemyLoop
        sta     tempShortestDistanceX
        sty     closestEnemyIndex
        jmp     updateClosestEnemyLoop

endUpdateClosestEnemy

        rts


;
;
;       Runs each tick
;
;
TickEnemies

        ldx     enemyTickPointer
        
tickEnemiesLoop
        cpx     levelEnemyEnd
        bcs     endTickEnemies
        lda     enemyStartTick,x
        sec
        sbc     levelTickBase       ; relative to level start
        cmp     ticks
        beq     tickEnemiesActivate ; spawn on matching tick
        bcs     endTickEnemies      ; not yet
tickEnemiesActivate
        stx     enemyToActivate
        jsr     ActivateEnemy
        bcs     endTickEnemies              ; overflow → tickHalt set
        ldx     enemyTickPointer
        inx
        stx     enemyTickPointer
        jmp     tickEnemiesLoop

endTickEnemies
        rts

;
;
;       Activates enemy id in enemyToActivate.
;       C=0 ok, C=1 no free active slot (tickHalt set when not in rush).
;
ActivateEnemy
        ldx     #$ff
activateEnemyLoop
        inx
        cpx     #maxActiveEnemies
        bcs     ActiveEnemiesOverFlow

        lda     activeEnemies,x
        cmp     #$ff
        bne     activateEnemyLoop
        
        ldy     enemyToActivate
        lda     #$01
        sta     enemies,y
        lda     #$00
        sta     enemyPhase,y
        tya
        sta     activeEnemies,x
        ; Sprite slot X color from EnemyColor[enemy index]
        lda     EnemyColor,y
        sta     $d029,x
        lda     EnemyType,y
        cmp     #$04
        beq     activateEnemyAstroX
        lda     enemyStartX,y
        jmp     activateEnemyStoreX
activateEnemyAstroX
        ; Random tumble (phase=0) vs static; random dir from AstroDir*; X from level
        stx     storedX
        jsr     UpdateRNG24
        lda     rng24
        and     #$01
        sta     enemyPhase,y
        jsr     UpdateRNG24
        lda     rng24
        and     #$03                ; 4 directions
        tax
        lda     AstroDirX,x
        sta     enemyMoveX,y
        lda     AstroDirY,x
        sta     enemyMoveY,y
        ldx     storedX
        lda     enemyStartX,y
        jmp     activateEnemyStoreX
activateEnemyStoreX
        sta     enemyX,y
        lda     enemyStartY,y
        sta     enemyY,y
        clc
        rts

ActiveEnemiesOverFlow
        ; Was: sta $d021 #$06 (painted level bg blue). Keep spawn throttle only.
        lda     inBossRush
        bne     activateEnemyFail
        lda     #$01
        sta     tickHalt
        ldx     ticks
        dex
        stx     ticks
activateEnemyFail
        sec
        rts



;#######################;
;                       ;
;   SEGENEMYWEAPON      ;
;                       ;
;#######################;

;
;
;
;
;
InitEnemyWeapons
        lda     #$00
        ldx     #$00
initEnemyWeaponsLoop
        sta     enemyWeapons,x
        sta     enemyWeaponX,x
        sta     enemyWeaponY,x
        sta     enemyWeaponXSpeed,x
        sta     enemyWeaponYSpeed,x
        sta     enemyWeaponType,x
        sta     enemyWeaponToRemove,x
        inx
        cpx     #maxEnemyWeapons
        bcc     initEnemyWeaponsLoop

        rts

;
;
;
;
;
ActivateEnemyWeapons
        ldx     #$ff
findInactiveEnemyWeaponLoop
        inx
        cpx     #maxEnemyWeapons
        bcs     endActivateEnemyWeapons

        lda     enemyWeapons,x
        cmp     #$00
        bne     findInactiveEnemyWeaponLoop

        lda     enemyWeaponStartX
        sta     enemyWeaponX,x

        lda     enemyWeaponStartY
        sta     enemyWeaponY,x

        lda     enemyWeaponStartXSpeed
        sta     enemyWeaponXSpeed,x

        lda     enemyWeaponStartYSpeed
        sta     enemyWeaponYSpeed,x

        lda     enemyWeaponStartType
        sta     enemyWeaponType,x

        lda     #$00
        sta     enemyWeaponToRemove,x

        lda     #$01
        sta     enemyWeapons,x

endActivateEnemyWeapons
        rts

;
;
;
;
;
UpdateEnemyWeapons
        ldx     #$ff
updateEnemyWeaponsLoop
        inx
        cpx     #maxEnemyWeapons
        bcs     jumpToEndUpdateEnemyWeapons
        jmp     startUpdateEnemyWeapons

jumpToEndUpdateEnemyWeapons
        jmp     endUpdateEnemyWeapons

startUpdateEnemyWeapons
        lda     enemyWeapons,x
        cmp     #$01
        bne     updateEnemyWeaponsLoop

        lda     enemyWeaponY,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     enemyWeaponX,x
        clc
        lsr
        lsr
        lsr
        tay

        lda     #$20
        sta     (tmp1),y

        lda     tmpColor1
        sta     tmp1
        lda     tmpColor2
        sta     tmp2
        lda     #$01
        sta     (tmp1),y
        
        lda     enemyWeaponToRemove,x
        cmp     #$01
        bne     continueUpdateEnemyWeapons

        lda     #$00
        sta     enemyWeapons,x
        sta     enemyWeaponToRemove,x

        jmp     updateEnemyWeaponsLoop
continueUpdateEnemyWeapons

        lda     enemyWeaponX,x
        clc
        adc     enemyWeaponXSpeed,x
        sta     enemyWeaponX,x
        cmp     #248
        bcs     inactivateEnemyWeapon
        cmp     #08
        bcc     inactivateEnemyWeapon

        lda     enemyWeaponY,x
        clc
        adc     enemyWeaponYSpeed,x
        sta     enemyWeaponY,x
        cmp     #192
        bcs     inactivateEnemyWeapon
        cmp     #08
        bcc     inactivateEnemyWeapon
        jmp     updateEnemyWeaponsLoop

inactivateEnemyWeapon
        lda     #$00
        sta     enemyWeapons,x
        sta     enemyWeaponX,x
        sta     enemyWeaponY,x
        sta     enemyWeaponXSpeed,x
        sta     enemyWeaponYSpeed,x
        sta     enemyWeaponType,x
        sta     enemyWeaponToRemove,x
        jmp     updateEnemyWeaponsLoop
endUpdateEnemyWeapons

        rts

;
;
;
;
;
DrawEnemyWeapons
        ldx     #$ff
drawEnemyWeaponsLoop
        inx
        cpx     #maxEnemyWeapons
        bcs     endDrawEnemyWeapons

        lda     enemyWeapons,x
        cmp     #$01
        bne     drawEnemyWeaponsLoop

        lda     enemyWeaponY,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     enemyWeaponX,x
        clc
        lsr
        lsr
        lsr
        tay

        lda     enemyWeaponType,x
        sta     (tmp1),y

        lda     tmpColor1
        sta     tmp1
        lda     tmpcolor2
        sta     tmp2

        lda     #$0a
        sta     (tmp1),y

        jmp     drawEnemyWeaponsLoop
endDrawEnemyWeapons
        rts


;#######################;
;                       ;
;      SEGTHINGS        ;
;                       ;
;#######################;

;
;
;
;
InitThings
        jsr     InitDrops
        jsr     InitExplosions
        jsr     InitStarField
        jsr     InitHud
        rts

UpdateThings

        jsr     UpdateDrops
        jsr     UpdateExplosion
        jsr     UpdateStarField

        jsr     DrawThings
        rts

DrawThings
        jsr     DrawExplosion
        jsr     DrawDrops
        jsr     DrawStarField
        rts


;#######################;
;                       ;
;       SEGDROPS        ;
;   (relocated $c500)   ;
;#######################;


;#######################;
;                       ;
;     SEGEXPLOSIONS     ;
;                       ;
;#######################;

;
;
;
;
InitExplosions
        lda     #$00
        ldx     #$00
initExplosionsLoop
        sta     explosions,x
        sta     explosionsX,x
        sta     explosionsY,x
        sta     explosionCounters,x
        sta     explosionFrames,x
        sta     explosionCurrentFrame,x
        sta     explosionColorFrame,x

        inx
        cpx     #maxExplosions
        bcc     initExplosionsLoop

        rts

;
;
;
;
;
ActivateExplosion
        ldx     #$ff
activateExplosionLoop
        inx
        cpx     #maxExplosions
        bcs     endActivateExplosions
        lda     explosions,x

        cmp     #$00
        bne     activateExplosionLoop

        lda     #$00
        sta     explosionCurrentFrame,x
        sta     explosionCounters,x
        sta     explosionFrames,x
        lda     #$01
        sta     explosions,x

        lda     explosionStartX
        sec
        sbc     #explosionXOffset
        bcs     expXShift
        lda     #$00
        beq     expXStore
expXShift
        lsr
        lsr
        lsr
expXStore
        cmp     #38
        bcc     expXInRange
        lda     #37
expXInRange
        sta     explosionsX,x
        lda     explosionStartY
        sec
        sbc     #explosionYOffset
        bcs     expYShift
        lda     #$00
        beq     expYStore
expYShift
        lsr
        lsr
        lsr
expYStore
        cmp     #23
        bcc     expYInRange
        lda     #22
expYInRange
        sta     explosionsY,x
        jsr     SfxPlayExplosion

endActivateExplosions
        rts

;
;
;
;
;
UpdateExplosion
        ldx     #$ff
updateExplosionLoop
        inx
        cpx     #maxExplosions
        bcs     endUpdateExplosion

        lda     explosions,x
        cmp     #$01
        bne     updateExplosionLoop
        ; Got one active to update

        lda     explosionCounters,x
        clc
        adc     #$01
        sta     explosionCounters,x
        cmp     #explosionFrameTime
        bcc     updateExplosionLoop

        lda     #$00
        sta     explosionCounters,x

        lda     explosionFrames,x
        clc
        adc     #$01
        sta     explosionFrames,x
        cmp     #explosionFrameMax
        bcc     updateExplosionLoop

        lda     #$00
        sta     explosions,x
        jmp     updateExplosionLoop
endUpdateExplosion
        rts


;
;
;
;
;
DrawExplosion
        ldx     #$ff
drawExplosionLoop
        inx
        cpx     #maxExplosions
        bcs     endDrawExplosionNext

        lda     explosions,x
        cmp     #$01
        bne     drawExplosionLoop
        jmp     continueDrawExplosion

endDrawExplosionNext
        jmp     endDrawExplosion

continueDrawExplosion
        ; Got one see if we should draw it
        lda     explosionCounters,x
        cmp     #$00
        bne     drawExplosionLoop
        ; Got one to draw

        lda     explosionsY,x     ; Y-pos/row
        sta     explosionRow

        lda     explosionsX,x     ; X-pos/col
        sta     explosionCol

        lda     explosionRow
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        stx     storedX
        lda     explosionCurrentFrame,x
        tax

        lda     explosionCol
        tay
        
        ; Top
        lda     explosionTableTopLeft,x
        sta     (tmp1),y

        iny
        lda     explosionTableTopCenter,x
        sta     (tmp1),y

        iny
        lda     explosionTableTopRight,x
        sta     (tmp1),y


        lda     explosionRow
        clc
        adc     #$01
        tay

        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2



        lda     explosionCol
        tay

        ; Middle
        lda     explosionTableMiddleLeft,x
        sta     (tmp1),y

        iny
        lda     explosionTableMiddleCenter,x
        sta     (tmp1),y

        iny
        lda     explosionTableMiddleRight,x
        sta     (tmp1),y


        lda     explosionRow
        clc
        adc     #$02
        tay

        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2



        lda     explosionCol
        tay

        ; Bottom
        lda     explosionTableBottomLeft,x
        sta     (tmp1),y

        iny
        lda     explosionTableBottomCenter,x;#$02
        sta     (tmp1),y

        iny
        lda     explosionTableBottomRight,x
        sta     (tmp1),y


        ldx     storedX
        lda     explosionCurrentFrame,x
        adc     #$01
        sta     explosionCurrentFrame,x


        jmp     drawExplosionLoop
endDrawExplosion

        jsr     UpdateExplosionColor
        rts

;
;
;
;
;
UpdateExplosionColor
        ldx     #$ff
updateExplosionColorLoop
        inx
        cpx     #maxExplosions
        bcs     jumpToendUpdateExplosionColor
        jmp     startUpdateExplosionColor
jumpToendUpdateExplosionColor
        jmp     endUpdateExplosionColor
startUpdateExplosionColor
        lda     explosions,x
        cmp     #$01
        bne     updateExplosionColorLoop

        lda     explosionCounters,x
        cmp     #$00
        bne     updateExplosionColorLoop

        lda     explosionsY,x     ; Y-pos/row
        sta     explosionRow
        tay

        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2

        lda     explosionsX,x     ; X-pos/col
        sta     explosionCol

        tay

        stx     storedX
        lda     explosionCurrentFrame,x
        tax
        
        lda     explosionColorTable,x
        sta     (tmp1),y
        iny
        sta     (tmp1),y
        iny
        sta     (tmp1),y

        lda     explosionRow
        clc
        adc     #$01
        tay

        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2

        ldy     explosionCol
        lda     explosionColorTable,x
        sta     (tmp1),y
        iny
        sta     (tmp1),y
        iny
        sta     (tmp1),y

        lda     explosionRow
        clc
        adc     #$02
        tay

        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2

        ldy     explosionCol
        lda     explosionColorTable,x
        sta     (tmp1),y
        iny
        sta     (tmp1),y
        iny
        sta     (tmp1),y


        ldx     storedX

        jmp     updateExplosionColorLoop


endUpdateExplosionColor
        rts


;#######################;
;                       ;
;     SEGSTARFIELD      ;
;                       ;
;#######################;

;
;
;
;
;
InitStarField
        ldx     #$00
initStarLoop
        lda     #$01
        sta     starField,x
        lda     #$00
        sta     starFrame,x
        inx
        cpx     #maxStars
        bcc     initStarLoop
        
        jsr     RandomizeStars
        rts


;
;
;
;
;
RandomizeStars
        ldx     #$00
randomizeStarsLoop

        jsr     UpdateRNG30

        ldy     rng30
        lda     RNG30TABLE,y
        sta     starX,x

        jsr     UpdateRNG24
        ldy     rng24
        lda     RNG24TABLE,y
        sta     starY,x

        inx
        cpx     #maxStars
        bcc     randomizeStarsLoop

        ldx     #$00
randomizeStarLoop2
        jsr     UpdateRNG30
        ldy     rng30
        lda     RNG30TABLE,y
        cmp     #15
        bcc     setStarColorTo3
        lda     #$01
        jmp     continueRandomizeStarLoop2
setStarColorTo3
        lda     #$0e
continueRandomizeStarLoop2
        sta     starColor,x
        inx
        cpx     #maxStars
        bcc     randomizeStarLoop2
 
        rts

;
;
;
;
;
UpdateStarField
        ldx     #$ff
updateStarFieldLoop
        inx
        cpx     #maxStars
        bcs     endUpdateStarField

        lda     starField,x
        cmp     #$01
        bne     updateStarFieldLoop

        lda     starFrame,x
        clc
        adc     #$01
        sta     starFrame,x
        cmp     #$08
        bcc     skipResetStarFrame

        ldy     starY,x
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2
        ldy     starX,x
        lda     #$20
        sta     (tmp1),y

        ldy     starColor,x
        cpy     #$01
        beq     skipResetStarColor
        
        ldy     starY,x
        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2

        ldy     starX,x
        lda     #$01
        sta     (tmp1),y

        lda     #$01
        sta     starColor,x
        jmp     continueUpdateStarField
skipResetStarColor

        lda     #$0e
        sta     starColor,x

continueUpdateStarField
        lda     #$00
        sta     starFrame,x
        lda     starY,x
        clc
        adc     #$01
        sta     starY,x
        cmp     #$17
        bcc     skipResetStarFrame

        lda     #$00
        sta     starY,x
        jsr     UpdateRNG30
        ldy     rng30
        lda     RNG30TABLE,y
        sta     starX,x



skipResetStarFrame
        jmp     updateStarFieldLoop
endUpdateStarField
        rts

;
;
;
;
;
DrawStarField
        ldx     #$ff
drawStarFieldLoop
        inx
        cpx     #maxStars
        bcs     endDrawStarField

        lda     starField,x
        cmp     #$01
        bne     drawStarFieldLoop

        lda     starY,x
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2
        
        lda     starX,x
        tay
        
        lda     (tmp1),y
        cmp     #$20
        beq     continueDrawStar
        cmp     #$50
        bcc     drawStarFieldLoop
        cmp     #$57
        bcs     drawStarFieldLoop

continueDrawStar

        stx     storedX
        lda     starFrame,x
        tax
        lda     StarFrameTable,x
        sta     (tmp1),y            ; Y still = starX

        ; Restore star index before reading starY/starX/starColor
        ldx     storedX
        ldy     starY,x
        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2
        ldy     starX,x
        lda     starColor,x
        sta     (tmp1),y

        jmp     drawStarFieldLoop

endDrawStarField
        rts


;#######################;
;                       ;
;      SEGINPUT         ;
;                       ;
;#######################;


; DEV: edge-trigger on P via CIA matrix (IRQ uses $ea81 → $cb never updates)
; Matrix: PA5+PB1 = P. Restore $dc00=$ff for joystick after.
PollGodMode
        lda     gameState
        cmp     #STATE_TITLE
        beq     endPollGodMode
        cmp     #STATE_GAMEOVER
        beq     endPollGodMode
        lda     #$df                ; select keyboard column PA5
        sta     $dc00
        lda     $dc01
        and     #$02                ; PB1 = P
        pha
        lda     #$ff                ; restore for joy port 2
        sta     $dc00
        pla
        beq     godKeyDown          ; 0 = pressed
        lda     #$01
        sta     godKeyArmed
        rts
godKeyDown
        lda     godKeyArmed
        beq     endPollGodMode
        lda     #$00
        sta     godKeyArmed
        lda     godMode
        eor     #$01
        sta     godMode
        beq     godKeyHudOnly       ; turned off — keep voided score
        lda     godModeUsed
        bne     godKeyHudOnly       ; already cheated this run
        lda     #$01
        sta     godModeUsed
        jsr     ZeroPlayerScore
godKeyHudOnly
        jsr     UpdateGodModeHud
endPollGodMode
        rts

; HUD: "CHEAT" (red) once used; yellow border while invincible
UpdateGodModeHud
        lda     godModeUsed
        bne     godHudCheat
        lda     #$20
        sta     $4421
        sta     $4422
        sta     $4423
        sta     $4424
        sta     $4425
        jmp     godHudBorder
godHudCheat
        lda     #$03                ; C
        sta     $4421
        lda     #$08                ; H
        sta     $4422
        lda     #$05                ; E
        sta     $4423
        lda     #$01                ; A
        sta     $4424
        lda     #$14                ; T
        sta     $4425
        lda     #$02                ; red
        sta     $d821
        sta     $d822
        sta     $d823
        sta     $d824
        sta     $d825
godHudBorder
        lda     godMode
        beq     godHudBorderLevel
        lda     #$07                ; yellow border while invincible
        sta     $d020
        rts
godHudBorderLevel
        ldx     levelIndex
        lda     levelBorderColor,x
        sta     $d020
        rts

HandleInput     
; Button — locked during Warning (weapons use screen chars)
        lda     bossState
        cmp     #BOSS_STATE_WARNING
        beq     noFire

        lda     $dc00
        and     #$10
        beq     fire
        jmp     noFire
fire

        ldx     canFire
        cpx     #$01
        bne     noFire
        ldy     #$00
        sty     canFire
        lda     #$01
        sta     shouldFirePlayerWeapon

noFire

; Movement
        lda     $dc00
        ldx     #$00
        ldy     #$00
        lsr
        bcs     handleInputNext0
        dey
handleInputNext0
        lsr
        bcs     handleInputNext1
        iny
handleInputNext1
        lsr
        bcs     handleInputNext2
        dex
handleInputNext2
        lsr
        bcs     handleInputNext3
        inx
handleInputNext3
        lsr
        stx     xMoveAmount
        sty     yMoveAmount

; Handle X-Movement
        ldx     #$00
        lda     playerX
xMoveLoop
        clc
        adc     xMoveAmount
        inx
        cpx     playerMoveSpeed
        bcc     xMoveLoop
        ; Clamp player X
        cmp     #playerXMax
        bcc     checkXmin
        lda     #playerXMax
checkXmin
        cmp     #playerXMin
        bcs     saveXMovement
        lda     #playerXMin
saveXMovement
        sta     playerX
        
; Handle Y-Movement
        ldx     #$00
        lda     playerY
yMoveLoop
        clc
        adc     yMoveAmount
        inx
        cpx     playerMoveSpeed
        bcc     yMoveLoop
        ; Clamp player Y
        cmp     #playerYMax
        bcc     checkYmin
        lda     #playerYMax
checkYmin
        cmp     #playerYMin
        bcs     saveYMovement
        lda     #playerYMin
saveYMovement
        sta     playerY

        rts

; Movement only (Warning banner) — fire already blocked via bossState check
HandleInputWarning
        lda     #$00
        sta     shouldFirePlayerWeapon
        jmp     noFire

;#######################;
;                       ;
;     SEGCOLLISION      ;
;                       ;
;#######################;

;
;
;
;
;
CheckForCollision

        jsr     CheckEnemyPlayerCollision
        jsr     CheckEnemyBulletCollision
        jsr     CheckEnemyHomingCollision
        jsr     CheckEnemyThunderBoltCollision
        jsr     CheckPlayerEnemyWeaponCollision
        jsr     CheckBossCollisions
        rts

;
;
;       Boss vs bullets / homing / laser / player (only while IDLE)
;
;
CheckBossCollisions
        lda     bossState
        cmp     #BOSS_STATE_IDLE
        beq     checkBossCollisionsGo
        rts
checkBossCollisionsGo
        jsr     CheckBossBulletCollision
        jsr     CheckBossHomingCollision
        jsr     CheckBossThunderBoltCollision
        jsr     CheckBossPlayerCollision
        rts

CheckBossBulletCollision
        ldy     #$ff
checkBossBulletLoop
        iny
        cpy     #maxBullets
        bcs     endCheckBossBullet
        lda     bullets,y
        cmp     #$01
        bne     checkBossBulletLoop
        sty     storedY

        ; Bottom row parts first, then top
        lda     bossPartCount
        lsr
        sta     tmp3
        tax
checkBossBulletBottom
        cpx     bossPartCount
        bcs     checkBossBulletTop
        jsr     TryBossPartBullet
        bcs     checkBossBulletHit
        inx
        bne     checkBossBulletBottom
checkBossBulletTop
        ldx     #$00
checkBossBulletTopLoop
        cpx     tmp3
        bcs     checkBossBulletLoop
        jsr     TryBossPartBullet
        bcs     checkBossBulletHit
        inx
        bne     checkBossBulletTopLoop
checkBossBulletHit
        ldy     storedY
        lda     #$01
        sta     bulletsToRemove,y
        stx     bossHitPart
        sta     bossIsHit
        jmp     checkBossBulletLoop
endCheckBossBullet
        rts

; X=part, Y=bullet index (also in storedY). C=1 hit, X preserved as part.
TryBossPartBullet
        ldy     storedY
        lda     bossBoundY2,x
        cmp     bulletY,y
        bcc     tryBossPartBulletMiss
        lda     bossBoundY1,x
        cmp     bulletY,y
        bcs     tryBossPartBulletMiss
        lda     bulletX,y
        sec
        sbc     #$04
        sta     tmpBulletXBound
        lda     bossBoundX2,x
        cmp     tmpBulletXBound
        bcc     tryBossPartBulletMiss
        lda     bossBoundX1,x
        cmp     bulletX,y
        bcs     tryBossPartBulletMiss
        sec                     ; hit
        rts
tryBossPartBulletMiss
        clc
        rts

CheckBossHomingCollision
        ldy     #$ff
checkBossHomingLoop
        iny
        cpy     #maxBullets
        bcs     endCheckBossHoming
        lda     homings,y
        cmp     #$01
        bne     checkBossHomingLoop
        sty     storedY

        lda     bossPartCount
        lsr
        sta     tmp3
        tax
checkBossHomingBottom
        cpx     bossPartCount
        bcs     checkBossHomingTop
        jsr     TryBossPartHoming
        bcs     checkBossHomingHit
        inx
        bne     checkBossHomingBottom
checkBossHomingTop
        ldx     #$00
checkBossHomingTopLoop
        cpx     tmp3
        bcs     checkBossHomingLoop
        jsr     TryBossPartHoming
        bcs     checkBossHomingHit
        inx
        bne     checkBossHomingTopLoop
checkBossHomingHit
        ldy     storedY
        lda     #$01
        sta     homingsToRemove,y
        stx     bossHitPart
        sta     bossIsHit
        jmp     checkBossHomingLoop
endCheckBossHoming
        rts

TryBossPartHoming
        ldy     storedY
        lda     bossBoundY2,x
        cmp     homingY,y
        bcc     tryBossPartHomingMiss
        lda     bossBoundY1,x
        cmp     homingY,y
        bcs     tryBossPartHomingMiss
        lda     homingX,y
        sec
        sbc     #$04
        sta     tmpBulletXBound
        lda     bossBoundX2,x
        cmp     tmpBulletXBound
        bcc     tryBossPartHomingMiss
        lda     bossBoundX1,x
        cmp     homingX,y
        bcs     tryBossPartHomingMiss
        sec
        rts
tryBossPartHomingMiss
        clc
        rts

CheckBossThunderBoltCollision
        lda     thunderBoltCoolDown
        cmp     #thunderBoltCoolDownTime
        bne     endCheckBossThunder

        lda     bossPartCount
        lsr
        sta     tmp3
        tax
checkBossThunderBottom
        cpx     bossPartCount
        bcs     checkBossThunderTop
        jsr     TryBossPartThunder
        bcs     checkBossThunderHit
        inx
        bne     checkBossThunderBottom
checkBossThunderTop
        ldx     #$00
checkBossThunderTopLoop
        cpx     tmp3
        bcs     endCheckBossThunder
        jsr     TryBossPartThunder
        bcs     checkBossThunderHit
        inx
        bne     checkBossThunderTopLoop
checkBossThunderHit
        stx     bossHitPart
        lda     #$01
        sta     bossIsHit
endCheckBossThunder
        rts

TryBossPartThunder
        lda     bossBoundY1,x
        cmp     #$08
        bcc     tryBossPartThunderMiss
        cmp     playerBoundY2
        bcs     tryBossPartThunderMiss
        lda     bossBoundX1,x
        cmp     playerBoundX2
        bcs     tryBossPartThunderMiss
        lda     bossBoundX2,x
        cmp     playerBoundX1
        bcc     tryBossPartThunderMiss
        sec
        rts
tryBossPartThunderMiss
        clc
        rts

CheckBossPlayerCollision
        ldx     #$00
checkBossPlayerPartLoop
        cpx     bossPartCount
        bcs     endCheckBossPlayer
        lda     bossBoundY2,x
        cmp     playerBoundY1
        bcc     checkBossPlayerNext
        lda     bossBoundY1,x
        cmp     playerBoundY2
        bcs     checkBossPlayerNext
        lda     bossBoundX2,x
        cmp     playerBoundX1
        bcc     checkBossPlayerNext
        lda     bossBoundX1,x
        cmp     playerBoundX2
        bcs     checkBossPlayerNext
        lda     #$01
        sta     playerIsHit
        rts
checkBossPlayerNext
        inx
        bne     checkBossPlayerPartLoop
endCheckBossPlayer
        rts

;
;
;
;
;
CheckEnemyPlayerCollision
        ldx     #$ff
checkEnemyPlayerCollisionLoop
        inx
        cpx     #maxActiveEnemies
        bcs     endCheckEnemyPlayerCollision

        lda     activeEnemies,x
        tay
        lda     enemies,y
        cmp     #$01
        bne     checkEnemyPlayerCollisionLoop

        lda     enemyBoundY2,x
        cmp     playerBoundY1
        bcs     checkEnemyPlayerCollisionNext1
        jmp     checkEnemyPlayerCollisionLoop
checkEnemyPlayerCollisionNext1
        lda     enemyBoundY1,x
        cmp     playerBoundY2
        bcc     checkEnemyPlayerCollisionNext2
        jmp     checkEnemyPlayerCollisionLoop
checkEnemyPlayerCollisionNext2
        lda     enemyBoundX2,x
        cmp     playerBoundX1
        bcs     checkEnemyPlayerCollisionNext3
        jmp     checkEnemyPlayerCollisionLoop
checkEnemyPlayerCollisionNext3
        lda     enemyBoundX1,x
        cmp     playerBoundX2
        bcc     checkEnemyPlayerCollisionNext4
        jmp     checkEnemyPlayerCollisionLoop
checkEnemyPlayerCollisionNext4

        lda     #$01
        sta     playerIsHit
        jmp     checkEnemyPlayerCollisionLoop
endCheckEnemyPlayerCollision
        rts

;
;
;
;
;
CheckEnemyBulletCollision
        ldy     #$ff
checkEnemyBulletCollisionLoop

        iny
        cpy     #maxBullets
        bcs     endCheckEnemyBulletCollision

        lda     bullets,y
        cmp     #$01
        bne     checkEnemyBulletCollisionLoop
        sty     storedY

        ldx     #$ff
checkEnemyBulletCollisionInnerLoop
        inx
        cpx     #maxActiveEnemies
        bcs     endCheckInnerEnemyBulletCollision

        lda     activeEnemies,x
        tay
        lda     enemies,y
        cmp     #$01
        bne     checkEnemyBulletCollisionInnerLoop
        
        ldy     storedY

        lda     enemyBoundY2,x
        cmp     bulletY,y
        bcs     checkEnemyBulletCollisionNext1
        jmp     checkEnemyBulletCollisionInnerLoop
checkEnemyBulletCollisionNext1
        lda     enemyBoundY1,x
        cmp     bulletY,y
        bcc     checkEnemyBulletCollisionNext2
        jmp     checkEnemyBulletCollisionInnerLoop
checkEnemyBulletCollisionNext2
        lda     bulletX,y
        sec
        sbc     #$04
        sta     tmpBulletXBound
        lda     enemyBoundX2,x
        cmp     tmpBulletXBound
        bcs     checkEnemyBulletCollisionNext3
        jmp     checkEnemyBulletCollisionInnerLoop
checkEnemyBulletCollisionNext3
        lda     enemyBoundX1,x
        cmp     bulletX,y
        bcc     checkEnemyBulletCollisionNext4
        jmp     checkEnemyBulletCollisionInnerLoop
checkEnemyBulletCollisionNext4

        lda     #$01
        sta     bulletsToRemove,y

        lda     activeEnemies,x
        tay

        lda     #$01
        sta     enemyIsHit,y

        ldy     storedY

        jmp     checkEnemyBulletCollisionInnerLoop
endCheckInnerEnemyBulletCollision
        ldy     storedY
        jmp     checkEnemyBulletCollisionLoop
endCheckEnemyBulletCollision
        rts

;
;
;
;
;
CheckEnemyHomingCollision
        ldy     #$ff
checkEnemyHomingCollisionLoop

        iny
        cpy     #maxBullets
        bcs     endCheckEnemyHomingCollision

        lda     homings,y
        cmp     #$01
        bne     checkEnemyHomingCollisionLoop
        sty     storedY

        ldx     #$ff
checkEnemyHomingCollisionInnerLoop
        inx
        cpx     #maxActiveEnemies
        bcs     endCheckInnerEnemyHomingCollision

        lda     activeEnemies,x
        tay
        lda     enemies,y
        cmp     #$01
        bne     checkEnemyHomingCollisionInnerLoop
        
        ldy     storedY

        lda     enemyBoundY2,x
        cmp     homingY,y
        bcs     checkEnemyHomingCollisionNext1
        jmp     checkEnemyHomingCollisionInnerLoop
checkEnemyHomingCollisionNext1
        lda     enemyBoundY1,x
        cmp     homingY,y
        bcc     checkEnemyHomingCollisionNext2
        jmp     checkEnemyHomingCollisionInnerLoop
checkEnemyHomingCollisionNext2
        lda     homingX,y
        sec
        sbc     #$04
        sta     tmpBulletXBound
        lda     enemyBoundX2,x
        cmp     tmpBulletXBound
        bcs     checkEnemyHomingCollisionNext3
        jmp     checkEnemyHomingCollisionInnerLoop
checkEnemyHomingCollisionNext3
        lda     enemyBoundX1,x
        cmp     homingX,y
        bcc     checkEnemyHomingCollisionNext4
        jmp     checkEnemyHomingCollisionInnerLoop
checkEnemyHomingCollisionNext4

        lda     #$01
        sta     homingsToRemove,y

        lda     activeEnemies,x
        tay

        lda     #$01
        sta     enemyIsHit,y

        ldy     storedY

        jmp     checkEnemyHomingCollisionInnerLoop
endCheckInnerEnemyHomingCollision
        ldy     storedY
        jmp     checkEnemyHomingCollisionLoop
endCheckEnemyHomingCollision
        rts

;
;
;
;
;
CheckEnemyThunderBoltCollision
        lda     thunderBoltCoolDown
        cmp     #thunderBoltCoolDownTime
        bne     endCheckEnemyThunderBoltCollision

        ldx     #$ff
checkEnemyThunderBoltCollisionLoop
        inx
        cpx     #maxActiveEnemies
        bcs     endCheckEnemyThunderBoltCollision

        lda     activeEnemies,x
        cmp     #$ff
        beq     checkEnemyThunderBoltCollisionLoop

        tay
        lda     enemies,y
        cmp     #$01
        bne     checkEnemyThunderBoltCollisionLoop

        lda     enemyY,y
        cmp     #$08
        bcc     checkEnemyThunderBoltCollisionLoop

        ; Is enemy above player
        cmp     playerBoundY2
        bcs     checkEnemyThunderBoltCollisionLoop

        ; Is enemy in front of player
        lda     enemyBoundX1,x
        cmp     playerBoundX2
        bcs     checkEnemyThunderBoltCollisionLoop

        lda     enemyBoundX2,x
        cmp     playerBoundX1
        bcc     checkEnemyThunderBoltCollisionLoop

        lda     #$01
        sta     enemyIsHit,y

        jmp     checkEnemyThunderBoltCollisionLoop
endCheckEnemyThunderBoltCollision
        rts

;
;
;
;
;
CheckPlayerEnemyWeaponCollision
        ldx     #$ff
checkPlayerEnemyWeaponCollisionLoop
        inx
        cpx     #maxEnemyWeapons
        bcs     endCheckPlayerEnemyWeaponCollision

        lda     enemyWeapons,x
        cmp     #$01
        bne     checkPlayerEnemyWeaponCollisionLoop

        lda     playerBoundY2
        sec
        sbc     #$04
        cmp     enemyWeaponY,x
        bcs     checkPlayerEnemyWeaponCollisionNext1
        jmp     checkPlayerEnemyWeaponCollisionLoop

checkPlayerEnemyWeaponCollisionNext1
        lda     playerBoundY1
        sec
        sbc     #$08
        cmp     enemyWeaponY,x
        bcc     checkPlayerEnemyWeaponCollisionNext2
        jmp     checkPlayerEnemyWeaponCollisionLoop

checkPlayerEnemyWeaponCollisionNext2
        lda     enemyWeaponX,x
        sec
        sbc     #$04
        sta     tmpEnemyWeaponXBound
        lda     playerBoundX2
        cmp     tmpEnemyWeaponXBound
        bcs     checkPlayerEnemyWeaponCollisionNext3
        jmp     checkPlayerEnemyWeaponCollisionLoop

checkPlayerEnemyWeaponCollisionNext3
        lda     playerBoundX1
        cmp     enemyWeaponX,x
        bcc     checkPlayerEnemyWeaponCollisionNext4
        jmp     checkPlayerEnemyWeaponCollisionLoop

checkPlayerEnemyWeaponCollisionNext4

        lda     #$01
        sta     enemyWeaponToRemove,x
        sta     playerIsHit
        jmp     checkPlayerEnemyWeaponCollisionLoop

endCheckPlayerEnemyWeaponCollision
        rts

; (TempDrawBounds / Deebug removed — freed space below screen $4400)

;
;
;       SEGHELPERS
;
;
;#######################################;
;                                       ;
;      Draws a straight col             ;
;                                       ;
; Per-boss paths (before sprites). Editor: web/boss-path.html
; Paste over BossPath0/1/2 X+Y. Runtime index = levelIndex.
*=$5d00
; Layout MUST stay: all X banks (0,1,2) then all Y banks (0,1,2).
; Paste only the .char rows under the matching BossPathNX / BossPathNY label.
BossPathXAll
; X offsets scaled so bossX+maxOffX stays ≤250 (no 8-bit wrap to left)
BossPath0X
        .char   0,-6,-13,-19,-26,-33,-40,-48,-56,-64,-73,-81,-88,-95,-100,-104
        .char   -105,-105,-98,-91,-83,-75,-67,-59,-51,-43,-35,-27,-19,-11,-3,4
        .char   10,16,23,30,36,43,51,58,65,72,80,87,92,98,101,103
        .char   106,102,99,92,85,78,70,63,55,48,41,34,27,20,13,6
BossPath1X
        .char   9,1,-10,-22,-35,-49,-63,-77,-87,-93,-91,-79,-66,-52,-38,-24
        .char   -11,2,12,21,30,39,49,59,70,80,87,93,94,90,81,70
        .char   60,50,40,30,21,13,6,-2,-11,-6,4,14,24,27,25,20
        .char   16,13,10,4,-1,-5,-2,4,14,24,24,23,21,18,15,12
BossPath2X
        .char   0,-24,-52,-82,-104,-93,-63,-33,-3,22,48,76,100,106,84,55
        .char   27,5,-16,-15,14,20,9,-1,-14,-11,15,18,11,3,10,39
        .char   66,82,95,100,100,91,65,37,8,-22,-53,-84,-101,-80,-53,-23
        .char   7,35,64,91,92,67,38,9,-20,-51,-81,-96,-91,-81,-59,-31
BossPathYAll
BossPath0Y
        .char   -1,-6,-12,-17,-21,-26,-30,-31,-32,-32,-33,-31,-28,-24,-18,-11
        .char   -3,5,9,14,16,17,17,18,17,14,12,10,7,4,2,-2
        .char   -6,-10,-14,-18,-21,-24,-27,-29,-28,-28,-26,-24,-19,-13,-6,2
        .char   10,17,24,26,25,25,25,24,23,20,18,16,13,11,7,3
BossPath1Y
        .char   -1,-10,-19,-26,-31,-32,-33,-28,-19,-7,6,13,17,17,16,13
        .char   8,4,-2,-9,-16,-22,-26,-29,-28,-24,-15,-3,11,23,25,25
        .char   24,21,17,13,6,-4,-14,-24,-35,-46,-53,-53,-49,-36,-22,-9
        .char   3,17,30,43,55,69,82,93,96,93,81,67,53,40,26,13
BossPath2Y
        .char   -1,-20,-32,-31,-11,12,18,12,2,-13,-26,-28,-13,15,25,22
        .char   13,-5,-27,-51,-51,-25,3,32,60,89,95,69,39,9,-15,-16
        .char   -7,18,45,75,106,127,127,127,127,127,127,127,126,118,127,127
        .char   127,127,127,127,120,106,107,110,115,112,104,83,53,24,3,-5

; Bank2 sprites
*=$6000
.include  "spritedata.asm"

; Bank2 charset
*=$7000
.binary "totalchars.bin"

; Vars/tables — above VIC bank2 sprites/charset so large levels can grow
*=$8000
.include "arrays.asm"

; GoatTracker player + tune (build.ps1 relocates export → sid/music.bin @ $C000)
*=$c000
.binary "sid/music.bin"

; Drop routines (kept out of screen $4400)
*=$c500
;#######################;
;                       ;
;       SEGDROPS        ;
;                       ;
;#######################;


;
;
;
;
;
; Erase drop char at X index (preserves X)
EraseDropCell
        ldy     dropY,x
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2
        ldy     dropX,x
        lda     #$20
        sta     (tmp1),y
        ldy     dropY,x
        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2
        ldy     dropX,x
        lda     #$01
        sta     (tmp1),y
        rts

InitDrops
        lda     #$00
        sta     dropKillCount
        sta     weaponDecayCount
        ldx     #$00
initDropsLoop
        sta     drops,x
        sta     dropX,x
        sta     dropY,x
        sta     dropType,x
        sta     dropFrameCounter,x
        sta     dropTimer,x             ; cycle countdown
        inx
        cpx     #maxDrops
        bcc     initDropsLoop

        sta     dropStartX
        sta     dropStartY
        sta     dropStartType
        rts

;
;
;       CLEAR DROPS — erase chars + deactivate (e.g. level fly-out)
;
;
ClearDrops
        ldx     #$00
clearDropsLoop
        lda     drops,x
        beq     clearDropsNext
        jsr     EraseDropCell
        lda     #$00
        sta     drops,x
        sta     dropFrameCounter,x
        sta     dropTimer,x
clearDropsNext
        inx
        cpx     #maxDrops
        bcc     clearDropsLoop
        rts

;
;
;       ACTIVATE DROP — stationary; random start type; cycle every 2s; 2 cycles
;
;
ActivateDrop
        ldx     #$00
        lda     drops,x
        bne     endActivateDrop         ; max 1

        lda     #$01
        sta     drops,x
        lda     dropStartX
        lsr
        lsr
        lsr
        cmp     #32                     ; playfield cols 0..31 (HUD at 33+)
        bcc     dropXInRange
        lda     #31
dropXInRange
        sta     dropX,x
        lda     dropStartY
        lsr
        lsr
        lsr
        cmp     #25
        bcc     dropYInRange
        lda     #24
dropYInRange
        sta     dropY,x
        ; Don't touch storedX — UpdateEnemyIsHit keeps the active slot there
        jsr     PickRandomWeaponType    ; random start 1..3 (clobbers X)
        ldx     #$00                    ; maxDrops=1, always slot 0
        sta     dropType,x
        lda     #dropCycleFrames
        sta     dropTimer,x
        lda     #$00
        sta     dropFrameCounter,x      ; completed cycles
endActivateDrop
        rts

;
;
;       UPDATE DROPS — pickup; cycle type; despawn after dropMaxCycles
;
;
UpdateDrops
        ldx     #$00
        lda     drops,x
        bne     dropUpdateActive
        rts
dropUpdateActive
        ; --- pickup ---
        lda     playerBoundY2
        lsr
        lsr
        lsr
        cmp     dropY,x
        bcc     dropAfterPickup
        lda     playerBoundY1
        lsr
        lsr
        lsr
        sec
        sbc     #$02
        cmp     dropY,x
        bcs     dropAfterPickup
        lda     playerBoundX2
        lsr
        lsr
        lsr
        cmp     dropX,x
        bcc     dropAfterPickup
        lda     playerBoundX1
        lsr
        lsr
        lsr
        cmp     dropX,x
        bcc     dropGotIt
        jmp     dropAfterPickup

dropGotIt
        jsr     EraseDropCell
        lda     #$00
        sta     drops,x
        sta     dropTimer,x
        sta     dropFrameCounter,x

        lda     dropType,x
        cmp     playerWeapon
        beq     dropSameWeapon
        sta     playerWeapon
        lda     #$01
        sta     playerWeaponLevel
        jmp     dropApplyWeapon
dropSameWeapon
        lda     playerWeaponLevel
        cmp     #maxWeaponLevel
        bcs     dropApplyWeapon
        clc
        adc     #$01
        sta     playerWeaponLevel
dropApplyWeapon
        jsr     RefreshWeaponPower
        ldx     playerWeapon
        lda     PlayerColor,x
        sta     $d027
        jsr     UpdateHudWeapon
        rts

dropAfterPickup
        ; --- cycle timer (stationary) ---
        lda     dropTimer,x
        beq     dropDoCycle
        sec
        sbc     #$01
        sta     dropTimer,x
        rts
dropDoCycle
        lda     dropFrameCounter,x
        clc
        adc     #$01
        sta     dropFrameCounter,x
        cmp     #dropMaxCycles
        bcs     dropExpire
        lda     #dropCycleFrames
        sta     dropTimer,x
        lda     dropType,x
        clc
        adc     #$01
        cmp     #$04                    ; 1..3 then wrap
        bcc     dropCycleStore
        lda     #$01
dropCycleStore
        sta     dropType,x
        rts
dropExpire
        jsr     EraseDropCell
        lda     #$00
        sta     drops,x
        sta     dropTimer,x
        sta     dropFrameCounter,x
        rts

;
;
;       DRAW DROPS — weapon glyph + color; blink for visibility
;
;
DrawDrops
        ldx     #$00
        lda     drops,x
        beq     endDrawDrops

        ; Blink ~8 frames on / 8 off (use cycle timer)
        lda     dropTimer,x
        and     #$08
        beq     dropDrawBlank

        lda     dropY,x
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2
        lda     ScreenColorL,y
        sta     tmpColor1
        lda     ScreenColorH,y
        sta     tmpColor2

        lda     dropX,x
        tay
        stx     storedX
        lda     dropType,x
        tax
        lda     DropCharByType,x
        sta     (tmp1),y

        lda     tmpColor1
        sta     tmp1
        lda     tmpColor2
        sta     tmp2
        ldx     storedX
        lda     dropType,x
        tax
        lda     WeaponColor,x
        sta     (tmp1),y
        ldx     storedX
endDrawDrops
        rts

dropDrawBlank
        jsr     EraseDropCell
        rts

;
;
;       TITLE MENU + CREDITS (relocated above screen $4400)
;
;

; START GAME / CREDITS labels (rows 21–22, col 14/16)
DrawTitleMenuLabels
        ldx     #$00
drawTitleStartLoop
        lda     titleStartText,x
        beq     drawTitleCreditsLabel
        sta     $4758,x             ; row 21 col 16
        lda     #$01
        sta     $db58,x
        inx
        jmp     drawTitleStartLoop
drawTitleCreditsLabel
        ldx     #$00
drawTitleCreditsLoop
        lda     titleCreditsText,x
        beq     endDrawTitleMenuLabels
        sta     $4780,x             ; row 22 col 16
        lda     #$01
        sta     $db80,x
        inx
        jmp     drawTitleCreditsLoop
endDrawTitleMenuLabels
        rts

; Row 24: "FROM CSDOS" bottom-left, "V1.0" bottom-right
DrawTitleCorners
        ldx     #$00
drawTitleFromLoop
        lda     titleFromText,x
        beq     drawTitleVerLabel
        sta     $47c0,x             ; row 24 col 0
        lda     #$01
        sta     $dbc0,x
        inx
        jmp     drawTitleFromLoop
drawTitleVerLabel
        ldx     #$00
drawTitleVerLoop
        lda     titleVersionText,x
        beq     endDrawTitleCorners
        sta     $47e4,x             ; row 24 col 36
        lda     #$01
        sta     $dbe4,x
        inx
        jmp     drawTitleVerLoop
endDrawTitleCorners
        rts

DrawTitleMenuCursor
        lda     #$20
        sta     $4756               ; row 21 col 14
        sta     $477e               ; row 22 col 14
        lda     #$01
        sta     $db56
        sta     $db7e
        lda     menuIndex
        bne     titleCursorOnCredits
        lda     #titleMenuCursorChar
        sta     $4756
        rts
titleCursorOnCredits
        lda     #titleMenuCursorChar
        sta     $477e
        rts

titleStartText
        .byte    $13,$14,$01,$12,$14,$20,$07,$01,$0d,$05,$00
titleCreditsText
        .byte    $03,$12,$05,$04,$09,$14,$13,$00
titleFromText
        .byte    $06,$12,$0f,$0d,$20,$03,$13,$04,$0f,$13,$00
        ; FROM CSDOS
titleVersionText
        .byte    $16,$31,$2e,$30,$00
        ; V1.0

; Credits — record: row, col, screen-codes..., $00. End: row=$ff.
; ZP: credSrc1/2 = table, tmp1/2 = screen, warnSrc1/2 = color
DrawCreditsScreen
        lda     #<creditsData
        sta     credSrc1
        lda     #>creditsData
        sta     credSrc2
drawCreditsNextRec
        ldy     #$00
        lda     (credSrc1),y
        cmp     #$ff
        bne     drawCreditsRecGo
        jmp     drawCreditsPrompt
drawCreditsRecGo
        sta     warnRow
        iny
        lda     (credSrc1),y
        sta     warnColLeft
        lda     credSrc1
        clc
        adc     #$02
        sta     credSrc1
        bcc     drawCreditsPtrOk
        inc     credSrc2
drawCreditsPtrOk
        ldy     warnRow
        lda     ScreenRowsL,y
        clc
        adc     warnColLeft
        sta     tmp1
        lda     ScreenRowsH,y
        adc     #$00
        sta     tmp2
        lda     ScreenColorL,y
        clc
        adc     warnColLeft
        sta     warnSrc1
        lda     ScreenColorH,y
        adc     #$00
        sta     warnSrc2
        ldy     #$00
drawCreditsCharLoop
        lda     (credSrc1),y
        beq     drawCreditsLineEnd
        sta     (tmp1),y
        lda     #$01
        sta     (warnSrc1),y
        iny
        bne     drawCreditsCharLoop
drawCreditsLineEnd
        iny
        tya
        clc
        adc     credSrc1
        sta     credSrc1
        bcc     drawCreditsNextRec
        inc     credSrc2
        jmp     drawCreditsNextRec

drawCreditsPrompt
        ldx     #$00
drawCreditsPromptLoop
        lda     titlePrompt,x
        beq     endDrawCreditsScreen
        sta     $47cf,x
        lda     #$01
        sta     $dbcf,x
        inx
        jmp     drawCreditsPromptLoop
endDrawCreditsScreen
        rts

creditsData
        .byte   2,2
        .byte   $02,$01,$13,$05,$20,$07,$01,$0d,$05,$20,$10,$12,$0f,$07,$12,$01,$0d,$0d,$09,$0e,$07,$20,$0d,$01,$04,$05,$20,$09,$0e,$20,$32,$30,$31,$38,$2c,$00
        .byte   3,3
        .byte   $06,$09,$0e,$09,$13,$08,$05,$04,$20,$17,$09,$14,$08,$20,$01,$09,$20,$28,$03,$15,$12,$13,$0f,$12,$29,$20,$09,$0e,$20,$32,$30,$32,$36,$00
        .byte   5,2
        .byte   $14,$08,$05,$0d,$05,$20,$09,$0e,$13,$10,$09,$12,$05,$04,$20,$02,$19,$20,$10,$12,$05,$13,$09,$04,$05,$0e,$14,$20,$14,$12,$15,$0d,$10,$27,$13,$00
        .byte   6,5
        .byte   $01,$0e,$0e,$0f,$15,$0e,$03,$05,$0d,$05,$0e,$14,$20,$0f,$06,$20,$01,$20,$13,$10,$01,$03,$05,$20,$06,$0f,$12,$03,$05,$00
        .byte   8,10
        .byte   $14,$0f,$0f,$0c,$13,$20,$01,$0e,$04,$20,$12,$05,$13,$0f,$15,$12,$03,$05,$13,$00
        .byte   9,3
        .byte   $03,$0f,$0d,$0d,$0f,$04,$0f,$12,$05,$20,$36,$34,$20,$10,$12,$0f,$07,$12,$01,$0d,$0d,$05,$12,$13,$20,$12,$05,$06,$05,$12,$05,$0e,$03,$05,$00
        .byte   10,3
        .byte   $03,$02,$0d,$20,$10,$12,$07,$20,$13,$14,$15,$04,$09,$0f,$2c,$20,$0c,$01,$14,$05,$12,$20,$16,$13,$20,$03,$0f,$04,$05,$20,$17,$09,$14,$08,$00
        .byte   11,9
        .byte   $36,$34,$14,$01,$13,$13,$20,$14,$15,$12,$02,$0f,$20,$01,$13,$13,$05,$0d,$02,$0c,$05,$12,$00
        .byte   12,11
        .byte   $16,$09,$03,$05,$3a,$20,$03,$36,$34,$20,$05,$0d,$15,$0c,$01,$14,$0f,$12,$00
        .byte   13,17
        .byte   $10,$01,$09,$0e,$14,$00
        .byte   14,8
        .byte   $10,$05,$14,$13,$03,$09,$09,$01,$14,$0f,$12,$20,$17,$05,$02,$20,$05,$04,$09,$14,$09,$0f,$0e,$00
        .byte   15,13
        .byte   $03,$08,$01,$14,$07,$10,$14,$20,$09,$0d,$01,$07,$05,$13,$00
        .byte   17,8
        .byte   $13,$10,$05,$03,$09,$01,$0c,$20,$14,$08,$01,$0e,$0b,$13,$20,$14,$0f,$20,$09,$0e,$07,$16,$01,$12,$00
        .byte   $ff
