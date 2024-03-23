; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_PROC_L                    =   0x00
ENEMY_PROC_H                    =   0x01
ENEMY_STATE                     =   0x02
ENEMY_FLAG                      =   0x03
ENEMY_LIFE                      =   0x04
ENEMY_DAMAGE                    =   0x05
ENEMY_POSITION_L_L              =   0x06
ENEMY_POSITION_L_H              =   0x07
ENEMY_POSITION_Z_L              =   0x08
ENEMY_POSITION_Z_H              =   0x09
ENEMY_POSITION_X                =   0x0a
ENEMY_POSITION_Y                =   0x0b
ENEMY_SPEED_L_L                 =   0x0c
ENEMY_SPEED_L_H                 =   0x0d
ENEMY_SPEED_Z_L                 =   0x0e
ENEMY_SPEED_Z_H                 =   0x0f
ENEMY_ACCEL_L                   =   0x10
ENEMY_ACCEL_H                   =   0x11
ENEMY_R_0                       =   0x12
ENEMY_R_1                       =   0x13
ENEMY_COLOR                     =   0x14
ENEMY_ANIMATION                 =   0x15
ENEMY_LENGTH                    =   0x16

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_STRAIGHT             =   0x01
ENEMY_TYPE_ROUND                =   0x02
ENEMY_TYPE_CURVE                =   0x03
ENEMY_TYPE_BOSS                 =   0x0d
ENEMY_TYPE_BULLET               =   0x0e
ENEMY_TYPE_BOMB                 =   0x0f

; 処理
ENEMY_PROC_NULL                 =   0x00

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_HIT_PLAYER_BIT       =   0x00
ENEMY_FLAG_HIT_PLAYER           =   (1 << ENEMY_FLAG_HIT_PLAYER_BIT)
ENEMY_FLAG_HIT_SHOT_BIT         =   0x01
ENEMY_FLAG_HIT_SHOT             =   (1 << ENEMY_FLAG_HIT_SHOT_BIT)
ENEMY_FLAG_TURN_BIT             =   0x02
ENEMY_FLAG_TURN                 =   (1 << ENEMY_FLAG_TURN_BIT)
ENEMY_FLAG_BOSS_BIT             =   0x07
ENEMY_FLAG_BOSS                 =   (1 << ENEMY_FLAG_BOSS_BIT)

; ライフ
ENEMY_LIFE_NULL                 =   0x00
ENEMY_LIFE_BOSS                 =   0x04

; ダメージ
ENEMY_DAMAGE_NULL               =   0x00
ENEMY_DAMAGE_FRAME              =   0x08

; 位置
ENEMY_POSITION_NULL             =   0x00

; 速度
ENEMY_SPEED_NULL                =   0x00
ENEMY_SPEED_MAXIMUM             =   0x04

; 加速度
ENEMY_ACCEL_NULL                =   0x00
ENEMY_ACCEL_CURVE               =   0x0020
ENEMY_ACCEL_BULLET              =   0x0018

; 半径
ENEMY_R_NULL                    =   0x00
ENEMY_R_ONE                     =   0x08

; 色
ENEMY_COLOR_NULL                =   VDP_COLOR_TRANSPARENT
ENEMY_COLOR_BOSS                =   VDP_COLOR_DARK_RED
ENEMY_COLOR_DAMAGE              =   VDP_COLOR_MEDIUM_RED
ENEMY_COLOR_BOMB                =   VDP_COLOR_MEDIUM_RED

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00

; エントリ
ENEMY_ENTRY                     =   0x10

; 生成
ENEMY_BORN_STATE                =   0x00
ENEMY_BORN_TYPE                 =   0x01
ENEMY_BORN_COUNT                =   0x02
ENEMY_BORN_RANGE                =   0x03
ENEMY_BORN_FRAME                =   0x04
ENEMY_BORN_FLAG                 =   0x05
ENEMY_BORN_POSITION_L           =   0x06
ENEMY_BORN_POSITION_Z           =   0x07
ENEMY_BORN_SPEED_L              =   0x08
ENEMY_BORN_SPEED_Z              =   0x09
ENEMY_BORN_ACCEL_L              =   0x0a
ENEMY_BORN_ACCEL_H              =   0x0b
ENEMY_BORN_COLOR                =   0x0c
ENEMY_BORN_LENGTH               =   0x0d

; 生成／状態
ENEMY_BORN_STATE_NULL           =   0x00

; 生成／数
ENEMY_BORN_COUNT_NULL           =   0x00

; 生成／連なり
ENEMY_BORN_RANGE_NULL           =   0x00

; 生成／フレーム
ENEMY_BORN_FRAME_NULL           =   0x00

; 残り
ENEMY_REST_STATE                =   0x00
ENEMY_REST_BORN                 =   0x01
ENEMY_REST_ZAKO                 =   0x02
ENEMY_REST_BOSS                 =   0x03
ENEMY_REST_LENGTH               =   0x04

; 残り／状態
ENEMY_REST_STATE_NULL           =   0x00

; 残り／生成
ENEMY_REST_BORN_NULL            =   0x00

; 残り／ザコ
ENEMY_REST_ZAKO_NULL            =   0x00
ENEMY_REST_ZAKO_MAXIMUM         =   100

; 残り／ボス
ENEMY_REST_BOSS_NULL            =   0x00
ENEMY_REST_BOSS_MAXIMUM         =   0x08

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyBorn
    .globl  _EnemyHit
    .globl  _EnemyClear
    .globl  _EnemyGetRestZako
    .globl  _EnemyGetRestBoss

; 外部変数宣言
;

    .globl  _enemy
