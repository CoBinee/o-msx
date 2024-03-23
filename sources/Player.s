; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Ring.inc"
    .include    "Game.inc"
    .include    "Shot.inc"
    .include	"Player.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; 処理の設定
    ld      hl, #PlayerStart
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_player + PLAYER_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; 位置の更新
    ld      a, (_player + PLAYER_POSITION_L_H)
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Z_H)
    ld      d, a
    call    _RingGetLZtoXY
    ld      (_player + PLAYER_POSITION_X), de

    ; 半径の更新
    ld      a, (_player + PLAYER_POSITION_Z_H)
    ld      c, a
    ld      b, #PLAYER_R_ONE
    call    _RingGetRadius
    ld      (_player + PLAYER_R), a

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; 本体の描画
    ld      a, (_player + PLAYER_BLINK)
    and     #PLAYER_BLINK_INTERVAL
    jr      nz, 19$
    ld      hl, (_player + PLAYER_POSITION_X)
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    ld      a, (_player + PLAYER_R)
    ld      b, a
    ld      c, #PLAYER_COLOR_BODY
    call    _RingPrintOne
19$:

    ; 爆発の描画
    ld      a, (_player + PLAYER_BOMB_ANIMATION)
    or      a
    jr      z, 29$
    sub     #PLAYER_BOMB_ANIMATION_FRAME
    neg
    srl     a
    ld      b, a
    ld      a, (_player + PLAYER_R)
    add     a, b
    ld      b, a
    ld      c, #PLAYER_COLOR_BOMB
    ld      hl, (_player + PLAYER_BOMB_X)
    ld      de, #(_sprite + GAME_SPRITE_BOMB)
    call    _RingPrintAll
29$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを開始する
;
PlayerStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_HIT_BIT, (hl)

    ; 点滅の設定
    ld      a, #PLAYER_BLINK_START
    ld      (_player + PLAYER_BLINK), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 処理の更新
    ld      hl, #PlayerPlay
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 左右の操作
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      nz, 110$
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      nz, 120$

    ; 停止
100$:
    ld      hl, (_player + PLAYER_SPEED_L)
    ld      de, #PLAYER_SPEED_BRAKE
    ld      a, h
    or      l
    jr      z, 103$
    ld      a, h
    or      h
    jp      p, 101$
;   or      a
    adc     hl, de
    jp      m, 103$
    jr      102$
101$:
;   or      a
    sbc     hl, de
    jp      p, 103$
102$:
    ld      hl, #0x0000
103$:
    ld      (_player + PLAYER_SPEED_L), hl
    jr      130$

    ; 左へ移動
110$:
    ld      hl, (_player + PLAYER_SPEED_L)
    ld      de, #PLAYER_SPEED_ACCEL
    or      a
    sbc     hl, de
    jp      p, 111$
    ld      a, h
    cp      #-PLAYER_SPEED_MAXIMUM
    jr      nc, 111$
    ld      hl, #-(PLAYER_SPEED_MAXIMUM << 8)
111$:
    ld      (_player + PLAYER_SPEED_L), hl
    jr      130$

    ; 右へ移動
120$:
    ld      hl, (_player + PLAYER_SPEED_L)
    ld      de, #PLAYER_SPEED_ACCEL
    or      a
    adc     hl, de
    jp      m, 121$
    jr      z, 121$
    ld      a, h
    cp      #PLAYER_SPEED_MAXIMUM
    jr      c, 121$
    ld      hl, #(PLAYER_SPEED_MAXIMUM << 8)
121$:
    ld      (_player + PLAYER_SPEED_L), hl
;   jr      130$

    ; 左右の移動
130$:
    ld      hl, (_player + PLAYER_POSITION_L_L)
    ld      de, (_player + PLAYER_SPEED_L)
    add     hl, de
    ld      (_player + PLAYER_POSITION_L_L), hl

    ; 左右の操作の完了
