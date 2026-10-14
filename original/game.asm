; 10 SYS (2304)

*=$0801

        byte    $0E, $08, $0A, $00, $9E, $20, $28
        byte    $32, $33, $30, $34, $29, $00, $00, $00

wait bytes 1*1
modulus bytes 1*1
rng24 bytes 1*1
rng30 bytes 1*1
tickHalt bytes 1*1
ticks bytes 1*1
tickCounter bytes 1*1

tmp1 =$fb
tmp2 =$fc
tmp3 byte 1*1
tmpColor1 bytes 1*1
tmpColor2 bytes 1*1

testTick bytes 1*1
testDir bytes 1*1

; Consts
tickDelayTime = #64
shipsMax = #06
shipsStart = #03
forceStart = #06
forceMax = #06
invulnerableTime = #40
playerFrameTime = #04
playerFrameMin = #01
playerFrameMax = #05
playerFrameCenter = #03

playerXMin = #20
playerXMax = #250
playerYMin = #52
playerYMax = #233

maxStars = #08

maxBullets = #4
thunderBoltCoolDownTime = #$0d
playerWeaponXOffset = #16
playerWeaponYOffset = #44
bulletSpeed = #08
homingSpeed = #04
fireDelayTime = #10
thunderBoltDelayTime = #30

enemyWidth=#28
enemyHeight=#48

maxActiveEnemies = #6
totalEnemies = #20

maxEnemyWeapons = #16

maxDrops = #04
dropsFrameTime = #08
maxDrops = #04

explosionFrameMax = #06
explosionFrameTime = #06
explosionXOffset = #20
explosionYOffset = #42
maxExplosions = #08


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

        jsr     Init

MainLoop

        ldx     wait
        cpx     #$00
        bne     MainLoop
        ldx     #$01
        stx     wait
        ; Update logic
        lda     #$00
        sta     $d021
        lda     #$08
        sta     $d020
        jsr     UpdateEntities
        jsr     UpdateStats

;        ;Temp
;        ldx     testTick
;        inx
;        stx     testTick
;        cpx     #$09
;        bcc     endTemp
;        ldx     #$00
;        stx     testTick

;        lda     #$90
;        sta     enemyWeaponStartX
;        lda     #$80
;        sta     enemyWeaponStartY
;        ldx     testDir
;        lda     testDirTableX,x
;        sta     enemyWeaponStartXSpeed

;        lda     testDirTableY,x
;        sta     enemyWeaponStartYSpeed
;        lda     #$97
;        sta     enemyWeaponStartType

;        inx
;        stx     testDir

;        jsr     ActivateEnemyWeapons

        lda     testDir
        cmp     #07
        bcc     dontResetTestDir

        ldx     #$00
        stx     testDir
dontResetTestDir

endTemp
        
        jsr     UpdateModulus
        ;jsr     UpdateRNG
        jsr     UpdateTick
        lda     #$01
        sta     $d020
        jmp     MainLoop

;
;
;
;
;
GameOver
        lda     #%00000000
        sta     $d015
        jsr     ClearScreen
        lda     #$00
gameOverLoop
        sta     $d021
        clc
        adc     #$01
        sta     $d020
        cmp     #$0f
        bcc     gameOverLoop
        lda     #$00
        jmp     gameOverLoop

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

        ldx     ticks
        cpx     #$17
        bcc     continueTickUpdate
        ldx     #$00
        stx     ticks
        jsr     InitEnemies
continueTickUpdate
;end Temp
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
        cpx     tickDelayTime
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
        cpx     maxActiveEnemies
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
        lda     #$01
        sta     $d020
        lda     #$00
        sta     $d021
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
        ;jsr     Deebug
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

        rts

