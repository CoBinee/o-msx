; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_PROC_L                   =   0x00
PLAYER_PROC_H                   =   0x01
PLAYER_STATE                    =   0x02
PLAYER_FLAG                     =   0x03
PLAYER_POSITION_L_L             =   0x04
PLAYER_POSITION_L_H             =   0x05
PLAYER_POSITION_Z_L             =   0x06
PLAYER_POSITION_Z_H             =   0x07
PLAYER_POSITION_X               =   0x08
PLAYER_POSITION_Y               =   0x09
PLAYER_SPEED_L                  =   0x0a
PLAYER_SPEED_H                  =   0x0b
PLAYER_R                        =   0x0c
PLAYER_BLINK                    =   0x0d
PLAYER_BOMB_X                   =   0x0e
PLAYER_BOMB_Y                   =   0x0f
PLAYER_BOMB_ANIMATION           =   0x10
PLAYER_LENGTH                   =   0x11

; 処理
PLAYER_PROC_NULL                =   0x00

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_START              =   0x10
PLAYER_STATE_PLAY               =   0x20
PLAYER_STATE_MISS               =   0x30
PLAYER_STATE_OVER               =   0x40

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_HIT_BIT             =   0x00
PLAYER_FLAG_HIT                 =   (1 << PLAYER_FLAG_HIT_BIT)
PLAYER_FLAG_DAMAGE_BIT          =   0x01
PLAYER_FLAG_DAMAGE              =   (1 << PLAYER_FLAG_DAMAGE_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00

; 速度
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_MAXIMUM            =   0x02
PLAYER_SPEED_ACCEL              =   0x0040
PLAYER_SPEED_BRAKE              =   0x0020

; 半径
PLAYER_R_NULL                   =   0x00
PLAYER_R_ONE                    =   0x08

; 色
PLAYER_COLOR_NULL               =   VDP_COLOR_TRANSPARENT
PLAYER_COLOR_BODY               =   VDP_COLOR_WHITE
PLAYER_COLOR_BOMB               =   VDP_COLOR_LIGHT_RED

; 点滅
PLAYER_BLINK_NULL               =   0x00
PLAYER_BLINK_INTERVAL           =   0x02
PLAYER_BLINK_START              =   0x18
PLAYER_BLINK_MISS               =   0x30

; 爆発
PLAYER_BOMB_NULL                =   0x00
PLAYER_BOMB_ANIMATION_FRAME     =   (0x08 * 0x02)

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerHit
    .globl  _PlayerClear
    .globl  _PlayerGetPosition

; 外部変数宣言
;

    .globl  _player
