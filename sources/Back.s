; Back.s : 背景
;


; モジュール宣言
;
    .module Back

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Back.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 背景を初期化する
;
_BackInitialize::

    ; レジスタの保存

    ; 背景の初期化
    ld      hl, #backDefault
    ld      de, #_back
    ld      bc, #BACK_LENGTH
    ldir

    ; パターンネームの転送
    ld      hl, #(backPatternName + 0x0000)
    ld      de, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      bc, #0x0300
    call    LDIRVM
    ld      hl, #(backPatternName + 0x0300)
    ld      de, #(APP_PATTERN_NAME_TABLE + 0x0400)
    ld      bc, #0x0300
    call    LDIRVM

    ; レジスタの復帰

    ; 終了
    ret


; 背景を更新する
;
_BackUpdate::

    ; レジスタの保存

    ; フレームの更新
    ld      hl, #(_back + BACK_FRAME)
    inc     (hl)

    ; 色の更新
    ld      a, (hl)
    and     #0x0f
    jr      nz, 10$
    call    _SystemGetRandom
    and     #0x18
    ld      (_back + BACK_COLOR), a

;   ; BGM の再生
;   rrca
;   rrca
;   rrca
;   add     a, #SOUND_BGM_0
;   call    _SoundPlayBgm
10$:

    ; 色の取得
    ld      a, (_back + BACK_COLOR)
    ld      c, a

    ; ビデオレジスタの更新
    ld      a, (hl)
    and     #0x0f
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #backVideoRegister
    add     hl, de
    ld      de, #(_videoRegister + VDP_R2)
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de

    ; レジスタの復帰
    
    ; 終了
    ret

; 背景を描画する
;
_BackRender::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; 背景をクリアする
;
_BackClear::

    ; レジスタの保存

    ; ビデオレジスタの更新
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; 背景の初期値
;
backDefault:

    .db     BACK_STATE_NULL
    .db     BACK_FRAME_NULL
    .db     BACK_COLOR_NULL

; ビデオレジスタ
;
backVideoRegister:

    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0040) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0080) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0400) >> 10
    .db     (APP_COLOR_TABLE + 0x00c0) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0400) >> 10
    .db     (APP_COLOR_TABLE + 0x0100) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0400) >> 10
    .db     (APP_COLOR_TABLE + 0x0140) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0180) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00
    .db     (APP_PATTERN_NAME_TABLE + 0x0000) >> 10
    .db     (APP_COLOR_TABLE + 0x0000) >> 6
    .db     (APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11
    .db     0x00

; パターンネーム
;
backPatternName:

    ; 0
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x81, 0x82, 0x83, 0x84
    .db     0x85, 0x86, 0x87, 0x88, 0x89, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8a, 0x8b, 0x8c, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x8d, 0x8e, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0x91, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x92, 0x93, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x94, 0x95, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x96, 0x97, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x98, 0x99, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9a, 0x9b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x9e, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0xa1, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xa2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa3, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xa4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd8, 0xd9, 0xda
    .db     0xdb, 0xdc, 0xdd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa5, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xa6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xde, 0xf0, 0xf1
    .db     0xf2, 0xf3, 0xdf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xa8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xf4, 0x00
    .db     0x00, 0xf5, 0xe1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa9, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xaa, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe2, 0xf6, 0x00
    .db     0x00, 0xf7, 0xe3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xab, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xac, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe4, 0xf8, 0xf9
    .db     0xfa, 0xfb, 0xe5, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xad, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xae, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe6, 0xe7, 0xe8
    .db     0xe9, 0xea, 0xeb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xaf, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb1, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xb2, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb4, 0xb5, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb8, 0xb9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xba, 0xbb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbc, 0xbd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbe, 0xbf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0xc1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc4, 0xc5, 0xc6, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0xc7, 0xc8, 0xc9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xca, 0xcb, 0xcc, 0xcd, 0xce
    .db     0xcf, 0xd0, 0xd1, 0xd2, 0xd3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

    ; 1
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x81, 0x82, 0x83
    .db     0x84, 0x85, 0x86, 0x87, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x88, 0x89, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x8a, 0x8b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8c, 0x8d, 0x00, 0xb8, 0xb9, 0xba
    .db     0xbb, 0xbc, 0xbd, 0x00, 0x8e, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90, 0x91, 0x00, 0xbe, 0xd8, 0xd9, 0xda
    .db     0xdb, 0xdc, 0xdd, 0xbf, 0x00, 0x92, 0x93, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x94, 0x00, 0xc0, 0xde, 0xdf, 0x00, 0x00
    .db     0x00, 0x00, 0xe0, 0xe1, 0xc1, 0x00, 0x95, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x96, 0x00, 0xc2, 0xe2, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0xe3, 0xc3, 0x00, 0x97, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x98, 0x00, 0xc4, 0xe4, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0xe5, 0xc5, 0x00, 0x99, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9a, 0x00, 0xc6, 0xe6, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0xe7, 0xc7, 0x00, 0x9b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9c, 0x00, 0xc8, 0xe8, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0xe9, 0xc9, 0x00, 0x9d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9e, 0x00, 0xca, 0xea, 0xeb, 0x00, 0x00
    .db     0x00, 0x00, 0xec, 0xed, 0xcb, 0x00, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0xa1, 0x00, 0xcc, 0xee, 0xef, 0xf0
    .db     0xf1, 0xf2, 0xf3, 0xcd, 0x00, 0xa2, 0xa3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa4, 0xa5, 0x00, 0xce, 0xcf, 0xd0
    .db     0xd1, 0xd2, 0xd3, 0x00, 0xa6, 0xa7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa8, 0xa9, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0xaa, 0xab, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xac, 0xad, 0xae, 0xaf
    .db     0xb0, 0xb1, 0xb2, 0xb3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 背景
;
_back::
    
    .ds     BACK_LENGTH