;
;
;       Increases score
;
;
IncreaseScore

        ldx     #$00
        lda     playerScore,x
        clc
        adc     scoreMultiplier
        sta     playerScore,x
        cmp     #$0a
        bcc     endIncreaseScore
        lda     #$00
        sta     playerScore,x

        inx
        lda     playerScore,x
        clc
        adc     scoreMultiplier
        sta     playerScore,x
        cmp     #$0a
        bcc     endIncreaseScore
        lda     #$00
        sta     playerScore,x

        inx
        lda     playerScore,x
        clc
        adc     scoreMultiplier
        sta     playerScore,x
        cmp     #$0a
        bcc     endIncreaseScore
        lda     #$00
        sta     playerScore,x

        inx
        lda     playerScore,x
        clc
        adc     scoreMultiplier
        sta     playerScore,x
        cmp     #$0a
        bcc     endIncreaseScore
        lda     #$00
        sta     playerScore,x

        inx
        lda     playerScore,x
        clc
        adc     scoreMultiplier
        sta     playerScore,x
        cmp     #$0a
        bcc     endIncreaseScore
        lda     #$00
        sta     playerScore,x

endIncreaseScore
        jsr     UpdateScore

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

        rts

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
;       DISPLAY GET PSYCHED
;
;
DisplayGetPsyched
        ldx     modulus
        cpx     #$01
        bne     displayGetPsychedNext
        jsr     HideGetPsyched
        jmp     endDisplayGetPsyched
displayGetPsychedNext
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

endDisplayGetPsyched
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

        iny
        cpy     ships
        bcs     endUpdateHudShips
        jsr     AddShip4

        iny
        cpy     ships
        bcs     endUpdateHudShips
        jsr     AddShip5

        iny
        cpy     ships
        bcs     endUpdateHudShips
        jsr     AddShip6
endUpdateHudShips
        rts
;
;
;       CLEAR SHIPS
;
;
ClearHubShips
        lda     #$20
        ldx     #33
        sta     $4540,x
        sta     $4568,x
        sta     $4590,x
        sta     $45b8,x
        inx
        sta     $4540,x
        sta     $4568,x
        sta     $4590,x
        sta     $45b8,x
        inx
        sta     $4540,x
        sta     $4568,x
        sta     $4590,x
        sta     $45b8,x
        inx
        sta     $4540,x
        sta     $4568,x
        sta     $4590,x
        sta     $45b8,x
        inx
        sta     $4540,x
        sta     $4568,x
        sta     $4590,x
        sta     $45b8,x
        inx
        sta     $4540,x
        sta     $4568,x
        sta     $4590,x
        sta     $45b8,x

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
        jsr     UpdatePlayer
        jsr     UpdateEnemies
        jsr     UpdateThings
        jsr     CheckForCollision
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
        lda     playerFrameCenter
        sta     playerFrame

        lda     #$00
        sta     isInvulnerable
        sta     invulnerableCounter
        sta     shouldFirePlayerWeapon
        sta     canFire

        lda     #$03
        sta     playerWeapon



        lda     #$02
        sta     playerMoveSpeed


        ; Add sprite
        lda     #%11111111
        sta     $d015
        lda     #%11111111
        sta     $d01c
        sta     $d01b
        lda     #$0b
        sta     $d025
        lda     #$0c
        sta     $d026
        lda     #$02
        sta     $d027
        ldx     playerFrame
        lda     PlayerFrameTable,x
        sta     $47f8

        lda     #$80;#$7f
        sta     $d000
        lda     #$80;#$00
        sta     $d001

        ; Init player weapon
        jsr     InitPlayerWeapon

        lda     shipsStart
        sta     ships
        lda     forceStart
        sta     force

        lda     #$02
        sta     scoreMultiplier

        lda     #$00
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

        lda     invulnerableTime
        sta     invulnerableCounter

        lda     #$01
        sta     isInvulnerable

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
        bne     updateHudForceAndEndPlayerHit

        lda     forceMax
        sta     force

        lda     ships
        sec
        sbc     #$01
        sta     ships
        cmp     #$ff
        bne     updateHudShipsAndEndPlayerHit

        ; GameOver
        jsr     GameOver
        
updateHudShipsAndEndPlayerHit
        jsr     UpdateHudShips
updateHudForceAndEndPlayerHit
        jsr     UpdateHudForce
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
        cpx     playerFrameTime
        bcc     updatePlayerCheckPlayerFrame
        lda     #$00
        sta     playerFrameCounter
        ldx     playerFrame
        dex
        stx     playerFrame
        cpx     playerFrameMin
        bcs     updatePlayerCheckPlayerFrame
        lda     playerFrameMin
        sta     playerFrame
        jmp     updatePlayerCheckPlayerFrame

