; Firework.inc : 花火
;


; マクロの定義
;

; 花火
FIREWORK_STATE                  =   0x00
FIREWORK_POSITION_X             =   0x01
FIREWORK_POSITION_Y             =   0x02
FIREWORK_R                      =   0x03
FIREWORK_COLOR                  =   0x04
FIREWORK_LENGTH                 =   0x05

; 状態
FIREWORK_STATE_NULL             =   0x00

; 位置
FIREWORK_POSITION_NULL          =   0x00

; 半径
FIREWORK_R_NULL                 =   0x00

; 色
FIREWORK_COLOR_NULL             =   VDP_COLOR_TRANSPARENT

; エントリ
FIREWORK_ENTRY                  =   0x04

; 外部関数宣言
;

    .globl  _FireworkInitialize
    .globl  _FireworkUpdate
    .globl  _FireworkRender
    .globl  _FireworkLaunch

; 外部変数宣言
;

    .globl  _firework
