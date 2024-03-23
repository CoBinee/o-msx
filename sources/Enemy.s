; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Ring.inc"
    .include    "Game.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; エネミーの初期化
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; スプライトの初期化
    xor     a
    ld      (enemySpriteRotate), a

    ; 生成の初期化
    ld      hl, #enemyBornDefault
    ld      de, #enemyBorn
    ld      bc, #ENEMY_BORN_LENGTH
    ldir

    ; エネミーの残りの初期化
    ld      hl, #enemyRestDefault
    ld      de, #enemyRest
    ld      bc, #ENEMY_REST_LENGTH
    ldir
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; 種類別の処理
    ld      l, ENEMY_PROC_L(ix)
    ld      h, ENEMY_PROC_H(ix)
    ld      a, h
    or      l
    jr      z, 19$
    ld      de, #11$
    push    de
    jp      (hl)
;   pop     hl
11$:

    ; 位置の更新
    ld      e, ENEMY_POSITION_L_H(ix)
    ld      d, ENEMY_POSITION_Z_H(ix)
    call    _RingGetLZtoXY
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d

    ; 半径の更新
    ld      a, ENEMY_ANIMATION(ix)
    srl     a
    ld      e, a
    ld      c, ENEMY_POSITION_Z_H(ix)
    ld      b, ENEMY_R_0(ix)
    call    _RingGetRadius
    add     a, e
    ld      ENEMY_R_1(ix), a

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE(ix)
    or      a
    jr      z, 12$
    dec     ENEMY_DAMAGE(ix)
