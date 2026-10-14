; SFX lab — tweak the gameplay one-shots and read the values back.
;
; Same model as game.asm voice 3:
;   gate off, write freq / pulse / AD / SR / wave+gate, count TIMER frames.
;   Each frame: if FREQ HI >= THRESH then FREQ HI -= SWEEP,
;   else FREQ LO ^= WOBBLE.
;   TIMER 00 holds the tone (no sweep, gate stays on) so a timbre is easy to hear.
;
; Build:  64tass --cbm-prg -o sfxlab.prg sfxlab.asm
; Run:    LOAD "SFXLAB.PRG",8,1   then RUN
;
; Keys:   1/2/3/4 effect  U/D select    L/P and +/- adjust
;         C=  step $10    SPACE replay  R reset this effect
; Paste the two FL/AD lines back to change the game.

; 10 SYS (2304)

*=$0801

        .byte   $0E, $08, $0A, $00, $9E, $20, $28
        .byte   $32, $33, $30, $34, $29, $00, $00, $00

*=$0900

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

        lda     #$00
        sta     $d020
        sta     $d021
        sta     $d015
        lda     #$ff
        sta     $cc                 ; no cursor blink

        jsr     SidClear
        jsr     ClearScreen
        jsr     CopyDefaults
        jsr     DrawStatic
        jsr     DrawAll
        jsr     SfxTrigger

MainLoop
        lda     wait
        bne     MainLoop
        lda     #$01
        sta     wait
        jsr     SfxUpdate
        jsr     ReadKeys
        jmp     MainLoop

;
; Raster IRQ once per frame. Exit through the Kernal so the keyboard is scanned.
;
irq
        lda     #$00
        sta     wait
        ldy     #$00
        sty     $d012
        asl     $d019
        jmp     $ea31

;
; SID voice 3, same registers as the game.
;
sidFreqL = $d40e
sidFreqH = $d40f
sidPwL   = $d410
sidPwH   = $d411
sidWave  = $d412
sidAD    = $d413
sidSR    = $d414
sidVol   = $d418

P_FREQ_L = 0
P_FREQ_H = 1
P_PW_L   = 2
P_PW_H   = 3
P_WAVE   = 4
P_AD     = 5
P_SR     = 6
P_TIMER  = 7
P_SWEEP  = 8
P_WOBBLE = 9
P_VOLUME = 10
P_COUNT  = 11
P_THRESH = 11                   ; global, not stored per effect
PARAM_N  = 12
EFFECT_N = 7

SidClear
        ldx     #$18
        lda     #$00
sidClearLoop
        sta     $d400,x
        dex
        bpl     sidClearLoop
        rts

CopyDefaults
        ldx     #EFFECT_N*P_COUNT-1
copyDefLoop
        lda     Defaults,x
        sta     Work,x
        dex
        bpl     copyDefLoop
        lda     #$05
        sta     thresh
        lda     #$00
        sta     effectIndex
        sta     paramIndex
        sta     sfxActive
        lda     #$40
        sta     lastKey
        rts

;
; Play the current effect. TIMER 00 latches the voice on with no modulation.
;
SfxTrigger
        jsr     EffectPtr
        lda     #$00
        sta     sidWave             ; gate off before the new note
        ldy     #P_FREQ_L
        lda     ($f9),y
        sta     playFreqL
        sta     sidFreqL
        ldy     #P_FREQ_H
        lda     ($f9),y
        sta     playFreqH
        sta     sidFreqH
        ldy     #P_PW_L
        lda     ($f9),y
        sta     sidPwL
        ldy     #P_PW_H
        lda     ($f9),y
        sta     sidPwH
        ldy     #P_AD
        lda     ($f9),y
        sta     sidAD
        ldy     #P_SR
        lda     ($f9),y
        sta     sidSR
        ldy     #P_SWEEP
        lda     ($f9),y
        sta     playSweep
        ldy     #P_WOBBLE
        lda     ($f9),y
        sta     playWobble
        ldy     #P_VOLUME
        lda     ($f9),y
        sta     sidVol
        ldy     #P_WAVE
        lda     ($f9),y
        ora     #$01                ; force gate, matching a one-shot
        sta     sidWave
        ldy     #P_TIMER
        lda     ($f9),y
        sta     playTimer
        beq     sfxHoldOn
        lda     #$01
        sta     sfxActive
        lda     #$00
        sta     sfxHold
        jmp     DrawStatus
