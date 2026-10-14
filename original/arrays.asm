;testDirTableX    byte    $02,$01,$00,$ff,$fe,$ff,$00
;testDirTableY    byte    $00,$01,$02,$01,$00,$ff,$fe

testDirTableX    byte    $04,$02,$00,$fe,$fc,$fe,$00
testDirTableY    byte    $00,$02,$04,$04,$00,$fe,$fc

; Vars
scoreMultiplier         bytes 1*1
playerScore     bytes   1*6
force                   bytes 1*1
ships                   bytes 1*1
playerX                 bytes 1*1
playerY                 bytes 1*1
playerBoundY2           bytes 1*1
playerBoundY1           bytes 1*1
playerBoundX2           bytes 1*1
playerBoundX1           bytes 1*1
playerFrame             bytes 1*1
playerFrameCounter      bytes 1*1
playerIsHit             bytes 1*1
canFire                 bytes 1*1
fireDelay               bytes 1*1
shouldFirePlayerWeapon  bytes 1*1
playerMoveSpeed         bytes 1*1
xMoveAmount             bytes 1*1
yMoveAmount             bytes 1*1
playerWeapon            bytes 1*1
playerWeaponPower       bytes 1*1
invulnerableCounter     bytes 1*1
isInvulnerable          bytes 1*1

storedX                 bytes 1*1
storedY                 bytes 1*1
tmpBulletXBound         bytes 1*1
tmpBulletFrame          bytes 1*1
thunderBoltFrame        bytes 1*1
thunderBoltColorFrame  bytes 1*1

thunderBoltCoolDown bytes 1*1
thunderBoltX bytes 1*1
thunderBoltY bytes 1*1
savedThunderBoltX  bytes 1*1
savedThunderBoltY  bytes 1*1

enemyTickPointer    bytes 1*1
activeEnemyPointer  bytes 1*1
tmpActiveEnemiesPointer bytes 1*1
enemyToActivate  bytes 1*1

enemyWeaponStartX       bytes 1*1
enemyWeaponStartY       bytes 1*1
enemyWeaponStartXSpeed  bytes 1*1
enemyWeaponStartYSpeed  bytes 1*1
enemyWeaponStartType    bytes 1*1
tmpEnemyWeaponXBound    bytes 1*1

closestEnemyIndex       bytes 1*1
tempShortestDistanceX   bytes 1*1

explosionStartX bytes 1*1
explosionStartY bytes 1*1
explosionCol    bytes 1*1
explosionRow    bytes 1*1

explosions              bytes 1*maxExplosions
explosionsX         bytes   1*maxExplosions
explosionsY         bytes   1*maxExplosions
explosionCounters   bytes   1*maxExplosions
explosionFrames     bytes   1*maxExplosions
explosionCurrentFrame     bytes   1*maxExplosions
explosionColorFrame      bytes   1*maxExplosions

starField       bytes   1*maxStars
starX             bytes   1*maxStars
starY          bytes   1*maxStars
starFrame          bytes   1*maxStars
starColor       bytes   1*maxStars

; Arrays and tables
activeEnemies   bytes 1*maxActiveEnemies
enemyBoundX1   bytes 1*maxActiveEnemies
enemyBoundY1   bytes 1*maxActiveEnemies
enemyBoundX2   bytes 1*maxActiveEnemies
enemyBoundY2   bytes 1*maxActiveEnemies
enemies         bytes 1*totalEnemies
enemyX          bytes 1*totalEnemies
enemyY          bytes 1*totalEnemies
enemyMoveX      bytes 1*totalEnemies
enemyMoveY      bytes 1*totalEnemies
enemyIsHit      bytes 1*totalEnemies
enemyHitPoints  bytes 1*totalEnemies
enemySpriteFrame bytes  1*totalEnemies
enemySpriteFrameCounter bytes  1*totalEnemies

enemyWeapons            bytes 1*maxEnemyWeapons
enemyWeaponX            bytes 1*maxEnemyWeapons
enemyWeaponY            bytes 1*maxEnemyWeapons
enemyWeaponXSpeed       bytes 1*maxEnemyWeapons
enemyWeaponYSpeed       bytes 1*maxEnemyWeapons
enemyWeaponType         bytes 1*maxEnemyWeapons
enemyWeaponToRemove     bytes 1*maxEnemyWeapons

bullets         bytes 1*maxBullets
bulletsToRemove bytes 1*maxBullets
bulletX         bytes 1*maxBullets
bulletY         bytes 1*maxBullets
bulletFrame     bytes 1*maxBullets

homings         bytes 1*maxBullets
homingsToRemove bytes 1*maxBullets
homingX         bytes 1*maxBullets
homingY         bytes 1*maxBullets
homingXMoveR         bytes 1*maxBullets
homingXMoveL         bytes 1*maxBullets

PlayerFrameTable byte   $85,$83,$84,$80,$81,$82
PlayerColor      byte   $00,$07,$05,$03,$07

drops           bytes   1*maxDrops
dropX           bytes   1*maxDrops
dropY           bytes   1*maxDrops
dropType        bytes   1*maxDrops
dropFrame       bytes   1*maxDrops
dropFrameCounter   bytes   1*maxDrops
dropStartX     bytes   1*1
dropStartY     bytes   1*1
dropStartType  bytes   1*1

