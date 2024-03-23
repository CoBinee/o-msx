; Firework.s : 花火
;


; モジュール宣言
;
    .module Firework

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Ring.inc"
    .include    "Game.inc"
    .include	"Firework.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 花火を初期化する
;
_FireworkInitialize::
    
    ; レジスタの保存
    
    ; 花火の初期化
    ld      hl, #(_firework + 0x0000)
    ld      de, #(_firework + 0x0001)
    ld      bc, #(FIREWORK_LENGTH * FIREWORK_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; スプライトの初期化
    xor     a
    ld      (fireworkSpriteRotate), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 花火を更新する
;
_FireworkUpdate::
    
    ; レジスタの保存

    ; 花火の走査
    ld      ix, #_firework
    ld      de, #FIREWORK_LENGTH
    ld      b, #FIREWORK_ENTRY
10$:

    ; 状態の判定
    ld      a, FIREWORK_STATE(ix)
    or      a
    jr      z, 19$

    ; 半径の更新
    inc     FIREWORK_R(ix)
    ld      a, FIREWORK_R(ix)
    cp      #0x11
    jr      c, 19$
    ld      FIREWORK_STATE(ix), #FIREWORK_STATE_NULL
;   jr      19$

    ; 次の花火へ
19$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; 花火を描画する
;
_FireworkRender::

    ; レジスタの保存

    ; 花火の走査
    ld      ix, #_firework
    ld      a, (fireworkSpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      b, #FIREWORK_ENTRY
10$:
    push    bc

    ; 描画の確認
    ld      a, FIREWORK_STATE(ix)
    or      a
    jr      z, 19$

    ; スプライトの描画
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_FIREWORK)
    add     hl, de
    ex      de, hl
    ld      l, FIREWORK_POSITION_X(ix)
    ld      h, FIREWORK_POSITION_Y(ix)
    ld      b, FIREWORK_R(ix)
    ld      c, FIREWORK_COLOR(ix)
    call    _RingPrintAll
    pop     de

    ; スプライトのローテート
    ld      a, e
    add     a, #0x10
    and     #(FIREWORK_ENTRY * 0x10 - 0x01)
    ld      e, a

    ; 次の花火へ
19$:
    ld      bc, #FIREWORK_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      a, (fireworkSpriteRotate)
    add     a, #0x10
    and     #(FIREWORK_ENTRY * 0x10 - 0x01)
    ld      (fireworkSpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; 花火を打ち上げる
;
_FireworkLaunch::

    ; レジスタの保存

    ; 花火の検索
    ld      ix, #_firework
    ld      b, #FIREWORK_ENTRY
10$:
    ld      a, FIREWORK_STATE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      bc, #FIREWORK_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      19$

    ; 花火の設定
11$:
    inc     FIREWORK_STATE(ix)
    call    _SystemGetRandom
    and     #0x7f
    ld      e, a
    call    _SystemGetRandom
    and     #0x3f
    add     a, e
    add     a, #0x20
    ld      FIREWORK_POSITION_X(ix), a
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      d, a
    call    _SystemGetRandom
    and     #0x40
    jr      z, 12$
    ld      a, d
    add     a, #0x60
    ld      d, a
12$:
    ld      FIREWORK_POSITION_Y(ix), d
    ld      FIREWORK_R(ix), #0x00
    call    _SystemGetRandom
    and     #0x03
    ld      c, a
    ld      b, #0x00
    ld      hl, #fireworkColor
    add     hl, bc
    ld      a, (hl)
    ld      FIREWORK_COLOR(ix), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 色
;
fireworkColor:

    .db     VDP_COLOR_LIGHT_RED
    .db     VDP_COLOR_LIGHT_GREEN
    .db     VDP_COLOR_LIGHT_BLUE
    .db     VDP_COLOR_LIGHT_YELLOW
    .db     VDP_COLOR_DARK_RED
    .db     VDP_COLOR_DARK_GREEN
    .db     VDP_COLOR_DARK_BLUE
    .db     VDP_COLOR_DARK_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 花火
;
_firework::
    
    .ds     FIREWORK_LENGTH * FIREWORK_ENTRY

; スプライト
;
fireworkSpriteRotate:

    .ds     0x01