sfxHoldOn
        lda     #$01
        sta     sfxActive
        sta     sfxHold
        jmp     DrawStatus

SfxUpdate
        lda     sfxActive
        beq     endSfxUpdate
        lda     sfxHold
        bne     endSfxUpdate
        lda     playTimer
        beq     sfxDone
        sec
        sbc     #$01
        sta     playTimer
        beq     sfxDone
        lda     playFreqH
        cmp     thresh
        bcc     sfxWobble
        sec
        sbc     playSweep
        sta     playFreqH
        sta     sidFreqH
        rts
sfxWobble
        lda     playFreqL
        eor     playWobble
        sta     playFreqL
        sta     sidFreqL
        rts
sfxDone
        lda     #$00
        sta     sfxActive
        sta     sidWave
        sta     sidFreqL
        sta     sidFreqH
        sta     sidAD
        sta     sidSR
        jmp     DrawStatus
endSfxUpdate
        rts

;
; $f9/$fa -> the 11 bytes of the current effect. Screen pointer stays in $fb.
;
EffectPtr
        ldx     effectIndex
        lda     effLo,x
        sta     $f9
        lda     effHi,x
        sta     $fa
        rts

;
; Keyboard, once per frame. Cursor and +/- repeat; the rest fire once.
;
ReadKeys
        lda     $cb
        cmp     #$40
        bne     keyDown
        lda     #$40
        sta     lastKey
        rts
keyDown
        cmp     lastKey
        beq     keyHeld
        sta     lastKey
        lda     #16
        sta     repDelay
        jmp     Dispatch
keyHeld
        lda     repDelay
        beq     keyRepeat
        dec     repDelay
        rts
keyRepeat
        lda     lastKey
        jsr     IsRepeatKey
        bcc     endReadKeys
        lda     #14
        sta     repDelay
        lda     lastKey
        jmp     Dispatch
endReadKeys
        rts

IsRepeatKey
        cmp     #$1e                ; U
        beq     repeatYes
        cmp     #$12                ; D
        beq     repeatYes
        cmp     #$2a                ; L
        beq     repeatYes
        cmp     #$29                ; P
        beq     repeatYes
        cmp     #$28                ; +
        beq     repeatYes
        cmp     #$2b                ; -
        beq     repeatYes
        clc
        rts
repeatYes
        sec
        rts

Dispatch
        lda     lastKey
        cmp     #$1e                ; U
        beq     keyParamPrev
        cmp     #$12                ; D
        beq     keyParamNext
        cmp     #$2a                ; L
        beq     keyMinus
        cmp     #$29                ; P
        beq     keyPlus
        cmp     #$28                ; +
        beq     keyPlus
        cmp     #$2b                ; -
        beq     keyMinus
        cmp     #$3c                ; SPACE
        bne     notSpace
        jmp     keySpace
notSpace
        cmp     #$11                ; R
        bne     notReset
        jmp     keyReset
notReset
        cmp     #$38                ; 1
        bne     notEff0
        jmp     keyEff0
notEff0
        cmp     #$3b                ; 2
        bne     notEff1
        jmp     keyEff1
notEff1
        cmp     #$08                ; 3
        bne     notEff2
        jmp     keyEff2
notEff2
        cmp     #$0b                ; 4
        bne     notEff3
        jmp     keyEff3