updatePlayerMoveRight
        ldx     playerFrameCounter
        inx
        stx     playerFrameCounter
        cpx     playerFrameTime
        bcc     updatePlayerCheckPlayerFrame
        lda     #$00
        sta     playerFrameCounter
        ldx     playerFrame
        inx
        stx     playerFrame
        cpx     playerFrameMax
        bcc     updatePlayerCheckPlayerFrame
        lda     playerFrameMax
        sta     playerFrame
        jmp     updatePlayerCheckPlayerFrame

updatePlayerNoMove      ; ToDo: Animate back!
        lda     #$00
        sta     playerFrameCounter
        ldx     playerFrame
        cpx     playerFrameCenter
        beq     endUpdatePlayerFrame
        ldx     playerFrameCenter
        stx     playerFrame
        lda     PlayerFrameTable,x
        sta     $47f8
        jmp     endUpdatePlayerFrame

updatePlayerCheckPlayerFrame
        ldx     playerFrame
        cpx     playerFrameCenter
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

        lda     fireDelayTime
        sta     fireDelay
        rts

;
;
;
;
ActivatePlayerWeapon

        ldx     playerWeapon
        cpx     #$03
        beq     startActivateThunderBolt
        cpx     #$02
        beq     startActivateHoming
        lda     #$08
        sta     playerWeaponPower
        jsr     ActivateBullet
        jmp     endActivatePlayerWeapon
startActivateThunderBolt
        lda     #$10
        sta     playerWeaponPower
        jsr     ActivateThunderBolt
        jmp     endActivatePlayerWeapon
startActivateHoming
        lda     #$04
        sta     playerWeaponPower
        jsr     ActivateHoming

endActivatePlayerWeapon

        rts

;
;
;
;
UpdatePlayerWeaponFrame

        ldx     #$ff
updateWeaponFrameLoop
        inx
        cpx     maxBullets
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
        beq     continueUpdatePlayerWeaponDelay

        ldx     fireDelay
        cpx     #$00
        beq     continueUpdatePlayerWeaponDelay

        dex
        stx     fireDelay
        cpx     #$00
        beq     setCanFiretoTrue

        lda     #$00
        sta     canFire
        jmp     continueUpdatePlayerWeaponDelay
setCanFiretoTrue
        lda     #$01
        sta     canFire
continueUpdatePlayerWeaponDelay
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
        cpx     maxBullets
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
        cpx     maxBullets
        bcs     endActivateBullet

        lda     bullets,x
        cmp     #$00
        bne     findInactiveBulletLoop

        lda     #$01
        sta     bullets,x

        lda     playerX
        sec
        sbc     playerWeaponXOffset
        sta     bulletX,x

        lda     playerY
        sec
        sbc     playerWeaponYOffset
        sta     bulletY,x

        lda     fireDelayTime
        sta     fireDelay

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
        cpx     maxBullets
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
        cpx     maxBullets
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
        sbc     bulletSpeed
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
        cpx     maxBullets
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
        cpx     maxBullets
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
        sbc     playerWeaponXOffset
        sta     homingX,x

        lda     playerY
        sec
        sbc     playerWeaponYOffset
        sta     homingY,x

        lda     fireDelayTime
        sta     fireDelay

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
        cpx     maxBullets
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
        cpx     maxBullets
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
        sbc     bulletSpeed
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
        sbc     playerWeaponXOffset
        lsr
        lsr
        lsr
        sta     thunderBoltX
        sta     savedThunderBoltX
        lda     playerY
        sec
        sbc     playerWeaponYOffset
        lsr
        lsr
        lsr
        sta     thunderBoltY

        lda     thunderBoltCoolDownTime
        sta     thunderBoltCoolDown

endFireThunderBolt
        lda     thunderBoltDelayTime
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
        cpx     maxActiveEnemies
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
        inx
        cpx     totalEnemies
        bcc     initEnemiesLoop2