12$:

    ; 次のエネミーへ
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      a, (enemySpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; 描画の確認
    ld      a, ENEMY_PROC_H(ix)
    or      ENEMY_PROC_L(ix)
    jr      z, 19$

    ; スプライトの描画
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    ex      de, hl
    ld      l, ENEMY_POSITION_X(ix)
    ld      h, ENEMY_POSITION_Y(ix)
    ld      b, ENEMY_R_1(ix)
    ld      c, ENEMY_COLOR(ix)
    ld      a, ENEMY_DAMAGE(ix)
    or      a
    jr      z, 11$
    ld      c, #ENEMY_COLOR_DAMAGE
11$:
    call    _RingPrintOne
    pop     de

    ; スプライトのローテート
    ld      a, e
    add     a, #0x04
    and     #(ENEMY_ENTRY * 0x04 - 0x01)
    ld      e, a

    ; 次のエネミーへ
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      a, (enemySpriteRotate)
    add     a, #0x04
    and     #(ENEMY_ENTRY * 0x04 - 0x01)
    ld      (enemySpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの種類別の処理を行う
;

; ENEMY_TYPE_NULL
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_STRAIGHT
EnemyStraight:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    xor     a
    ld      ENEMY_SPEED_L_L(ix), a
    ld      ENEMY_SPEED_L_H(ix), a

    ; 初期化の官僚
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyMove
    jr      nc, 19$
    call    EnemyTurn
    call    nc, EnemyKill
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_ROUND
EnemyRound:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の官僚
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyMove
    jr      nc, 19$
    call    EnemyTurn
    call    nc, EnemyKill
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_CURVE
EnemyCurve:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      hl, #(ENEMY_SPEED_MAXIMUM << 8)
    bit     #0x07, ENEMY_ACCEL_H(ix)
    jr      nz, 00$
    ld      hl, #(-ENEMY_SPEED_MAXIMUM << 8)
00$:
    ld      ENEMY_SPEED_L_L(ix), l
    ld      ENEMY_SPEED_L_H(ix), h

    ; 初期化の官僚
    inc     ENEMY_STATE(ix)
09$:

    ; 速度の更新
    ld      e, ENEMY_ACCEL_L(ix)
    ld      d, ENEMY_ACCEL_H(ix)
    ld      l, ENEMY_SPEED_L_L(ix)
    ld      h, ENEMY_SPEED_L_H(ix)
    or      a
    adc     hl, de
    ld      a, h
    jp      p, 10$
    cp      #-ENEMY_SPEED_MAXIMUM
    jr      nc, 19$
    ld      hl, #(-ENEMY_SPEED_MAXIMUM << 8)
    jr      11$
10$:
    ld      a, h
    cp      #ENEMY_SPEED_MAXIMUM
    jr      c, 19$
    ld      hl, #(ENEMY_SPEED_MAXIMUM << 8)
;   jr      11$
11$:
    ld      a, e
    cpl
    ld      e, a
    ld      a, d
    cpl
    ld      d, a
    inc     de
    ld      ENEMY_ACCEL_L(ix), e
    ld      ENEMY_ACCEL_H(ix), d
19$:
    ld      ENEMY_SPEED_L_L(ix), l
    ld      ENEMY_SPEED_L_H(ix), h

    ; 移動
    call    EnemyMove
    jr      nc, 29$
    call    EnemyTurn
    call    nc, EnemyKill
29$:

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_BOSS
EnemyBoss:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の官僚
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyMove
    ld      a, ENEMY_POSITION_Z_H(ix)
    cp      #0x30
    jr      nc, 10$
    xor     a
    ld      ENEMY_POSITION_Z_L(ix), a
    ld      ENEMY_POSITION_Z_H(ix), #0x30
    ld      ENEMY_SPEED_Z_L(ix), a
    ld      ENEMY_SPEED_Z_H(ix), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_BULLET
EnemyBullet:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の官僚
    inc     ENEMY_STATE(ix)
09$:

    ; 速度の更新
    ld      de, #ENEMY_ACCEL_BULLET
    ld      l, ENEMY_SPEED_L_L(ix)
    ld      h, ENEMY_SPEED_L_H(ix)
    call    _PlayerGetPosition
    sub     ENEMY_POSITION_L_H(ix)
    jp      p, 10$
    or      a
    sbc     hl, de
    jp      p, 19$
    ld      a, h
    cp      #-ENEMY_SPEED_MAXIMUM
    jr      nc, 19$
    ld      hl, #(-ENEMY_SPEED_MAXIMUM << 8)
    jr      19$
10$:
    or      a
    adc     hl, de
    jp      m, 19$
    ld      a, h
    cp      #ENEMY_SPEED_MAXIMUM
    jr      c, 19$
    ld      hl, #(ENEMY_SPEED_MAXIMUM << 8)
;   jr      19$
19$:
    ld      ENEMY_SPEED_L_L(ix), l
    ld      ENEMY_SPEED_L_H(ix), h

    ; 移動
    call    EnemyMove
    call    c, EnemyKill

    ; 色の更新
    call    _SystemGetRandom
    and     #0x03
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyColorBullet
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_COLOR(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_BOMB
EnemyBomb:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    res     #ENEMY_FLAG_HIT_PLAYER_BIT, ENEMY_FLAG(ix)
    res     #ENEMY_FLAG_HIT_SHOT_BIT, ENEMY_FLAG(ix)

    ; 色の設定
    ld      ENEMY_COLOR(ix), #ENEMY_COLOR_BOMB

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #0xff

    ; 初期化の官僚
    inc     ENEMY_STATE(ix)
09$:

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)
    ld      a, ENEMY_ANIMATION(ix)
    cp      #(0x04 * 0x02)
    call    nc, EnemyKill

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを移動させる
;
EnemyMove:

    ; レジスタの保存

    ; cf > 1 = 画面外

    ; L 位置の移動
    ld      e, ENEMY_SPEED_L_L(ix)
    ld      d, ENEMY_SPEED_L_H(ix)
    ld      l, ENEMY_POSITION_L_L(ix)
    ld      h, ENEMY_POSITION_L_H(ix)
    add     hl, de
    ld      ENEMY_POSITION_L_L(ix), l
    ld      ENEMY_POSITION_L_H(ix), h

    ; Z 位置の移動
    ld      e, ENEMY_SPEED_Z_L(ix)
    ld      d, ENEMY_SPEED_Z_H(ix)
    ld      l, ENEMY_POSITION_Z_L(ix)
    ld      h, ENEMY_POSITION_Z_H(ix)
    add     hl, de
    ld      ENEMY_POSITION_Z_L(ix), l
    ld      ENEMY_POSITION_Z_H(ix), h
    
    ; 画面外の判定
    ld      a, h
    cp      #GAME_Z_FAR
    ccf

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが反転する
;
EnemyTurn:

    ; レジスタの保存

    ; cf > 1 = 反転した

    ; 反転
    bit     #ENEMY_FLAG_TURN_BIT, ENEMY_FLAG(ix)
    jr      nz, 10$
    or      a
    jr      19$
10$:
    res     #ENEMY_FLAG_TURN_BIT, ENEMY_FLAG(ix)
    ld      l, ENEMY_POSITION_Z_L(ix)
    ld      h, ENEMY_POSITION_Z_H(ix)
    cp      #((0x0100 + GAME_Z_FAR) / 2)
    jr      nc, 11$
    ld      de, #(GAME_Z_FAR << 8)
    or      a
    sbc     hl, de
    ex      de, hl
    or      a
    sbc     hl, de
    jr      12$
11$:
    ld      a, h
    cpl
    ld      h, a
    ld      a, l
    cpl
    ld      l, a
    inc     hl
;   jr      12$
12$:
    ld      ENEMY_POSITION_Z_L(ix), l
    ld      ENEMY_POSITION_Z_H(ix), h
    ld      a, ENEMY_SPEED_Z_L(ix)
    cpl
    ld      l, a
    ld      a, ENEMY_SPEED_Z_H(ix)
    cpl
    ld      h, a
    inc     hl
    ld      ENEMY_SPEED_Z_L(ix), l
    ld      ENEMY_SPEED_Z_H(ix), h
    scf
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを生成する
;
_EnemyBorn::

    ; レジスタの保存

    ; 数の確認
    ld      a, (enemyBorn + ENEMY_BORN_COUNT)
    or      a
    jr      nz, 09$

    ; 種類と数の設定
    ld      hl, #(enemyRest + ENEMY_REST_STATE)
    ld      a, (hl)
    or      a
    jr      nz, 00$
    ld      a, (enemyRest + ENEMY_REST_ZAKO)
    or      a
    jr      nz, 00$
    ld      a, #ENEMY_TYPE_BOSS
    ld      (enemyBorn + ENEMY_BORN_TYPE), a
    ld      a, #ENEMY_REST_BOSS_MAXIMUM
    ld      (enemyBorn + ENEMY_BORN_COUNT), a
    inc     (hl)
    jr      01$
00$:
    call    _SystemGetRandom
    and     #0x03
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyBornType
    add     hl, de
    ld      a, (hl)
    ld      (enemyBorn + ENEMY_BORN_TYPE), a
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x04
    ld      (enemyBorn + ENEMY_BORN_COUNT), a
;   jr      01$
01$:

    ; 連なりの設定
    ld      a, (enemyBorn + ENEMY_BORN_TYPE)
    rrca
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyBornRangeMask
    add     hl, de
    call    _SystemGetRandom
    and     (hl)
    ld      (enemyBorn + ENEMY_BORN_RANGE), a

    ; 色の設定
    ld      hl, #(enemyBorn + ENEMY_BORN_COLOR)
    inc     (hl)
09$:

    ; 生成できるか
    ld      a, (enemyRest + ENEMY_REST_BORN)
    ld      hl, #(enemyBorn + ENEMY_BORN_COUNT)
    cp      (hl)
    jp      c, 90$

    ; ボスの生成
100$:
    ld      a, (enemyBorn + ENEMY_BORN_TYPE)
    cp      #ENEMY_TYPE_BOSS
    jr      nz, 200$

    ; エネミーを同時に生成
    ld      bc, #((ENEMY_REST_BOSS_MAXIMUM << 8) | 0x00)
101$:

    ; エネミーの生成
    call    EnemyGetNull
    jr      nc, 109$
    push    bc
    ld      hl, #enemyDefaultBoss
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     bc
    ld      ENEMY_POSITION_L_H(ix), c
    ld      a, c
    add     a, #(0x0100 / ENEMY_REST_BOSS_MAXIMUM)
    ld      c, a

    ; エネミーの残りの更新
    ld      hl, #(enemyRest + ENEMY_REST_BORN)
    dec     (hl)

    ; 数の更新
    ld      hl, #(enemyBorn + ENEMY_BORN_COUNT)
    dec     (hl)

    ; 次の生成へ
    djnz    101$

    ; 生成の更新
    xor     a
    ld      (enemyBorn + ENEMY_BORN_STATE), a
109$:
    jp      90$

    ; ザコの生成
200$:

    ; 初期化
    ld      a, (enemyBorn + ENEMY_BORN_STATE)
    or      a
    jr      nz, 209$

    ; フレームの設定
    xor     a
    ld      (enemyBorn + ENEMY_BORN_FRAME), a

    ; フラグの設定
    call    _SystemGetRandom
    and     #ENEMY_FLAG_TURN
    ld      (enemyBorn + ENEMY_BORN_FLAG), a

    ; L 位置の設定
    call    EnemyGetRandomPosition
    ld      (enemyBorn + ENEMY_BORN_POSITION_L), a

    ; L 速度の設定
    call    _SystemGetRandom
    and     #0x0f
    sub     #0x08
    ccf
    adc     a, #0x00
    ld      (enemyBorn + ENEMY_BORN_SPEED_L), a

    ; Z 位置／速度の設定
    ld      c, #GAME_Z_FAR
    call    _SystemGetRandom
    and     #0x03
    sub     #0x02
    jr      c, 201$
    inc     a
    inc     a
    ld      c, #0x00
    jr      202$
201$:
    dec     a
202$:
    ld      (enemyBorn + ENEMY_BORN_SPEED_Z), a
    ld      a, c
    ld      (enemyBorn + ENEMY_BORN_POSITION_Z), a

    ; 加速度の設定
    ld      hl, #ENEMY_ACCEL_CURVE
    call    _SystemGetRandom
    and     #0x20
    jr      z, 203$
    ld      hl, #-ENEMY_ACCEL_CURVE
203$:
    ld      (enemyBorn + ENEMY_BORN_ACCEL_L), hl

    ; 初期化の完了
    ld      hl, #(enemyBorn + ENEMY_BORN_STATE)
    inc     (hl)
209$:

    ; フレームの更新
    ld      a, (enemyBorn + ENEMY_BORN_FRAME)
    or      a
    jr      z, 210$
    dec     a
    ld      (enemyBorn + ENEMY_BORN_FRAME), a
    jp      90$

    ; エネミーの生成
210$:
    call    EnemyGetNull
    jp      nc, 90$
    push    ix
    pop     hl
    ld      e, l
    ld      d, h
    inc     de
    ld      bc, #(ENEMY_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      a, (enemyBorn + ENEMY_BORN_TYPE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_PROC_L(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_PROC_H(ix), a
;   inc     hl
    ld      a, (enemyBorn + ENEMY_BORN_FLAG)
    or      #(ENEMY_FLAG_HIT_PLAYER | ENEMY_FLAG_HIT_SHOT)
    ld      ENEMY_FLAG(ix), a
    ld      ENEMY_LIFE(ix), #0x01
    ld      bc, (enemyBorn + ENEMY_BORN_POSITION_L)
    ld      a, (enemyBorn + ENEMY_BORN_RANGE)
    or      a
    jr      z, 211$
    call    EnemyGetRandomPosition
    ld      c, a
211$:
    ld      ENEMY_POSITION_L_H(ix), c
    ld      ENEMY_POSITION_Z_H(ix), b
    ld      bc, (enemyBorn + ENEMY_BORN_SPEED_L)
    ld      ENEMY_SPEED_L_H(ix), c
    ld      ENEMY_SPEED_Z_H(ix), b
    ld      bc, (enemyBorn + ENEMY_BORN_ACCEL_L)
    ld      ENEMY_ACCEL_L(ix), c
    ld      ENEMY_ACCEL_H(ix), b
    ld      ENEMY_R_0(ix), #ENEMY_R_ONE
    ld      a, (enemyBorn + ENEMY_BORN_COLOR)
    and     #0x03
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyColorNormal
    add     hl, de
    ld      a, (hl)    
    ld      ENEMY_COLOR(ix), a

    ; エネミーの残りの更新
    ld      hl, #(enemyRest + ENEMY_REST_BORN)
    dec     (hl)

    ; フレームの設定
    ld      a, #0x08
    ld      (enemyBorn + ENEMY_BORN_FRAME), a

    ; 数の更新
    ld      hl, #(enemyBorn + ENEMY_BORN_COUNT)
    dec     (hl)
    jr      nz, 212$

    ; 生成の更新
    xor     a
    ld      (enemyBorn + ENEMY_BORN_STATE), a
212$:

    ; 生成の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_BULLET を生成する
;
EnemyBornBullet:

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy

    ; ix < エネミー

    ; エネミーの生成
    ld      a, (enemyRest + ENEMY_REST_BORN)
    or      a
    jr      z, 19$
    push    ix
    pop     iy
    call    EnemyGetNull
    ld      hl, #enemyDefaultBullet
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    ld      a, ENEMY_POSITION_L_H(iy)
    ld      ENEMY_POSITION_L_H(ix), a
    ld      a, ENEMY_POSITION_Z_H(iy)
    ld      ENEMY_POSITION_Z_H(ix), a

    ; エネミーの残りの更新
    ld      hl, #(enemyRest + ENEMY_REST_BORN)
    dec     (hl)
19$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 空のエネミーを取得する
;
EnemyGetNull:

    ; レジスタの保存
    push    bc
    push    de

    ; ix > エネミー
    ; cf > 1 = 取得の成功

    ; エネミーの検索
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_PROC_H(ix)
    or      ENEMY_PROC_L(ix)
    jr      z, 11$
    add     ix, de
    djnz    10$
    or      a
    jr      19$
11$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; エネミーのランダムな出現位置を取得する
;
EnemyGetRandomPosition:

    ; レジスタの保存
    push    de
    
    ; a > L 位置

    ; 位置の取得
    call    _SystemGetRandom
    and     #0x7f
    ld      e, a
    call    _SystemGetRandom
    and     #0x3f
    add     a, e
    add     a, #0x20
    ld      e, a
    call    _PlayerGetPosition
    add     a, e

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; エネミーを削除する
;
EnemyKill:

    ; レジスタの保存

    ; ix < エネミー

    ; エネミーの削除
    xor     a
    ld      ENEMY_PROC_L(ix), a
    ld      ENEMY_PROC_H(ix), a
    
    ; エネミーの残りの更新
    ld      hl, #(enemyRest + ENEMY_REST_BORN)
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

; エネミーにヒットする
;
_EnemyHit::

    ; レジスタの保存

    ; ix < エネミー

    ; 反射弾を撃つ
    ld      a, ENEMY_POSITION_Z_H(ix)
    cp      #GAME_Z_SHORT
    call    nc, EnemyBornBullet

    ; ダメージ
    dec     ENEMY_LIFE(ix)
    jr      z, 10$
    ld      ENEMY_DAMAGE(ix), #ENEMY_DAMAGE_FRAME

    ; SE の再生
    ld      a, #SOUND_SE_HIT
    call    _SoundPlaySe
    jr      19$

    ; 破壊
10$:
    ld      hl, #(enemyRest + ENEMY_REST_ZAKO)
    bit     #ENEMY_FLAG_BOSS_BIT, ENEMY_FLAG(ix)
    jr      z, 11$
    inc     hl
11$:
    ld      a, (hl)
    or      a
    jr      z, 12$
    dec     (hl)
12$:
    ld      hl, #EnemyBomb
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00

    ; SE の再生
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySe
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーをクリアする
;
_EnemyClear::

    ; レジスタの保存

    ; 処理の更新
    ld      hl, #EnemyBomb
    ld      de, #ENEMY_LENGTH
    xor     a
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_PROC_H(ix)
    or      ENEMY_PROC_L(ix)
    jr      z, 19$
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), a
19$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの残りを取得する
;
_EnemyGetRestZako::

    ; レジスタの保存

    ; a > 残りの数

    ; 残りの取得
    ld      a, (enemyRest + ENEMY_REST_ZAKO)

    ; レジスタの復帰

    ; 終了
    ret

_EnemyGetRestBoss::

    ; レジスタの保存

    ; a > 残りの数

    ; 残りの取得
    ld      a, (enemyRest + ENEMY_REST_BOSS)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 種類別の処理
;
enemyProc:
    
    .dw     EnemyNull
    .dw     EnemyStraight
    .dw     EnemyRound
    .dw     EnemyCurve
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyBoss
    .dw     EnemyBullet
    .dw     EnemyBomb

; エネミーの初期値
;
enemyDefaultBoss:

    .dw     EnemyBoss ; ENEMY_PROC_NULL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_BOSS | ENEMY_FLAG_HIT_PLAYER | ENEMY_FLAG_HIT_SHOT
    .db     ENEMY_LIFE_BOSS ; ENEMY_LIFE_NULL
    .db     ENEMY_DAMAGE_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     GAME_Z_FAR << 8 ; ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     ENEMY_SPEED_MAXIMUM << 8 ; ENEMY_SPEED_NULL
    .dw     -0x0200 ; ENEMY_SPEED_NULL
    .dw     ENEMY_ACCEL_NULL
    .db     ENEMY_R_ONE ; ENEMY_R_NULL
    .db     ENEMY_R_NULL
    .db     ENEMY_COLOR_BOSS ; ENEMY_COLOR_NULL
    .db     ENEMY_ANIMATION_NULL

enemyDefaultBullet:

    .dw     EnemyBullet ; ENEMY_PROC_NULL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_HIT_PLAYER
    .db     0xff ; ENEMY_LIFE_NULL
    .db     ENEMY_DAMAGE_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     0x0000 ; ENEMY_SPEED_NULL
    .dw     -0x0400 ; ENEMY_SPEED_NULL
    .dw     ENEMY_ACCEL_NULL
    .db     ENEMY_R_ONE ; ENEMY_R_NULL
    .db     ENEMY_R_NULL
    .db     ENEMY_COLOR_NULL
    .db     ENEMY_ANIMATION_NULL

; 生成の初期値
;
enemyBornDefault:

    .db     ENEMY_BORN_STATE_NULL
    .db     ENEMY_TYPE_NULL
    .db     ENEMY_BORN_COUNT_NULL
    .db     ENEMY_BORN_RANGE_NULL
    .db     ENEMY_BORN_FRAME_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .dw     ENEMY_ACCEL_NULL
    .db     ENEMY_COLOR_NULL

; 生成する種類
;
enemyBornType:

    .db     ENEMY_TYPE_STRAIGHT
    .db     ENEMY_TYPE_ROUND
    .db     ENEMY_TYPE_CURVE
    .db     ENEMY_TYPE_ROUND

; 連なり
;
enemyBornRangeMask:

    .db     0x00    ; ENEMY_TYPE_NULL
    .db     0x01    ; ENEMY_TYPE_STRAIGHT
    .db     0x00    ; ENEMY_TYPE_ROUND
    .db     0x00    ; ENEMY_TYPE_CURVE
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_???
    .db     0x00    ; ENEMY_TYPE_BOSS
    .db     0x00    ; ENEMY_TYPE_BULLET
    .db     0x00    ; ENEMY_TYPE_BOMB

; 色
;
enemyColorNormal:

    .db     VDP_COLOR_LIGHT_GREEN
    .db     VDP_COLOR_CYAN
    .db     VDP_COLOR_LIGHT_YELLOW
    .db     VDP_COLOR_MAGENTA

enemyColorBullet:

    .db     VDP_COLOR_DARK_RED
    .db     VDP_COLOR_DARK_GREEN
    .db     VDP_COLOR_DARK_BLUE
    .db     VDP_COLOR_DARK_YELLOW

; エネミーの残りの初期値
;
enemyRestDefault:

    .db     ENEMY_REST_STATE_NULL
    .db     ENEMY_ENTRY ; ENEMY_REST_BORN_NULL
    .db     ENEMY_REST_ZAKO_MAXIMUM ; ENEMY_REST_ZAKO_NULL
    .db     ENEMY_REST_BOSS_MAXIMUM ; ENEMY_REST_BOSS_NULL
    

; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; スプライト
;
enemySpriteRotate:

    .ds     0x01

; 生成
;
enemyBorn:

    .ds     ENEMY_BORN_LENGTH

; エネミーの残り
;
enemyRest:

    .ds     ENEMY_REST_LENGTH