notEff3
        cmp     #$10                ; 5
        bne     notEff4
        jmp     keyEff4
notEff4
        cmp     #$13                ; 6
        bne     notEff5
        jmp     keyEff5
notEff5
        cmp     #$18                ; 7
        bne     notEff6
        jmp     keyEff6
notEff6
        rts

keyParamNext
        inc     paramIndex
        lda     paramIndex
        cmp     #PARAM_N
        bcc     movedParam
        lda     #$00
        sta     paramIndex
        jmp     movedParam
keyParamPrev
        dec     paramIndex
        bpl     movedParam
        lda     #PARAM_N-1
        sta     paramIndex
movedParam
        jmp     DrawAll

keyPlus
        jmp     doPlus
keyMinus
doMinus
        jsr     LoadAdjust
        sty     adjIndex
        sec
        sbc     adjStep
        jmp     storeAdjust
doPlus
        jsr     LoadAdjust
        sty     adjIndex
        clc
        adc     adjStep
storeAdjust
        ldy     adjIndex
        cpy     #$ff
        beq     storeThresh
        sta     ($f9),y
        jmp     afterAdjust
storeThresh
        sta     thresh
afterAdjust
        jsr     DrawAll
        jmp     SfxTrigger

keySpace
        jmp     SfxTrigger

keyReset
        jsr     EffectPtr
        lda     effectIndex
        asl
        tax
        lda     defLo,x
        sta     $fd
        lda     defHi,x
        sta     $fe
        ldy     #P_COUNT-1
resetLoop
        lda     ($fd),y
        sta     ($f9),y
        dey
        bpl     resetLoop
        jsr     DrawAll
        jmp     SfxTrigger

keyEff0
        lda     #$00
        jmp     setEffect
keyEff1
        lda     #$01
        jmp     setEffect
keyEff2
        lda     #$02
        jmp     setEffect
keyEff3
        lda     #$03
        jmp     setEffect
keyEff4
        lda     #$04
        jmp     setEffect
keyEff5
        lda     #$05
        jmp     setEffect
keyEff6
        lda     #$06
setEffect
        cmp     effectIndex
        beq     retrigSame
        sta     effectIndex
        jsr     DrawAll
retrigSame
        jmp     SfxTrigger

;
; A = current value, Y = param offset or $FF for threshold, adjStep set.
;
LoadAdjust
        lda     #$01
        sta     adjStep
        lda     $028d
        and     #$02                ; Commodore key
        beq     stepFine
        lda     #$10
        sta     adjStep
stepFine
        lda     paramIndex
        cmp     #P_THRESH
        beq     loadThresh
        jsr     EffectPtr
        ldy     paramIndex
        lda     ($f9),y
        rts
loadThresh
        ldy     #$ff
        lda     thresh
        rts

;
; Screen.
;
ClearScreen
        ldx     #$00
        lda     #$20
clearLoop
        sta     $0400,x
        sta     $0500,x
        sta     $0600,x
        sta     $0700,x
        inx
        bne     clearLoop
        ldx     #$00
        lda     #$0e                ; light blue
colorLoop
        sta     $d800,x
        sta     $d900,x
        sta     $da00,x
        inx
        bne     colorLoop
        ldx     #$00
colorLast
        sta     $db00,x
        inx
        cpx     #$e8
        bne     colorLast
        rts

DrawStatic
        ldx     #$00
        ldy     #$00
        lda     #<tTitle
        sta     $fd
        lda     #>tTitle
        sta     $fe
        jsr     PrintAt
        ldx     #$01
        ldy     #$00
        lda     #<tHelp1
        sta     $fd
        lda     #>tHelp1
        sta     $fe
        jsr     PrintAt
        ldx     #18
        lda     #<tRule1
        sta     $fd
        lda     #>tRule1
        sta     $fe
        ldy     #$00
        jsr     PrintAt
        ldx     #19
        lda     #<tRule2
        sta     $fd
        lda     #>tRule2
        sta     $fe
        ldy     #$00
        jsr     PrintAt
        ldx     #21
        lda     #<tLegend
        sta     $fd
        lda     #>tLegend
        sta     $fe
        ldy     #$00
        jsr     PrintAt
        ldx     #24
        lda     #<tHelp2
        sta     $fd
        lda     #>tHelp2
        sta     $fe
        ldy     #$00
        jmp     PrintAt

