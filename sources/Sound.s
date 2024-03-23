; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgm0_A, soundBgm0_B, soundNull
    .dw     soundBgm1, soundNull, soundNull

; 0
soundBgm0_A:

    .ascii  "T3@0V13,4L3"
    .ascii  "O3DEFDEFGE"
    .ascii  "O3FGAFGABGAFGEFDEC+"
    .ascii  "O3DO2AB-GAFGE"
    .db     0xff

soundBgm0_B:

    .ascii  "T3@0V13,4L3"
    .ascii  "R1O2AAAAAAAA"
    .ascii  "O2AAAAAAAAAAAAAAAA"
    .ascii  "O2AAAAAAAA1"
    .db     0xff

; 1
soundBgm1:

    .ascii  "T1@0V13,4L9O1CCCCCCCC"
    .db     0xff

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeShot
    .dw     soundSeHit
    .dw     soundSeBomb
    .dw     soundSeDamage
    .dw     soundSeMiss

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; ショット
soundSeShot:

    .ascii  "T1@0V13L0O2F+O6F+O2GO6C+O2G+O5G+O2AO5D+"
    .db     0x00

; ヒット
soundSeHit:

    .ascii  "T1@0V13L2O5AGBA"
    .db     0x00

; 爆発
soundSeBomb:

    .ascii  "T1@0V13L0O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-O3CO2D-O3D-O2CO3CO2D-O3D-O2CO3CO2D-O3D-O2CO3CO2D-O3D-O2C"
    .db     0x00

; ダメージ
soundSeDamage:

    .ascii  "T1@0L1O3V13CV12CV11CV10C"
    .db     0x00

; ミス
soundSeMiss:

    .ascii  "T1@0L0"
    .ascii  "V13O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
    .ascii  "V12O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
    .ascii  "V11O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
    .ascii  "V10O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
