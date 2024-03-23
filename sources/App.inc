; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_COLOR_TABLE                 =   0x2000
APP_PATTERN_NAME_TABLE          =   0x2800
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; アプリケーション
APP_STATE                       =   0x00
APP_FRAME                       =   0x01
APP_SCORE_L                     =   0x02
APP_SCORE_H                     =   0x03
APP_LENGTH                      =   0x04

; 状態
APP_STATE_NULL                  =   0x00
APP_STATE_GAME_INITIALIZE       =   0x01
APP_STATE_GAME_UPDATE           =   0x02

; フレーム
APP_FRAME_NULL                  =   0x00

; スコア
APP_SCORE_NULL                  =   0x0000
APP_SCORE_MAXIMUM               =   0xffff

; 数値
APP_NUMBER_COLOR_RED            =   0x40
APP_NUMBER_COLOR_GREEN          =   0x48
APP_NUMBER_COLOR_BLUE           =   0x50
APP_NUMBER_COLOR_YELLOW         =   0x58
APP_NUMBER_COLOR_CYAN           =   0x60
APP_NUMBER_COLOR_MAGENTA        =   0x68
APP_NUMBER_COLOR_GRAY           =   0x70
APP_NUMBER_COLOR_WHITE          =   0x78

; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppNull
    .globl  _AppUpdateScore

; 外部変数宣言
;

; 状態
    .globl  _app
    