DrawAll
        jsr     DrawEffects
        jsr     DrawParams
        jsr     DrawDump
        jmp     DrawStatus

DrawEffects
        ldx     #$00
drawEffLoop
        stx     tmpX
        txa
        clc
        adc     #$02
        tax
        jsr     RowPtr
        ldy     #$00
        lda     #$20
effRowClr
        sta     ($fb),y
        iny
        cpy     #14
        bcc     effRowClr
        ldy     #$00
        lda     #$0e
        sta     ($fd),y
        iny
        lda     tmpX
        cmp     effectIndex
        bne     effPlain
        lda     #$3e                ; >
        sta     ($fb),y
        lda     #$07
        jmp     effName
effPlain
        lda     #$20
        sta     ($fb),y
        lda     #$0e
effName
        sta     effColor
        iny
        sty     tmpY
        lda     tmpX
        asl
        tay
        lda     nameLo,y
        sta     $f7
        lda     nameHi,y
        sta     $f8
        ldy     #$00
effChar
        lda     ($f7),y
        beq     effNext
        sty     tmpC
        ldy     tmpY
        sta     ($fb),y
        lda     effColor
        sta     ($fd),y
        ldy     tmpC
        inc     tmpY
        iny
        cpy     #$08
        bcc     effChar
effNext
        ldx     tmpX
        inx
        cpx     #EFFECT_N
        bcc     drawEffLoop
        ; reverse the active name
        lda     effectIndex
        clc
        adc     #$02
        tax
        jsr     RowPtr
        ldy     #$02
revEff
        lda     ($fb),y
        ora     #$80
        sta     ($fb),y
        iny
        cpy     #$0a
        bcc     revEff
        rts

DrawParams
        ldx     #$00
drawParLoop
        stx     tmpX
        txa
        clc
        adc     #$09                ; below 7 effect rows (2..8)
        tax
        jsr     RowPtr
        ldy     #$00
spacePar
        lda     #$20
        sta     ($fb),y
        lda     #$0e
        sta     ($fd),y
        iny
        cpy     #14
        bcc     spacePar
        lda     tmpX
        asl
        tay
        lda     labelLo,y
        sta     $f7
        lda     labelHi,y
        sta     $f8
        ldy     #$00
        ldx     #$00
parChar
        lda     ($f7),y
        beq     parHex
        cpx     #9
        bcs     parHex
        sta     ($fb),y
        inx
        iny
        bne     parChar
parHex
        jsr     ParamValue
        ldy     #10
        jsr     PutHex
        ldx     tmpX
        inx
        cpx     #PARAM_N
        bcc     drawParLoop
        ; highlight the selected row
        lda     paramIndex
        clc
        adc     #$09
        tax
        jsr     RowPtr
        ldy     #$00
hiPar
        lda     ($fb),y
        ora     #$80
        sta     ($fb),y
        lda     #$01
        sta     ($fd),y
        iny
        cpy     #14
        bcc     hiPar
        rts

;
; A = value of paramIndex-style index in tmpX (0-10 effect, 11 threshold).
;
ParamValue
        lda     tmpX
        cmp     #P_THRESH
        beq     pvThresh
        jsr     EffectPtr
        ldy     tmpX
        lda     ($f9),y
        rts
pvThresh
        lda     thresh
        rts

