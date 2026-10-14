;testDirTableX    byte    $02,$01,$00,$ff,$fe,$ff,$00
;testDirTableY    byte    $00,$01,$02,$01,$00,$ff,$fe

testDirTableX    .byte    $04,$02,$00,$fe,$fc,$fe,$00
testDirTableY    .byte    $00,$02,$04,$04,$00,$fe,$fc

; Vars
scoreMultiplier         .fill 1
playerScore     .fill   6
hiscoreCount = 5
Hiscores                .fill   hiscoreCount * 6   ; 5×6 digit scores (RAM, survives runs)
force                   .fill 1
ships                   .fill 1
playerX                 .fill 1
playerY                 .fill 1
playerBoundY2           .fill 1
playerBoundY1           .fill 1
playerBoundX2           .fill 1
playerBoundX1           .fill 1
playerFrame             .fill 1
playerFrameCounter      .fill 1
playerIsHit             .fill 1
canFire                 .fill 1
fireDelay               .fill 1
shouldFirePlayerWeapon  .fill 1
playerMoveSpeed         .fill 1
xMoveAmount             .fill 1
yMoveAmount             .fill 1
playerWeapon            .fill 1
playerWeaponLevel       .fill 1
playerWeaponPower       .fill 1
invulnerableCounter     .fill 1
isInvulnerable          .fill 1

storedX                 .fill 1
storedY                 .fill 1
tmpBulletXBound         .fill 1
tmpBulletFrame          .fill 1
scoreAdd                .fill 1
thunderBoltFrame        .fill 1
thunderBoltColorFrame  .fill 1

thunderBoltCoolDown .fill 1
thunderBoltX .fill 1
thunderBoltY .fill 1
savedThunderBoltX  .fill 1
savedThunderBoltY  .fill 1

enemyTickPointer    .fill 1
activeEnemyPointer  .fill 1
tmpActiveEnemiesPointer .fill 1
enemyToActivate  .fill 1

enemyWeaponStartX       .fill 1
enemyWeaponStartY       .fill 1
enemyWeaponStartXSpeed  .fill 1
enemyWeaponStartYSpeed  .fill 1
enemyWeaponStartType    .fill 1
tmpEnemyWeaponXBound    .fill 1

closestEnemyIndex       .fill 1
tempShortestDistanceX   .fill 1

explosionStartX .fill 1
explosionStartY .fill 1
explosionCol    .fill 1
explosionRow    .fill 1

explosions              .fill maxExplosions
explosionsX         .fill   maxExplosions
explosionsY         .fill   maxExplosions
explosionCounters   .fill   maxExplosions
explosionFrames     .fill   maxExplosions
explosionCurrentFrame     .fill   maxExplosions
explosionColorFrame      .fill   maxExplosions

starField       .fill   maxStars
starX             .fill   maxStars
starY          .fill   maxStars
starFrame          .fill   maxStars
starColor       .fill   maxStars

; Arrays and tables
activeEnemies   .fill maxActiveEnemies
enemyBoundX1   .fill maxActiveEnemies
enemyBoundY1   .fill maxActiveEnemies
enemyBoundX2   .fill maxActiveEnemies
enemyBoundY2   .fill maxActiveEnemies
enemies         .fill totalEnemies
enemyX          .fill totalEnemies
enemyY          .fill totalEnemies
enemyMoveX      .fill totalEnemies
enemyMoveY      .fill totalEnemies
enemyIsHit      .fill totalEnemies
enemyHitPoints  .fill totalEnemies
enemySpriteFrame .fill  totalEnemies
enemySpriteFrameCounter .fill  totalEnemies
enemyPhase      .fill totalEnemies   ; type02: 0=align, 1=kamikaze

enemyWeapons            .fill maxEnemyWeapons
enemyWeaponX            .fill maxEnemyWeapons
enemyWeaponY            .fill maxEnemyWeapons
enemyWeaponXSpeed       .fill maxEnemyWeapons
enemyWeaponYSpeed       .fill maxEnemyWeapons
enemyWeaponType         .fill maxEnemyWeapons
enemyWeaponToRemove     .fill maxEnemyWeapons

