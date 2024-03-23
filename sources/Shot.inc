; Shot.inc : 自弾
;


; マクロの定義
;

; 自弾
SHOT_STATE                      =   0x00
SHOT_FLAG                       =   0x01
SHOT_POSITION_L_L               =   0x02
SHOT_POSITION_L_H               =   0x03
SHOT_POSITION_Z_L               =   0x04
SHOT_POSITION_Z_H               =   0x05
SHOT_POSITION_X                 =   0x06
SHOT_POSITION_Y                 =   0x07
SHOT_R                          =   0x08
SHOT_LENGTH                     =   0x09

; 状態
SHOT_STATE_NULL                 =   0x00

; フラグ
SHOT_FLAG_NULL                  =   0x00
SHOT_FLAG_HIT_BIT               =   0x00
SHOT_FLAG_HIT                   =   (1 << SHOT_FLAG_HIT_BIT)
SHOT_FLAG_DAMAGE_BIT            =   0x01
SHOT_FLAG_DAMAGE                =   (1 << SHOT_FLAG_DAMAGE_BIT)

; 位置
SHOT_POSITION_NULL              =   0x00

; 半径
SHOT_R_NULL                     =   0x00
SHOT_R_ONE                      =   0x04

; エントリ
SHOT_ENTRY                      =   0x04

; 速度
SHOT_SPEED                      =   0x0800

; 色
SHOT_COLOR                      =   VDP_COLOR_GRAY

; 外部関数宣言
;

    .globl  _ShotInitialize
    .globl  _ShotUpdate
    .globl  _ShotRender
    .globl  _ShotFire
    .globl  _ShotHit

; 外部変数宣言
;

    .globl  _shot