DrawDump
        ldx     #22
        jsr     RowPtr
        jsr     EffectPtr
        ldy     #0
        lda     #<dFL
        sta     $f7
        lda     #>dFL
        sta     $f8
        jsr     PutTag
        ldy     #P_FREQ_L
        lda     ($f9),y
        ldy     #2
        jsr     PutHex
        ldy     #5
        lda     #<dFH
        sta     $f7
        lda     #>dFH
        sta     $f8
        jsr     PutTag
        ldy     #P_FREQ_H
        lda     ($f9),y
        ldy     #7
        jsr     PutHex
        ldy     #10
        lda     #<dPL
        sta     $f7
        lda     #>dPL
        sta     $f8
        jsr     PutTag
        ldy     #P_PW_L
        lda     ($f9),y
        ldy     #12
        jsr     PutHex
        ldy     #15
        lda     #<dPH
        sta     $f7
        lda     #>dPH
        sta     $f8
        jsr     PutTag
        ldy     #P_PW_H
        lda     ($f9),y
        ldy     #17
        jsr     PutHex
        ldy     #20
        lda     #<dWV
        sta     $f7
        lda     #>dWV
        sta     $f8
        jsr     PutTag
        ldy     #P_WAVE
        lda     ($f9),y
        ldy     #22
        jsr     PutHex
        ldy     #25
        lda     #<dVL
        sta     $f7
        lda     #>dVL
        sta     $f8
        jsr     PutTag
        ldy     #P_VOLUME
        lda     ($f9),y
        ldy     #27
        jsr     PutHex

        ldx     #23
        jsr     RowPtr
        jsr     EffectPtr
        ldy     #0
        lda     #<dAD
        sta     $f7
        lda     #>dAD
        sta     $f8
        jsr     PutTag
        ldy     #P_AD
        lda     ($f9),y
        ldy     #2
        jsr     PutHex
        ldy     #5
        lda     #<dSR
        sta     $f7
        lda     #>dSR
        sta     $f8
        jsr     PutTag
        ldy     #P_SR
        lda     ($f9),y
        ldy     #7
        jsr     PutHex
        ldy     #10
        lda     #<dTM
        sta     $f7
        lda     #>dTM
        sta     $f8
        jsr     PutTag
        ldy     #P_TIMER
        lda     ($f9),y
        ldy     #12
        jsr     PutHex
        ldy     #15
        lda     #<dSW
        sta     $f7
        lda     #>dSW
        sta     $f8
        jsr     PutTag
        ldy     #P_SWEEP
        lda     ($f9),y
        ldy     #17
        jsr     PutHex
        ldy     #20
        lda     #<dWB
        sta     $f7
        lda     #>dWB
        sta     $f8
        jsr     PutTag
        ldy     #P_WOBBLE
        lda     ($f9),y
        ldy     #22
        jsr     PutHex
        ldy     #25
        lda     #<dTH
        sta     $f7
        lda     #>dTH
        sta     $f8
        jsr     PutTag
        lda     thresh
        ldy     #27
        jmp     PutHex

DrawStatus
        ldx     #20
        jsr     RowPtr
        ldy     #$00
        lda     #$20
stClear
        sta     ($fb),y
        iny
        cpy     #16
        bcc     stClear
        lda     sfxActive
        beq     stUsePreset
        lda     playFreqH
        jmp     stCmp
stUsePreset
        jsr     EffectPtr
        ldy     #P_FREQ_H
        lda     ($f9),y
stCmp
        cmp     thresh
        bcc     stWobble
        lda     #<tSweep
        sta     $f7
        lda     #>tSweep
        sta     $f8
        jmp     stMode
stWobble
        lda     #<tWobble
        sta     $f7
        lda     #>tWobble
        sta     $f8
stMode
        ldy     #$00
        jsr     PutTag
        lda     sfxActive
        beq     stIdle
        lda     sfxHold
        bne     stHold
        lda     #<tPlay
        sta     $f7
        lda     #>tPlay
        sta     $f8
        jmp     stWord
