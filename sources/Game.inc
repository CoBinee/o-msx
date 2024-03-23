; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER              =   0x00
GAME_SPRITE_ENEMY               =   0x20
GAME_SPRITE_SHOT                =   0x60
GAME_SPRITE_BOMB                =   0x70
GAME_SPRITE_SCORE               =   0x10
GAME_SPRITE_FIREWORK            =   0x20

; ゲーム
GAME_PROC_L                     =   0x00
GAME_PROC_H                     =   0x01
GAME_STATE                      =   0x02
GAME_FLAG                       =   0x03
GAME_FRAME                      =   0x04
GAME_COUNT                      =   0x05
GAME_SCORE_L                    =   0x06
GAME_SCORE_H                    =   0x07
GAME_DIGIT                      =   0x08
GAME_LENGTH                     =   0x09

; 処理
GAME_PROC_NULL                  =   0x00

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_IDLE                 =   0x10
GAME_STATE_START                =   0x20
GAME_STATE_PLAY                 =   0x30
GAME_STATE_OVER                 =   0x40
GAME_STATE_CLEAR                =   0x50

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_TOP_BIT               =   0x00
GAME_FLAG_TOP                   =   (1 << GAME_FLAG_TOP)

; フレーム
GAME_FRAME_NULL                 =   0x00

; カウント
GAME_COUNT_NULL                 =   0x00

; スコア
GAME_SCORE_NULL                 =   0x0000
GAME_SCORE_MAXIMUM              =   0x0fff

; 桁数
GAME_DIGIT_NULL                 =   0x00

; Z 位置
GAME_Z_NEAR                     =   0x00
GAME_Z_SHORT                    =   0x20
GAME_Z_FAR                      =   0xc0

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameTransferPatternName
    .globl  _GameSubScore
    
; 外部変数宣言
;

    .globl  _game