;        lda     #$08
;        ldx     #$00
;initEnemiesLoop3
;        inx
;        cpx     totalEnemies
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
        cpx     maxActiveEnemies
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
        cmp     playerYMax
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
        ; continue add types
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

        lda     #$89
        sta     $47fa,x
        lda     #$00
        sta     enemyMoveX,y
        lda     #$01
        sta     enemyMoveY,y

        lda     enemyY,y
        cmp     playerBoundY2
        bcs     doneUpdateEnemy02Pos

        lda     enemyBoundX1,x
        cmp     playerBoundX2
        bcc     checkEnemy02PlayerLeft

        lda     #$fe
        sta     enemyMoveX,y
        lda     #$01
        sta     enemyMoveY,y
        lda     #$8a
        sta     $47fa,x
        jmp     doneUpdateEnemy02Pos
checkEnemy02PlayerLeft
        lda     enemyBoundX2,x
        cmp     playerBoundX1
        bcs     doneUpdateEnemy02Pos

        lda     #$02
        sta     enemyMoveX,y
        lda     #$01
        sta     enemyMoveY,y
        lda     #$8b
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
        cpx     maxActiveEnemies
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
        cpx     maxActiveEnemies
        bcs     endUpdateEnemyIsHit

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
        ; Enemy is dead, init drop and remove it!
        stx     storedX
        lda     enemyX,y
        sta     dropStartX
        lda     enemyY,y
        sta     dropStartY
        lda     #$01
        sta     dropStartType
        jsr     ActivateDrop
        ldx     storedX

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
        cpx     maxActiveEnemies
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
        lda     enemyStartTick,x
        cmp     ticks
        bcs     endTickEnemies

        stx     enemyToActivate
        jsr     ActivateEnemy


endTickEnemies
        rts

;
;
;       Activates enemy id stored in "ActivateEnemy"
;
;
ActivateEnemy
        ldx     #$ff
activateEnemyLoop
        inx
        cpx     maxActiveEnemies
        bcs     ActiveEnemiesOverFlow

        lda     activeEnemies,x
        cmp     #$ff
        bne     activateEnemyLoop
        
        ldy     enemyToActivate
        lda     #$01
        sta     enemies,y
        tya
        sta     activeEnemies,x
        sty     $4428
        lda     enemyStartX,y
        sta     $4429
        sta     enemyX,y
        lda     enemyStartY,y
        sta     $442a
        sta     enemyY,y

        ldx     enemyTickPointer
        inx
        stx     enemyTickPointer
        jmp     tickEnemiesLoop

ActiveEnemiesOverFlow
        lda     #$06
        sta     $d021
        lda     #$01
        sta     tickHalt
        ldx     ticks
        dex
        stx     ticks
        jmp     endTickEnemies



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
        cpx     maxEnemyWeapons
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
        cpx     maxEnemyWeapons
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
        cpx     maxEnemyWeapons
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
        cpx     maxEnemyWeapons
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
;                       ;
;#######################;


;
;
;
;
;
InitDrops
        lda     #$00
        ldx     #$00
initDropsLoop
        sta     drops,x
        sta     dropX,x
        sta     dropY,x
        sta     dropType,x
        sta     dropFrame,x
        sta     dropFrameCounter,x
        inx
        cpx     maxDrops
        bcc     initDropsLoop

        sta     dropStartX
        sta     dropStartY
        sta     dropStartType

        rts

;
;
;
;
;
ActivateDrop
        ldx     #$ff
findFreeDropLoop
        inx
        cpx     maxDrops
        bcs     endActivateDrop

        lda     drops,x
        cmp     #$00
        bne     findFreeDropLoop

        lda     #$01
        sta     drops,x
        lda     dropStartX
        clc
        lsr
        lsr
        lsr
        sec
        sbc     #$01
        sta     dropX,x
        lda     dropStartY
        clc
        lsr
        lsr
        lsr
        sec
        sbc     #$03
        sta     dropY,x
        lda     dropStartType
        sta     dropType,x

        lda     #$00
        sta     dropFrame,x
        sta     dropFrameCounter,x

endActivateDrop
        rts

;
;
;
;
;
UpdateDrops
        ldx     #$ff
updateDropsLoop
        inx
        cpx     maxDrops
        bcs     jumpToEndUpdateDrops
        jmp     startUpdateDrop
jumpToEndUpdateDrops
        jmp     endUpdateDrops