stHold
        lda     #<tHold
        sta     $f7
        lda     #>tHold
        sta     $f8
        jmp     stWord
stIdle
        lda     #<tIdle
        sta     $f7
        lda     #>tIdle
        sta     $f8
stWord
        ldy     #$08
        jmp     PutTag

;
; X = row, Y = column. String at $fd/$fe, screen-codes, zero ended.
; RowPtr leaves $fb screen and $fd color — so copy the string aside first.
;
PrintAt
        stx     prRow
        sty     prCol
        jsr     RowPtrFromA
        lda     prCol
        jsr     AddCol
        ldy     #$00
printLoop
        lda     ($f7),y
        beq     printDone
        sta     ($fb),y
        iny
        bne     printLoop
printDone
        rts

RowPtrFromA
        ; string still in $fd. Park it, then point at the row.
        lda     $fd
        sta     $f7
        lda     $fe
        sta     $f8
        ldx     prRow
        jsr     RowPtr
        rts

;
; X = row 0-24. $fb/$fc screen, $fd/$fe color.
;
RowPtr
        lda     rowLo,x
        sta     $fb
        lda     rowHi,x
        sta     $fc
        sta     $fe
        lda     $fb
        sta     $fd
        lda     $fe
        clc
        adc     #$d4
        sta     $fe
        rts

AddCol
        clc
        adc     $fb
        sta     $fb
        lda     $fc
        adc     #$00
        sta     $fc
        lda     $fd
        clc
        adc     prCol
        sta     $fd
        lda     $fe
        adc     #$00
        sta     $fe
        rts

;
; Write the zero-ended string at $f7 to column Y on the current row.
;
PutTag
        sty     tmpY
        ldy     #$00
tagLoop
        lda     ($f7),y
        beq     tagDone
        sty     tmpC
        ldy     tmpY
        sta     ($fb),y
        inc     tmpY
        ldy     tmpC
        iny
        bne     tagLoop
tagDone
        rts

;
; A = value, Y = column on the current row.
;
PutHex
        sty     tmpY
        pha
        lsr
        lsr
        lsr
        lsr
        tax
        lda     HexDig,x
        ldy     tmpY
        sta     ($fb),y
        pla
        and     #$0f
        tax
        lda     HexDig,x
        iny
        sta     ($fb),y
        rts

HexDig  .byte   $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
        .byte   $01,$02,$03,$04,$05,$06

effColor .byte  $0e

wait        .byte   0
effectIndex .byte   0
paramIndex  .byte   0
lastKey     .byte   $40
repDelay    .byte   0
sfxActive   .byte   0
sfxHold     .byte   0
thresh      .byte   $05
playFreqL   .byte   0
playFreqH   .byte   0
playSweep   .byte   0
playWobble  .byte   0
playTimer   .byte   0
adjStep     .byte   1
adjIndex    .byte   0
tmpX        .byte   0
tmpY        .byte   0
tmpC        .byte   0
prRow       .byte   0
prCol       .byte   0

Work    .fill   EFFECT_N*P_COUNT

effLo   .byte   <Work, <Work+P_COUNT, <Work+2*P_COUNT, <Work+3*P_COUNT
        .byte   <Work+4*P_COUNT, <Work+5*P_COUNT, <Work+6*P_COUNT
effHi   .byte   >Work, >Work+P_COUNT, >Work+2*P_COUNT, >Work+3*P_COUNT
        .byte   >Work+4*P_COUNT, >Work+5*P_COUNT, >Work+6*P_COUNT

; Screen-code strings (uppercase). A=1 ... Z=26, space=$20, digit=$30+.
tTitle  .byte   $13,$06,$18,$20,$0c,$01,$02,$00                 ; SFX LAB
tHelp1  .byte   $31,$2d,$37,$20,$05,$06,$06,$05,$0b,$14,$20     ; 1-7 EFFEKT
        .byte   $20,$13,$10,$01,$03,$05,$20,$13,$10,$05,$0c,$01 ;  SPACE SPELA
        .byte   $20,$20,$12,$20,$12,$05,$13,$05,$14,$00         ;  R RESET