bullets         .fill maxBullets
bulletsToRemove .fill maxBullets
bulletX         .fill maxBullets
bulletY         .fill maxBullets
bulletFrame     .fill maxBullets

homings         .fill maxBullets
homingsToRemove .fill maxBullets
homingX         .fill maxBullets
homingY         .fill maxBullets
homingXMoveR         .fill maxBullets
homingXMoveL         .fill maxBullets

PlayerFrameTable .byte   $85,$83,$84,$80,$81,$82
; Index = playerWeapon 1..3 (0 unused): Bullets yellow, Homing green, Laser cyan
PlayerColor      .byte   $00,$07,$05,$03
WeaponColor      .byte   $00,$07,$05,$03
JetFrameTable    .byte   $8d,$8e,$8f    ; jet01..jet03

; Damage by level index 0..2 (level 1..3). Homing < Laser < Bullets.
WeaponDamageBullets     .byte   2,4,5   ; wave / normal
WeaponDamageHoming      .byte   1,2,3
WeaponDamageLaser       .byte   3,4,6
; Boss-fight tables: flatter steps (weak less hopeless, 3x less delete)
BossDamageBullets       .byte   3,4,4
BossDamageHoming        .byte   2,2,3
BossDamageLaser         .byte   4,4,5
; Random pick 1..3 (and #$03 → table)
RandomWeaponTable       .byte   1,2,3,1

; PETSCII screen codes for HUD names (padded/terminated with $ff)
HudNameBullets  .byte   $02,$15,$0c,$0c,$05,$14,$13,$ff   ; BULLETS
HudNameHoming   .byte   $08,$0f,$0d,$09,$0e,$07,$20,$ff   ; HOMING_
HudNameLaser    .byte   $0c,$01,$13,$05,$12,$20,$20,$ff   ; LASER__

drops           .fill   maxDrops
dropX           .fill   maxDrops
dropY           .fill   maxDrops
dropType        .fill   maxDrops
dropFrameCounter   .fill   maxDrops
dropTimer       .fill   maxDrops
dropMoveX       .fill   maxDrops   ; signed ±1
dropMoveY       .fill   maxDrops   ; signed ±1
dropStartX     .fill   1
dropStartY     .fill   1
dropStartType  .fill   1
; Screen char per weapon (1=bullets, 2=homing, 3=laser) — same glyphs as shots
DropCharByType  .byte   $20,$97,$a5,$b4

; Boss (levelIndex selects boss 0/1/2)
bossState       .fill   1
bossX           .fill   1
bossY           .fill   1
bossHp          .fill   1
bossIsHit       .fill   1
bossHitPart     .fill   1
bossMovePhase   .fill   1       ; 0..63 path table index
bossPathFrac    .fill   1       ; 0..255 blend toward next step
bossPartCount   .fill   1       ; 4 or 6
bossOffBase     .fill   1       ; levelIndex * 6 into BossOff*
bossCenterX     .fill   1
bossCenterY     .fill   1
bossFireTimer   .fill   1
bossPatPtrL     .fill   1
bossPatPtrH     .fill   1
bossBoundX1     .fill   maxBossParts
bossBoundY1     .fill   maxBossParts
bossBoundX2     .fill   maxBossParts
bossBoundY2     .fill   maxBossParts
bannerExpand    .fill   1
bannerHoldTimer .fill   1
warnColLeft     .fill   1
warnColRight    .fill   1
warnRow         .fill   1
savedBgColor    .fill   1
savedBorderColor .fill  1

; Per-level boss defs (index = levelIndex)
BossSpriteBase  .byte   $90,$94,$9a     ; first sprite pointer
BossNumParts    .byte   4,6,4
BossCenterXTbl  .byte   $78,$6c,$78     ; TL origin (3x2 centered a bit left)
BossCenterYTbl  .byte   $48,$48,$48
BossMaxHpTbl    .byte   110,120,70       ; boss1/2 doubled; boss3 unchanged
BossColorTbl    .byte   12,11,12        ; spcolour from totalsprites.spt
BossMc2Tbl      .byte   4,13,7          ; mcolour2 (shared $d026) per boss
; Shot origin relative to boss TL (follows bossX/bossY each volley)
BossShotOriginX .byte   24,36,24        ; 2x2 center / 3x2 center / 2x2
BossShotOriginY .byte   21,21,21        ; mid-height of 2-row boss

; Part offsets: 3 layouts x 6 slots (unused slots 0)
BossOffX
        .byte   0,24,0,24,0,0           ; boss1 2x2
        .byte   0,24,48,0,24,48         ; boss2 3x2
        .byte   0,24,0,24,0,0           ; boss3 2x2
BossOffY
        .byte   0,0,21,21,0,0
        .byte   0,0,0,21,21,21
        .byte   0,0,21,21,0,0

BulletLeftFrameTable    .byte    $97,$96,$95,$94,$93,$92,$91,$90,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f
BulletCenterFrameTable  .byte    $8f,$9e,$9d,$9c,$9b,$9a,$99,$98,$97,$96,$95,$94,$93,$92,$91,$90,$8f,$00
BulletRightFrameTable   .byte    $8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$9e,$9d,$9c,$9b,$9a,$99,$98,$97,$96

ThunderBoltCenterFrameTable    .byte    $8f,$8f,$b8,$b7,$b6,$b5,$b4,$b3,$b2,$b1,$b0,$af,$ae,$ad,$ac,$8f,$8f,$00
ThunderBoltRightFrameTable     .byte    $8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$b8,$b7,$b6,$b5,$b4,$b3,$b2
ThunderBoltLeftFrameTable      .byte    $b2,$b1,$b0,$af,$ae,$ad,$ac,$8f,$8f,$8f,$8f,$ab,$aa,$a9,$a8,$a7,$a6,$a5
ThunderBoltColorTable          .byte    $03,$0e,$01,$03,$0e,$01,$03,$0e,$01,$03,$0e,$01,$03,$0e,$01,$03,$0e,$01

; Wave tables: one flat list, sliced per level via levelEnemyStart/Count.
; L1/L2/L3 = refs/levels/level1.png (55), level2.png (77), level3.png (84).
; Slots 216..223 = rush-only meteors (not in any level slice).
; Ticks restart per level (levelTickBase).
; --- L1 (0..54), L2 (55..131), L3 (132..215) ---
EnemyStartTick          .byte    $03,$07,$08,$0a,$0a,$0b,$0d,$0f,$10,$10,$12,$13,$14,$16,$17,$18
                        .byte    $1a,$1a,$1a,$1b,$1c,$1d,$25,$26,$27,$28,$29,$2a,$2a,$2b,$2b,$2c
                        .byte    $2c,$2d,$2e,$2f,$30,$31,$32,$35,$37,$37,$38,$38,$3a,$3a,$3a,$3c
                        .byte    $3c,$3e,$3f,$3f,$40,$42,$42
                        .byte    $04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0d,$0e,$0f,$0f,$10,$11
                        .byte    $13,$18,$18,$19,$19,$1a,$1a,$1f,$20,$21,$21,$22,$23,$27,$28,$28
                        .byte    $29,$2a,$2c,$2d,$2d,$2f,$2f,$31,$33,$34,$35,$37,$39,$3b,$3c,$3d
                        .byte    $3e,$40,$41,$43,$43,$44,$45,$47,$49,$49,$4c,$4e,$4e,$4f,$50,$51
                        .byte    $51,$52,$53,$53,$53,$53,$54,$55,$55,$55,$56,$57,$57
                        .byte    $02,$03,$04,$05,$07,$09,$09,$0a,$0b,$0c,$0d,$11,$12,$12,$13,$13
                        .byte    $14,$14,$15,$19,$1b,$1d,$1d,$1f,$20,$22,$23,$24,$24,$25,$26,$27
                        .byte    $28,$29,$30,$30,$32,$32,$34,$34,$35,$35,$37,$3a,$3b,$3c,$3d,$3e
                        .byte    $3f,$40,$40,$41,$41,$41,$42,$43,$44,$44,$44,$45,$47,$4f,$50,$52
                        .byte    $52,$52,$54,$56,$58,$59,$5a,$5c,$5c,$5d,$5f,$61,$61,$62,$62,$64
                        .byte    $65,$68,$68,$69
; --- rush meteors (216..223) ---
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00
EnemyType               .byte    $01,$01,$01,$03,$03,$01,$01,$01,$03,$03,$02,$02,$02,$01,$01,$01
                        .byte    $03,$01,$03,$01,$01,$03,$01,$04,$04,$04,$04,$04,$04,$04,$04,$04
                        .byte    $04,$01,$01,$01,$01,$01,$01,$02,$02,$02,$03,$03,$01,$01,$01,$01
                        .byte    $01,$03,$03,$02,$01,$03,$03
                        .byte    $03,$01,$02,$03,$01,$03,$01,$02,$01,$02,$03,$03,$03,$03,$03,$03
                        .byte    $01,$03,$03,$01,$01,$03,$03,$01,$01,$02,$01,$01,$01,$01,$01,$02
                        .byte    $01,$01,$03,$03,$03,$04,$04,$01,$01,$02,$01,$01,$01,$01,$03,$02
                        .byte    $01,$04,$01,$01,$03,$04,$01,$01,$03,$03,$02,$04,$04,$04,$04,$04
                        .byte    $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
                        .byte    $01,$01,$02,$01,$01,$01,$01,$01,$02,$01,$01,$01,$03,$03,$01,$01
                        .byte    $03,$03,$03,$01,$03,$03,$03,$03,$01,$01,$02,$03,$01,$02,$03,$01
                        .byte    $02,$03,$01,$01,$01,$01,$03,$03,$02,$02,$02,$01,$01,$01,$01,$01
                        .byte    $01,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$01,$03,$01,$03
                        .byte    $01,$03,$01,$01,$02,$02,$02,$03,$03,$01,$01,$01,$02,$03,$03,$01
                        .byte    $01,$02,$02,$01
                        .byte    $04,$04,$04,$04,$04,$04,$04,$04
EnemyStartX             .byte    $75,$58,$97,$47,$a2,$3c,$ad,$75,$64,$86,$47,$a2,$75,$75,$69,$5e
                        .byte    $2b,$75,$b9,$80,$8b,$75,$75,$75,$75,$75,$75,$4d,$91,$4d,$91,$4d
                        .byte    $91,$8b,$91,$97,$47,$42,$3c,$75,$36,$b3,$53,$97,$3c,$75,$ad,$53
                        .byte    $91,$6f,$69,$7a,$6f,$3c,$a8
                        .byte    $75,$7a,$8b,$ad,$a8,$42,$47,$b9,$7a,$2b,$5e,$53,$47,$91,$9c,$a8
                        .byte    $7a,$2b,$ca,$36,$be,$47,$a8,$80,$8b,$7a,$9c,$ad,$c4,$75,$69,$7a
                        .byte    $58,$3c,$7a,$31,$be,$47,$a2,$36,$4d,$7a,$69,$8b,$a8,$be,$3c,$7a
                        .byte    $be,$ad,$9c,$6f,$be,$5e,$47,$31,$58,$9c,$7a,$31,$b3,$53,$97,$3c
                        .byte    $91,$69,$25,$4d,$80,$b9,$53,$42,$a2,$ca,$6f,$4d,$97
                        .byte    $36,$53,$75,$6f,$7a,$7a,$be,$a8,$75,$86,$7a,$6f,$42,$a2,$31,$b9
                        .byte    $25,$c4,$6f,$75,$a2,$42,$8b,$58,$75,$42,$4d,$42,$a2,$97,$a2,$75
                        .byte    $80,$75,$53,$91,$3c,$ad,$53,$97,$36,$b3,$75,$3c,$42,$47,$97,$91
                        .byte    $8b,$75,$a8,$36,$58,$9c,$b3,$8b,$53,$75,$b9,$3c,$75,$75,$8b,$2b
                        .byte    $75,$b9,$5e,$75,$75,$a2,$47,$64,$86,$75,$ad,$3c,$75,$47,$a2,$97
                        .byte    $58,$3c,$b9,$75
                        .byte    $18,$28,$10,$38,$20,$30,$14,$40
EnemyStartY             .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte    $00,$00,$00,$00
                        .byte    $00,$00,$00,$00,$00,$00,$00,$00

; Per-level wave slices into tables above (rush slots are outside these)
levelEnemyStart         .byte    0,55,132
levelEnemyCount         .byte    55,77,84
levelBgColor            .byte    $06,$00,$02    ; blue / black / red
levelBorderColor        .byte    $08,$0b,$0a


EnemyFrameTable         .byte    $85,$86,$87,$88
AstroFrameTable         .byte    $9e,$9f,$a0    ; astro_1_1..3 tumble; astro_2=$a1 static
; Spawn dirs: mostly straight down; slight ±1 X (~20–25% of dy)
AstroDirX               .byte    $00,$00,$01,$ff
AstroDirY               .byte    $04,$03,$04,$03

; HP by type index: 0 unused, 01 medium=6, 02 kami=3, 03 tank=6, 04 astro=3
EnemyLifeByType         .byte    0,6,3,6,3

EnemyColor              .byte    $04,$04,$04,$08,$08,$04,$04,$04,$08,$08,$02,$02,$02,$04,$04,$04
                        .byte    $08,$04,$08,$04,$04,$08,$04,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
                        .byte    $0f,$04,$04,$04,$04,$04,$04,$02,$02,$02,$08,$08,$04,$04,$04,$04
                        .byte    $04,$08,$08,$02,$04,$08,$08
                        .byte    $08,$04,$02,$08,$04,$08,$04,$02,$04,$02,$08,$08,$08,$08,$08,$08
                        .byte    $04,$08,$08,$04,$04,$08,$08,$04,$04,$02,$04,$04,$04,$04,$04,$02
                        .byte    $04,$04,$08,$08,$08,$0f,$0f,$04,$04,$02,$04,$04,$04,$04,$08,$02
                        .byte    $04,$0f,$04,$04,$08,$0f,$04,$04,$08,$08,$02,$0f,$0f,$0f,$0f,$0f
                        .byte    $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
                        .byte    $04,$04,$02,$04,$04,$04,$04,$04,$02,$04,$04,$04,$08,$08,$04,$04
                        .byte    $08,$08,$08,$04,$08,$08,$08,$08,$04,$04,$02,$08,$04,$02,$08,$04
                        .byte    $02,$08,$04,$04,$04,$04,$08,$08,$02,$02,$02,$04,$04,$04,$04,$04
                        .byte    $04,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$04,$08,$04,$08
                        .byte    $04,$08,$04,$04,$02,$02,$02,$08,$08,$04,$04,$04,$02,$08,$08,$04
                        .byte    $04,$02,$02,$04
                        .byte    $0f,$0f,$01,$0f,$0f,$01,$0f,$0f
; Per-slot life matching EnemyType
EnemyLife               .byte    $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$03,$03,$03,$06,$06,$06
                        .byte    $06,$06,$06,$06,$06,$06,$06,$03,$03,$03,$03,$03,$03,$03,$03,$03
                        .byte    $03,$06,$06,$06,$06,$06,$06,$03,$03,$03,$06,$06,$06,$06,$06,$06
                        .byte    $06,$06,$06,$03,$06,$06,$06
                        .byte    $06,$06,$03,$06,$06,$06,$06,$03,$06,$03,$06,$06,$06,$06,$06,$06
                        .byte    $06,$06,$06,$06,$06,$06,$06,$06,$06,$03,$06,$06,$06,$06,$06,$03
                        .byte    $06,$06,$06,$06,$06,$03,$03,$06,$06,$03,$06,$06,$06,$06,$06,$03
                        .byte    $06,$03,$06,$06,$06,$03,$06,$06,$06,$06,$03,$03,$03,$03,$03,$03
                        .byte    $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
                        .byte    $06,$06,$03,$06,$06,$06,$06,$06,$03,$06,$06,$06,$06,$06,$06,$06
                        .byte    $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$03,$06,$06,$03,$06,$06
                        .byte    $03,$06,$06,$06,$06,$06,$06,$06,$03,$03,$03,$06,$06,$06,$06,$06
                        .byte    $06,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$06,$06,$06,$06
                        .byte    $06,$06,$06,$06,$03,$03,$03,$06,$06,$06,$06,$06,$03,$06,$06,$06
                        .byte    $06,$03,$03,$06
                        .byte    $03,$03,$03,$03,$03,$03,$03,$03


explosionTableTopLeft   .byte    $59,$5e,$63,$68,$20
explosionTableTopCenter   .byte    $5a,$5f,$64,$69,$20
explosionTableTopRight   .byte    $59,$5e,$63,$68,$20
explosionTableMiddleLeft   .byte    $5b,$60,$65,$6a,$20
explosionTableMiddleCenter   .byte    $5c,$61,$66,$6b,$20
explosionTableMiddleRight   .byte    $5b,$60,$65,$6a,$20
explosionTableBottomLeft   .byte    $5d,$62,$67,$6c,$20
explosionTableBottomCenter   .byte    $5a,$5f,$64,$69,$20
explosionTableBottomRight   .byte    $5d,$62,$67,$6c,$20
explosionColorTable   .byte    $01,$01,$07,$0a,$02,$01,$01

DropFrameTable         .byte    $c3,$c2,$c1,$c0,$20,$20

StarFrameTable         .byte    $50,$51,$52,$53,$54,$55,$56,$57,$20,$20,$20

RNG24TABLE      .byte    $01,$04,$06,$02,$12,$03,$05,$14,$10,$0B,$0F,$13,$07,$0E,$09,$11,$0C,$17,$16,$0A,$00,$0D,$15,$08,$0E,$10,$17,$0D,$04
RNG30TABLE      .byte    $06,$04,$1D,$02,$10,$15,$07,$0F,$05,$16,$0C,$1A,$14,$11,$00,$18,$19,$12,$03,$17,$08,$1B,$0B,$0E,$13,$1C,$09,$0D,$0A,$01

ScreenColorL    .byte    $00,$28,$50,$78,$a0,$c8,$f0,$18,$40,$68,$90,$b8,$e0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0,$00,$00,$00,$00,$00,$00,$00
ScreenColorH    .byte    $d8,$d8,$d8,$d8,$d8,$d8,$d8,$d9,$d9,$d9,$d9,$d9,$d9,$da,$da,$da,$da,$da,$da,$da,$db,$db,$db,$db,$db,$d8,$d8,$d8,$d8,$d8,$d8,$d8
; Bank 2
ScreenRowsL     .byte    $00,$28,$50,$78,$a0,$c8,$f0,$18,$40,$68,$90,$b8,$e0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0,$00,$00,$00,$00,$00,$00,$00 ; 4 st safe ScreenRowsL
ScreenRowsH     .byte    $44,$44,$44,$44,$44,$44,$44,$45,$45,$45,$45,$45,$45,$46,$46,$46,$46,$46,$46,$46,$47,$47,$47,$47,$47,$44,$44,$44,$44,$44,$44,$44 ; 4 st safe ScreenRowsH