startUpdateDrop
        lda     drops,x
        cmp     #$01
        bne     updateDropsLoop

        ; Check if player has got the drop
        lda     playerBoundY2
        clc
        lsr
        lsr
        lsr
        cmp     dropY,x
        bcc     didNotGetDrop
        lda     playerBoundY1
        clc     
        lsr
        lsr
        lsr
        sec
        sbc     #$02
        cmp     dropY,x
        bcs     didNotGetDrop
        lda     playerBoundX2
        clc
        lsr
        lsr
        lsr
        cmp     dropX,x
        bcc     didNotGetDrop
        lda     playerBoundX1
        clc
        lsr
        lsr
        lsr
        cmp     dropX,x
        bcs     didNotGetDrop

        ; Player got the drop
        ldy     dropY,x
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2
        ldy     dropX,x
        lda     #$20
        sta     (tmp1),y
        lda     #$00
        sta     drops,x

        lda     playerWeapon
        clc
        adc     #$01
        sta     playerWeapon

        jmp     continueUpdateDrops

didNotGetDrop
        lda     dropFrameCounter,x
        clc
        adc     #$01
        sta     dropFrameCounter,x
        cmp     dropsFrameTime
        bcc     continueUpdateDrops

        lda     #$01
        sta     dropFrameCounter,x
        lda     dropFrame,x
        clc
        adc     #$01
        sta     dropFrame,x
        cmp     #$05
        bcc     continueUpdateDrops

        lda     #$00
        sta     dropFrame,x
        sta     dropFrameCounter,x

        lda     dropY,x
        clc
        adc     #$01
        sta     dropY,x
        cmp     #25
        bcc     continueUpdateDrops

        lda     #$00
        sta     drops,x

continueUpdateDrops
        
        jmp     updateDropsLoop
endUpdateDrops
        rts

;
;
;
;
;
DrawDrops
        ldx     #$ff
drawDropsLoop
        inx
        cpx     maxDrops
        bcs     endDrawDrops

        lda     drops,x
        cmp     #$01
        bne     drawDropsLoop

        lda     dropY,x
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     dropX,x
        tay

        stx     storedX

        lda     dropFrame,x
        tax
        lda     DropFrameTable,x
        sta     (tmp1),y
        
        ldx     storedX

        jmp     drawDropsLoop
endDrawDrops
        rts

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
        cpx     maxExplosions
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
        cpx     maxExplosions
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
        sbc     explosionXOffset
        clc
        lsr
        lsr
        lsr
        sta     explosionsX,x
        lda     explosionStartY
        sec
        sbc     explosionYOffset
        clc
        lsr
        lsr
        lsr
        
        sta     explosionsY,x

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
        cpx     maxExplosions
        bcs     endUpdateExplosion

        lda     explosions,x
        cmp     #$01
        bne     updateExplosionLoop
        ; Got one active to update

        lda     explosionCounters,x
        clc
        adc     #$01
        sta     explosionCounters,x
        cmp     explosionFrameTime
        bcc     updateExplosionLoop

        lda     #$00
        sta     explosionCounters,x

        lda     explosionFrames,x
        clc
        adc     #$01
        sta     explosionFrames,x
        cmp     explosionFrameMax
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
        cpx     maxExplosions
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
        cpx     maxExplosions
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
        cpx     maxStars
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
        cpx     maxStars
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
        cpx     maxStars
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
        cpx     maxStars
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
        cpx     maxStars
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
        sta     (tmp1),y
        ; then color!!

        ldy     starY,x
        lda     ScreenColorL,y
        sta     tmp1
        lda     ScreenColorH,y
        sta     tmp2
        ldy     starX,x
        lda     starColor,x
        sta     (tmp1),y

        ldx     storedX
        jmp     drawStarFieldLoop

endDrawStarField
        rts


;#######################;
;                       ;
;      SEGINPUT         ;
;                       ;
;#######################;


HandleInput     
; Button




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

;        lda     playerX
;        sta     explosionX
;        lda     playerY
;        sec
;        sbc     #90
;        sta     explosionY
;        jsr     ActivateExplosion
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

;        lda     playerX
;        clc
;        adc     #$ff
;        sta     playerX
;        lda     playerY
;        clc
;        adc     #$fe
;        clc
;        adc     modulus
;        sta     playerY

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
        cmp     playerXMax
        bcc     checkXmin
        lda     playerXMax
checkXmin
        cmp     playerXMin
        bcs     saveXMovement
        lda     playerXMin
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
        cmp     playerYMax
        bcc     checkYmin
        lda     playerYMax
