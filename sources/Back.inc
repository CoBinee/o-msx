; Back.inc : 背景
;


; マクロの定義
;

; 背景
BACK_STATE                      =   0x00
BACK_FRAME                      =   0x01
BACK_COLOR                      =   0x02
BACK_LENGTH                     =   0x03

; 状態
BACK_STATE_NULL                 =   0x00

; フレーム
BACK_FRAME_NULL                 =   0x00

; 色
BACK_COLOR_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _BackInitialize
    .globl  _BackUpdate
    .globl  _BackRender
    .globl  _BackClear

; 外部変数宣言
;

    .globl  _back