BulletLeftFrameTable    byte    $97,$96,$95,$94,$93,$92,$91,$90,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f
BulletCenterFrameTable  byte    $8f,$9e,$9d,$9c,$9b,$9a,$99,$98,$97,$96,$95,$94,$93,$92,$91,$90,$8f,$00
BulletRightFrameTable   byte    $8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$9e,$9d,$9c,$9b,$9a,$99,$98,$97,$96

ThunderBoltCenterFrameTable    byte    $8f,$8f,$b8,$b7,$b6,$b5,$b4,$b3,$b2,$b1,$b0,$af,$ae,$ad,$ac,$8f,$8f,$00
ThunderBoltRightFrameTable     byte    $8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f,$b8,$b7,$b6,$b5,$b4,$b3,$b2
ThunderBoltLeftFrameTable      byte    $b2,$b1,$b0,$af,$ae,$ad,$ac,$8f,$8f,$8f,$8f,$ab,$aa,$a9,$a8,$a7,$a6,$a5
ThunderBoltColorTable          byte    $03,$0e,$01,$03,$0e,$01,$03,$0e,$01,$03,$0e,$01,$03,$0e,$01,$03,$0e,$01

EnemyStartTick          byte    $01,$02,$03,$04,$06,$07,$09,$09,$09,$0b,$0c,$0d,$0e,$0f,$10,$11,$20,$21,$22,$23;,$1$02,$02,$02,$02,$02,$02,$03,$04,$05,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16
EnemyType               byte    $01,$02,$03,$01,$01,$02,$03,$03,$03,$02,$01,$01,$01,$02,$01,$02,$01,$02,$01,$02
EnemyStartX             byte    $40,$fa,$20,$30,$40,$50,$30,$50,$70,$40,$60,$80,$a0,$40,$40,$40,$40,$40,$40,$40;,$20,$40,$60,$80,$a0,$c0,$e0,$e8,$ea,$ef,$e0,$a0,$c0,$e0,$20,$40,$60,$80,$a0,$c0,$e0,$20,$40,$60,$80,$a0
EnemyStartY             byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


EnemyFrameTable         byte    $85,$86,$87,$88
; enemyType som mappar mot en tabell som sätter sprites...
; så tex enemyType

EnemyColor              byte    $04,$04,$04,$08,$04,$04,$04,$08,$02,$04,$02,$04,$02,$04,$04,$04,$04,$04,$04,$04
EnemyLife               byte    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20  ; how many hit points the enemy can take



explosionTableTopLeft   byte    $59,$5e,$63,$68,$20
explosionTableTopCenter   byte    $5a,$5f,$64,$69,$20
explosionTableTopRight   byte    $59,$5e,$63,$68,$20
explosionTableMiddleLeft   byte    $5b,$60,$65,$6a,$20
explosionTableMiddleCenter   byte    $5c,$61,$66,$6b,$20
explosionTableMiddleRight   byte    $5b,$60,$65,$6a,$20
explosionTableBottomLeft   byte    $5d,$62,$67,$6c,$20
explosionTableBottomCenter   byte    $5a,$5f,$64,$69,$20
explosionTableBottomRight   byte    $5d,$62,$67,$6c,$20
explosionColorTable   byte    $01,$01,$07,$0a,$02,$01,$01

DropFrameTable         byte    $c3,$c2,$c1,$c0,$20,$20

StarFrameTable         byte    $50,$51,$52,$53,$54,$55,$56,$57,$20,$20,$20

RNG24TABLE      byte    $01,$04,$06,$02,$12,$03,$05,$14,$10,$0B,$0F,$13,$07,$0E,$09,$11,$0C,$17,$16,$0A,$00,$0D,$15,$08,$0E,$10,$17,$0D,$04
RNG30TABLE      byte    $06,$04,$1D,$02,$10,$15,$07,$0F,$05,$16,$0C,$1A,$14,$11,$00,$18,$19,$12,$03,$17,$08,$1B,$0B,$0E,$13,$1C,$09,$0D,$0A,$01

ScreenColorL    byte    $00,$28,$50,$78,$a0,$c8,$f0,$18,$40,$68,$90,$b8,$e0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0,$00,$00,$00,$00,$00,$00,$00
ScreenColorH    byte    $d8,$d8,$d8,$d8,$d8,$d8,$d8,$d9,$d9,$d9,$d9,$d9,$d9,$da,$da,$da,$da,$da,$da,$da,$db,$db,$db,$db,$db,$d8,$d8,$d8,$d8,$d8,$d8,$d8
; Bank 2
ScreenRowsL     byte    $00,$28,$50,$78,$a0,$c8,$f0,$18,$40,$68,$90,$b8,$e0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0,$00,$00,$00,$00,$00,$00,$00 ; 4 st safe ScreenRowsL
ScreenRowsH     byte    $44,$44,$44,$44,$44,$44,$44,$45,$45,$45,$45,$45,$45,$46,$46,$46,$46,$46,$46,$46,$47,$47,$47,$47,$47,$44,$44,$44,$44,$44,$44,$44 ; 4 st safe ScreenRowsH