checkYmin
        cmp     playerYMin
        bcs     saveYMovement
        lda     playerYMin
saveYMovement
        sta     playerY

        rts
        



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
        ;jsr TempDrawBounds
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
        cpx     maxActiveEnemies
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
        cpy     maxBullets
        bcs     endCheckEnemyBulletCollision

        lda     bullets,y
        cmp     #$01
        bne     checkEnemyBulletCollisionLoop
        sty     storedY

        ldx     #$ff
checkEnemyBulletCollisionInnerLoop
        inx
        cpx     maxActiveEnemies
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
        cpy     maxBullets
        bcs     endCheckEnemyHomingCollision

        lda     homings,y
        cmp     #$01
        bne     checkEnemyHomingCollisionLoop
        sty     storedY

        ldx     #$ff
checkEnemyHomingCollisionInnerLoop
        inx
        cpx     maxActiveEnemies
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
        cmp     thunderBoltCoolDownTime
        bne     endCheckEnemyThunderBoltCollision

        ldx     #$ff
checkEnemyThunderBoltCollisionLoop
        inx
        cpx     maxActiveEnemies
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
        cpx     maxEnemyWeapons
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

;
;
;
;
;
TempDrawBounds
        jsr     ClearScreen
        ; Player
        ;Y1
        lda     playerBoundY1
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     playerBoundX1
        clc
        lsr
        lsr
        lsr
        tay
        lda     #$ca
        sta     (tmp1),y

        lda     playerBoundX2
        clc
        lsr
        lsr
        lsr
        tay
        lda     #$cb
        sta     (tmp1),y

        ;Y2
        lda     playerBoundY2
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     playerBoundX1
        clc
        lsr
        lsr
        lsr
        tay
        lda     #$cc
        sta     (tmp1),y

        lda     playerBoundX2
        clc
        lsr
        lsr
        lsr
        tay
        lda     #$cd
        sta     (tmp1),y

        ; Enemies
        ldx     #$ff
tempDrawBoundsLoop
        inx
        cpx     maxActiveEnemies
        bcs     endTempDrawBounds

        lda     enemyBoundY1,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     enemyBoundX1,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     #$ca
        sta     (tmp1),y

        lda     enemyBoundX2,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     #$cb
        sta     (tmp1),y

        ;Y2
        lda     enemyBoundY2,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     ScreenRowsL,y
        sta     tmp1
        lda     ScreenRowsH,y
        sta     tmp2

        lda     enemyBoundX1,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     #$cc
        sta     (tmp1),y

        lda     enemyBoundX2,x
        clc
        lsr
        lsr
        lsr
        tay
        lda     #$cd
        sta     (tmp1),y

        jmp     tempDrawBoundsLoop   

endTempDrawBounds
        rts

;#######################;
;                       ;
;      SEGDEEBUG        ;
;                       ;
;#######################;

;
;
;
;
;
Deebug

        ldx     #$00
deebugLoop1

        lda     enemyWeapons,x
        sta     $4748,x
        lda     enemyWeaponX,x
        sta     $4770,x
        lda     enemyWeaponY,x
        sta     $4798,x
        lda     enemyWeaponToRemove,x
        sta     $47c0,x
        inx
        cpx     maxEnemyWeapons
        bcc     deebugLoop1

        ldx     #$00
deebugLoop5
; $80,$a8,$d0,$f8
        lda     activeEnemies,x
        sta     $4680,x
        lda     enemyX,x
        sta     $46a8,x
        lda     enemyY,x
        sta     $46d0,x
        lda     enemyHitPoints,x
        sta     $46f8,x

endDeebugLoop5
        inx
        cpx     maxActiveEnemies
        bcc     deebugLoop5



        rts


;
;
;       SEGHELPERS
;
;
;#######################################;
;                                       ;
;      Draws a straight col             ;
;                                       ;
;#######################################;
defm    DrawStraightCol; /1: x-pos /2: char /3: color
        ldx     /1
        lda     /2     
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
        lda     /3
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

        endm



incasm "arrays.asm"

; Bank2 sprites
*=$6000
incasm  "spritedata.asm"

; Bank2 charset
*=$7000
incbin "totalchars.bin"