tRule1  .byte   $06,$12,$05,$11,$20,$08,$09,$20,$3e,$3d,$20     ; FREQ HI >=
        .byte   $14,$08,$12,$05,$13,$08,$20,$3a,$20             ; THRESH :
        .byte   $13,$17,$05,$05,$10,$00                         ; SWEEP
tRule2  .byte   $05,$0c,$13,$05,$20,$06,$12,$05,$11,$20,$0c,$0f ; ELSE FREQ LO
        .byte   $20,$05,$0f,$12,$20,$17,$0f,$02,$02,$0c,$05,$00 ;  EOR WOBBLE
tLegend .byte   $17,$16,$20,$31,$31,$20,$14,$12,$09,$20         ; WV 11 TRI
        .byte   $32,$31,$20,$13,$01,$17,$20                     ; 21 SAW
        .byte   $34,$31,$20,$10,$15,$0c,$20                     ; 41 PUL
        .byte   $38,$31,$20,$0e,$13,$05,$00                     ; 81 NSE
tHelp2  .byte   $15,$2f,$04,$20,$16,$01,$0c,$20                 ; U/D VAL
        .byte   $0c,$2f,$10,$20,$2b,$2d,$20                     ; L/P +-
        .byte   $01,$0e,$04,$12,$01,$20                         ; ANDRA
        .byte   $03,$3d,$20,$13,$14,$05,$07,$20,$31,$30,$00     ; C= STEG 10
tSweep  .byte   $13,$17,$05,$05,$10,$00
tWobble .byte   $17,$0f,$02,$02,$0c,$05,$00
tPlay   .byte   $13,$10,$05,$0c,$01,$12,$00
tHold   .byte   $08,$01,$0c,$0c,$05,$12,$00
tIdle   .byte   $16,$09,$0c,$01,$12,$00

dFL     .byte   $06,$0c,$00
dFH     .byte   $06,$08,$00
dPL     .byte   $10,$0c,$00
dPH     .byte   $10,$08,$00
dWV     .byte   $17,$16,$00
dVL     .byte   $16,$0c,$00
dAD     .byte   $01,$04,$00
dSR     .byte   $13,$12,$00
dTM     .byte   $14,$0d,$00
dSW     .byte   $13,$17,$00
dWB     .byte   $17,$02,$00
dTH     .byte   $14,$08,$00

nBullets .byte  $02,$15,$0c,$0c,$05,$14,$13,$00                 ; BULLETS
nHoming  .byte  $08,$0f,$0d,$09,$0e,$07,$20,$00                 ; HOMING
nLaser   .byte  $0c,$01,$13,$05,$12,$20,$20,$00                 ; LASER
nExplode .byte  $05,$18,$10,$0c,$0f,$04,$05,$00                 ; EXPLODE
nHit     .byte  $08,$09,$14,$20,$20,$20,$20,$00                 ; HIT____
nCrash   .byte  $03,$12,$01,$13,$08,$20,$20,$00                 ; CRASH__
nAlarm   .byte  $01,$0c,$01,$12,$0d,$20,$20,$00                 ; ALARM__

lFreqL  .byte   $06,$12,$05,$11,$20,$0c,$0f,$00                 ; FREQ LO
lFreqH  .byte   $06,$12,$05,$11,$20,$08,$09,$00
lPwL    .byte   $10,$15,$0c,$13,$05,$20,$0c,$0f,$00             ; PULSE LO
lPwH    .byte   $10,$15,$0c,$13,$05,$20,$08,$09,$00
lWave   .byte   $17,$01,$16,$05,$00
lAD     .byte   $01,$14,$14,$2f,$04,$05,$03,$00                 ; ATT/DEC
lblSR  .byte   $13,$15,$13,$2f,$12,$05,$0c,$00                 ; SUS/REL
lTimer  .byte   $14,$09,$0d,$05,$12,$00
lSweep  .byte   $13,$17,$05,$05,$10,$00
lWobble .byte   $17,$0f,$02,$02,$0c,$05,$00
lVolume .byte   $16,$0f,$0c,$15,$0d,$05,$00
lThresh .byte   $14,$08,$12,$05,$13,$08,$00

nameLo  .byte   <nBullets, >nBullets
        .byte   <nHoming, >nHoming
        .byte   <nLaser, >nLaser
        .byte   <nExplode, >nExplode
        .byte   <nHit, >nHit
        .byte   <nCrash, >nCrash
        .byte   <nAlarm, >nAlarm
nameHi = nameLo+1

labelLo .byte   <lFreqL, >lFreqL
        .byte   <lFreqH, >lFreqH
        .byte   <lPwL, >lPwL
        .byte   <lPwH, >lPwH
        .byte   <lWave, >lWave
        .byte   <lAD, >lAD
        .byte   <lblSR, >lblSR
        .byte   <lTimer, >lTimer
        .byte   <lSweep, >lSweep
        .byte   <lWobble, >lWobble
        .byte   <lVolume, >lVolume
        .byte   <lThresh, >lThresh
labelHi = labelLo+1

rowLo
        .byte   <$0400, <$0428, <$0450, <$0478, <$04a0
        .byte   <$04c8, <$04f0, <$0518, <$0540, <$0568
        .byte   <$0590, <$05b8, <$05e0, <$0608, <$0630
        .byte   <$0658, <$0680, <$06a8, <$06d0, <$06f8
        .byte   <$0720, <$0748, <$0770, <$0798, <$07c0
rowHi
        .byte   >$0400, >$0428, >$0450, >$0478, >$04a0
        .byte   >$04c8, >$04f0, >$0518, >$0540, >$0568
        .byte   >$0590, >$05b8, >$05e0, >$0608, >$0630
        .byte   >$0658, >$0680, >$06a8, >$06d0, >$06f8
        .byte   >$0720, >$0748, >$0770, >$0798, >$07c0

; Game defaults (11 bytes: FL FH PL PH WV AD SR TM SW WB VL). Thresh is global.
; Match game.asm SfxPresets (HIT/CRASH/ALARM are placeholders).
Defaults
        .byte   $02,$03,$87,$2f,$81,$07,$28,$0a,$11,$a7,$2f     ; 1 bullets
        .byte   $00,$3f,$03,$0b,$13,$01,$ee,$08,$06,$61,$1f     ; 2 homing
        .byte   $10,$cd,$08,$09,$65,$01,$fc,$14,$0b,$63,$1b     ; 3 laser
        .byte   $0c,$cb,$08,$11,$81,$08,$fd,$1b,$4c,$66,$0f     ; 4 explode
        .byte   $20,$18,$00,$08,$81,$02,$48,$06,$08,$44,$0c     ; 5 hit
        .byte   $10,$40,$00,$10,$81,$06,$8a,$28,$18,$55,$12     ; 6 crash
        .byte   $00,$30,$80,$0c,$41,$02,$a8,$2c,$02,$90,$0e     ; 7 alarm

defLo   .byte   <Defaults, >Defaults
        .byte   <Defaults+P_COUNT, >Defaults+P_COUNT
        .byte   <Defaults+2*P_COUNT, >Defaults+2*P_COUNT
        .byte   <Defaults+3*P_COUNT, >Defaults+3*P_COUNT
        .byte   <Defaults+4*P_COUNT, >Defaults+4*P_COUNT
        .byte   <Defaults+5*P_COUNT, >Defaults+5*P_COUNT
        .byte   <Defaults+6*P_COUNT, >Defaults+6*P_COUNT
defHi = defLo+1