190$:

    ; 自弾を撃つ
    ld      a, (_player + PLAYER_BLINK)
    or      a
    jr      nz, 29$
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 29$
    ld      a, (_player + PLAYER_POSITION_L_H)
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Z_H)
    ld      d, a
    call    _ShotFire
29$:

    ; 点滅の更新
    ld      hl, #(_player + PLAYER_BLINK)
    ld      a, (hl)
    or      a
    jr      z, 39$
    dec     (hl)
    jr      nz, 39$
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_HIT_BIT, (hl)
39$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがミスした
;
PlayerMiss:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_HIT_BIT, (hl)

    ; 点滅の設定
    ld      a, #PLAYER_BLINK_MISS
    ld      (_player + PLAYER_BLINK), a

    ; 爆発の設定
    ld      hl, (_player + PLAYER_POSITION_X)
    ld      (_player + PLAYER_BOMB_X), hl
    ld      a, #PLAYER_BOMB_ANIMATION_FRAME
    ld      (_player + PLAYER_BOMB_ANIMATION), a

    ; スコアを減らす
    ld      de, #0x0100
    call    _GameSubScore

    ; SE の再生
    ld      a, #SOUND_SE_DAMAGE
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 左右の移動
    ld      hl, (_player + PLAYER_POSITION_L_L)
    ld      de, (_player + PLAYER_SPEED_L)
    add     hl, de
    ld      (_player + PLAYER_POSITION_L_L), hl

    ; 点滅の更新
    ld      hl, #(_player + PLAYER_BLINK)
    dec     (hl)

    ; 爆発の更新
    ld      hl, #(_player + PLAYER_BOMB_ANIMATION)
    dec     (hl)
    jr      nz, 19$

    ; 処理の更新
    ld      hl, #PlayerPlay
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがゲームオーバーになる
;
PlayerOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_HIT_BIT, (hl)

    ; 速度の設定
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPEED_L), hl

    ; 点滅の設定
    ld      a, #PLAYER_BLINK_INTERVAL
    ld      (_player + PLAYER_BLINK), a

    ; 爆発の設定
    ld      hl, (_player + PLAYER_POSITION_X)
    ld      (_player + PLAYER_BOMB_X), hl
    ld      a, #PLAYER_BOMB_ANIMATION_FRAME
    ld      (_player + PLAYER_BOMB_ANIMATION), a

    ; SE の再生
    ld      a, #SOUND_SE_MISS
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 爆発の更新
    ld      hl, #(_player + PLAYER_BOMB_ANIMATION)
    ld      a, (hl)
    or      a
    jr      z, 19$
    dec     (hl)
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤにヒットする
;
_PlayerHit::

    ; レジスタの保存

    ; de < 相手の Z/L 位置

    ; 速度の設定
    ld      a, (_player + PLAYER_POSITION_L_H)
    sub     e
    ld      a, #PLAYER_SPEED_MAXIMUM
    jp      p, 10$
    neg
10$:
    ld      (_player + PLAYER_SPEED_H), a
    xor     a
    ld      (_player + PLAYER_SPEED_L), a

    ; 処理の更新
    ld      hl, #PlayerMiss
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤをクリアする
;
_PlayerClear::

    ; レジスタの保存

    ; 処理の更新
    ld      hl, #PlayerOver
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤの位置を取得する
;
_PlayerGetPosition::

    ; レジスタの保存

    ; a > L 位置

    ; 位置の取得
    ld      a, (_player + PLAYER_POSITION_L_H)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; プレイヤの初期値
;
playerDefault:

    .dw     PLAYER_PROC_NULL
    .db     PLAYER_STATE_NULL
    .db     PLAYER_FLAG_NULL
    .dw     0x0000 ; PLAYER_POSITION_NULL
    .dw     0x0000 ; PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_NULL
    .dw     PLAYER_SPEED_NULL
    .db     PLAYER_R_NULL
    .db     PLAYER_BLINK_NULL
    .db     PLAYER_BOMB_NULL
    .db     PLAYER_BOMB_NULL
    .db     PLAYER_BOMB_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH

