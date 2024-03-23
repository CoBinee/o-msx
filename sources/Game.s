; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Ring.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "Shot.inc"
    .include    "Back.inc"
    .include    "Firework.inc"

; 外部変数宣言
;
    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName
    
    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; スコアの初期化
    ld      hl, #(gameScoreCharacter + 0x0000)
    ld      de, #(gameScoreCharacter + 0x0001)
    ld      bc, #(0x0080 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 丸の初期化
    call    _RingInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; 自弾の初期化
    call    _ShotInitialize

    ; 背景の初期化
    call    _BackInitialize

    ; 花火の初期化
    call    _FireworkInitialize

    ; 転送の設定
    ld      hl, #GameTransfer
    ld      (_transfer), hl

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 処理の設定
    ld      hl, #GameIdle
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a

    ; 状態の設定
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_game + GAME_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    inc     (hl)

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを待機する
;
GameIdle:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; スコアの作成
    ld      hl, (_app + APP_SCORE_L)
    call    GameMakeScore
    ld      (_game + GAME_DIGIT), a

    ; BGM の再生
    ld      a, #SOUND_BGM_1
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 丸の更新
    call    _RingUpdate

    ; 背景の更新
    call    _BackUpdate

    ; 丸の描画
    call    _RingRender

    ; 背景の描画
    call    _BackRender

    ; スコアの表示
    ld      c, #VDP_COLOR_WHITE
    ld      a, (_game + GAME_DIGIT)
    ld      b, a
    call    GamePrintScore

    ; SPACE キーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 処理の更新
    ld      hl, #GameStart
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; カウントの設定
    ld      a, #0x30
    ld      (_game + GAME_COUNT), a

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒット判定
    call    GameHit

    ; 丸の更新
    call    _RingUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; 自弾の更新
    call    _ShotUpdate

    ; 背景の更新
    call    _BackUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; 丸の描画
    call    _RingRender

    ; プレイヤの描画
    call    _PlayerRender

    ; 自弾の描画
    call    _ShotRender

    ; 背景の描画
    call    _BackRender

    ; ステータスの表示
    call    GamePrintStatus

    ; カウントの更新
    ld      hl, #(_game + GAME_COUNT)
    dec     (hl)
    jr      nz, 19$

    ; 処理の更新
    ld      hl, #GamePlay
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

;   ; BGM の再生
;   ld      a, #SOUND_BGM_0
;   call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒット判定
    call    GameHit

    ; 丸の更新
    call    _RingUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの生成
    call    _EnemyBorn

    ; エネミーの更新
    call    _EnemyUpdate

    ; 自弾の更新
    call    _ShotUpdate

    ; 背景の更新
    call    _BackUpdate

    ; ステータスの更新
    call    GameUpdateStatus

    ; 丸の描画
    call    _RingRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 自弾の描画
    call    _ShotRender

    ; 背景の描画
    call    _BackRender

    ; ステータスの表示
    call    GamePrintStatus

    ; 残りの監視
    call    _EnemyGetRestBoss
    or      a
    jr      nz, 10$
    ld      hl, #GameClear
    jr      18$
10$:

    ; スコアの監視
    ld      hl, (_game + GAME_SCORE_L)
    ld      a, h
    or      l
    jr      nz, 19$
    ld      hl, #GameOver
;   jr      18$

    ; 処理の更新
18$:
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; プレイヤのクリア
    call    _PlayerClear

    ; 背景のクリア
    call    _BackClear

    ; スコアの作成
    ld      hl, (_game + GAME_SCORE_L)
    call    GameMakeScore
    ld      (_game + GAME_DIGIT), a

    ; カウントの設定
    ld      a, #0x60
    ld      (_game + GAME_COUNT), a

    ; BGM の停止
    ld      a, #SOUND_BGM_NULL
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 丸の更新
    call    _RingUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 自弾の更新
    call    _ShotUpdate

;   ; 背景の更新
;   call    _BackUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; 丸の描画
    call    _RingRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 自弾の描画
    call    _ShotRender

;   ; 背景の描画
;   call    _BackRender

    ; ステータスの表示
    call    GamePrintStatus

    ; スコアの表示
    ld      c, #VDP_COLOR_WHITE
    ld      a, (_game + GAME_DIGIT)
    ld      b, a
    ld      a, (_game + GAME_COUNT)
    cp      #0x30
    call    c, GamePrintScore

    ; カウントの更新
    ld      hl, #(_game + GAME_COUNT)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      19$
10$:

    ; SPACE キーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; エネミーのクリア
    call    _EnemyClear

    ; 背景のクリア
    call    _BackClear

    ; スコアの作成
    ld      hl, (_game + GAME_SCORE_L)
    call    GameMakeScore
    ld      (_game + GAME_DIGIT), a

    ; スコアの更新
    ld      hl, (_game + GAME_SCORE_L)
    call    _AppUpdateScore
    jr      nc, 00$
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_TOP_BIT, (hl)
00$:

    ; カウントの設定
    ld      a, #0x60
    ld      (_game + GAME_COUNT), a

    ; BGM の停止
    ld      a, #SOUND_BGM_NULL
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 丸の更新
    call    _RingUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 自弾の更新
    call    _ShotUpdate

;   ; 背景の更新
;   call    _BackUpdate

;   ; ステータスの更新
;   call    GameUpdateStatus

    ; 丸の描画
    call    _RingRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 自弾の描画
    call    _ShotRender

;   ; 背景の描画
;   call    _BackRender

    ; ステータスの表示
    call    GamePrintStatus

    ; 結果の表示
    ld      a, (_game + GAME_COUNT)
    cp      #0x30
    jr      nc, 19$

    ; スコアの表示
    ld      c, #VDP_COLOR_WHITE
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_TOP_BIT, a
    jr      z, 10$
    ld      a, (_game + GAME_FRAME)
    and     #0x03
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameScoreColor
    add     hl, de
    ld      c, (hl)
10$:
    ld      a, (_game + GAME_DIGIT)
    ld      b, a
    call    GamePrintScore

    ; 花火の表示
    ld      a, (_game + GAME_FRAME)
    and     #0x07
    call    z, _FireworkLaunch
    call    _FireworkUpdate
    call    _FireworkRender

    ; 結果表示の完了
19$:


    ; カウントの更新
    ld      hl, #(_game + GAME_COUNT)
    ld      a, (hl)
    or      a
    jr      z, 20$
    dec     (hl)
    jr      29$
20$:

    ; SPACE キーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 29$

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; VRAM へ転送する
;
GameTransfer:

    ; レジスタの保存

    ; d < ポート #0
    ; e < ポート #1

    ; ステータスの転送
    ld      hl, #0x0000
    ld      b, #0x20
    call    _GameTransferPatternName

;   ; デバッグとステータスの転送
;   ld      hl, #0x02e0
;   ld      b, #0x20
;   call    _GameTransferPatternName

    ; レジスタの復帰

    ; 終了
    ret

; パターンネームを VRAM へ転送する
;
_GameTransferPatternName::

    ; レジスタの保存
    push    de

    ; d  < ポート #0
    ; e  < ポート #1
    ; hl < 相対アドレス
    ; b  < 転送バイト数

    ; パターンネームテーブルの取得    
    ld      a, (_videoRegister + VDP_R2)
    add     a, a
    add     a, a
    add     a, h

    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
    or      #0b01000000
    out     (c), a

    ; パターンネームテーブルの転送
    ld      c, d
    ld      de, #_patternName
    add     hl, de
10$:
    outi
    jp      nz, 10$

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; ヒット判定を行う
;
GameHit:

    ; レジスタの保存

    ; プレイヤの位置の取得
    ld      a, (_player + PLAYER_POSITION_L_H)
    ld      l, a
    ld      a, (_player + PLAYER_FLAG)
    and     #PLAYER_FLAG_HIT
    ld      h, a

    ; エネミーとの判定
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_PROC_H(ix)
    or      ENEMY_PROC_L(ix)
    jr      z, 190$

    ; エネミーの位置の取得
    ld      e, ENEMY_POSITION_L_H(ix)
    ld      d, ENEMY_POSITION_Z_H(ix)
    ld      c, ENEMY_R_0(ix)

    ; 自弾との判定
    bit     #ENEMY_FLAG_HIT_SHOT_BIT, ENEMY_FLAG(ix)
    jr      z, 119$
    ld      iy, #_shot
    ld      b, #SHOT_ENTRY
110$:
    push    bc
    ld      a, SHOT_STATE(iy)
    or      a
    jr      z, 118$
    ld      a, SHOT_POSITION_L_H(iy)
    sub     e
    jp      p, 111$
    neg
111$:
    cp      c
    jr      nc, 118$
    ld      a, SHOT_POSITION_Z_H(iy)
    sub     d
    jp      p, 112$
    neg
112$:
    cp      c
    jr      nc, 118$
    call    _EnemyHit
    call    _ShotHit
118$:
    ld      bc, #SHOT_LENGTH
    add     iy, bc
    pop     bc
    djnz    110$
119$:

    ; プレイヤとの判定
    bit     #ENEMY_FLAG_HIT_PLAYER_BIT, ENEMY_FLAG(ix)
    jr      z, 129$
    ld      a, h
    or      a
    jr      z, 129$
    ld      a, l
    sub     e
    jp      p, 120$
    neg
120$:
    cp      c
    jr      nc, 129$
    ld      a, d
    cp      c
    jr      nc, 129$
    call    _PlayerHit
129$:

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを更新する
;
GameUpdateStatus:

    ; レジスタの保存

    ; スコアの更新
    ld      hl, (_game + GAME_SCORE_L)
    ld      a, h
    or      l
    jr      z, 10$
    dec     hl
    ld      (_game + GAME_SCORE_L), hl
10$:

    ; 残りの更新

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを表示する
;
GamePrintStatus:

    ; レジスタの保存

    ; スコアの表示
    ld      hl, (_game + GAME_SCORE_L)
    ld      de, #(_patternName + 0x0000)
    ld      c, #APP_NUMBER_COLOR_WHITE
    call    GamePrintNumber

    ; 残りの表示
    call    _EnemyGetRestZako
    or      a
    jr      z, 20$
    ld      l, a
    ld      h, #0x00
    ld      de, #(_patternName + 0x0018)
    ld      c, #APP_NUMBER_COLOR_YELLOW
    call    GamePrintNumber
    jr      29$
20$:
    ld      hl, #(_patternName + 0x0020 - ENEMY_REST_BOSS_MAXIMUM)
    call    _EnemyGetRestBoss
    ld      c, a
    ld      a, #ENEMY_REST_BOSS_MAXIMUM
    sub     c
    jr      z, 22$
    ld      b, a
    ld      a, #0x40
21$:
    ld      (hl), a
    inc     hl
    djnz    21$
22$:
    ld      a, c
    or      a
    jr      z, 29$
    ld      b, a
    ld      a, #0x43
23$:
    ld      (hl), a
    inc     hl
    djnz    23$
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; スコアを減らす
;
_GameSubScore::

    ; レジスタの保存

    ; de < 減らすスコア

    ; スコアの減算
    ld      hl, (_game + GAME_SCORE_L)
    or      a
    sbc     hl, de
    jr      nc, 10$
    ld      hl, #0x0000
10$:
    ld      (_game + GAME_SCORE_L), hl

    ; レジスタの復帰

    ; 終了
    ret

; スコアを作成する
;
GameMakeScore:

    ; レジスタの保存

    ; hl < スコア
    ; a  > 桁数

    ; スプライトの作成
    push    hl
    ld      de, #gameScoreCharacter
    ld      c, #0x00
    ld      a, h
    or      l
    jr      nz, 10$
    dec     c
10$:
    push    hl
    ld      a, h
    rlca
    rlca
    call    11$
    rlca
    rlca
    call    11$
    rlca
    rlca
    call    11$
    rlca
    rlca
    call    11$
    pop     hl
    ld      a, l
    rlca
    rlca
    call    11$
    rlca
    rlca
    call    11$
    rlca
    rlca
    call    11$
    rlca
    rlca
    call    11$
    jr      19$
11$:
    push    af
    and     #0x03
    jr      z, 12$
    ld      c, #0xff
12$:
    push    bc
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #(_patternTable + 0x0a00)
    add     hl, bc
    pop     bc
    ld      b, #0x08
13$:
    ld      a, (hl)
    and     c
    ld      (de), a
    inc     hl
    inc     de
    djnz    13$
    ld      hl, #0x0008
    add     hl, de
    ex      de, hl
    pop     af
    ret
19$:

    ; スプライトジェネレータの転送
    ld      hl, #gameScoreCharacter
    ld      de, #(APP_SPRITE_GENERATOR_TABLE + 0x0780)
    ld      bc, #0x0080
    call    LDIRVM
    pop     hl

    ; 桁数を数える
    ld      a, h
    or      a
    jr      z, 20$
    ld      c, #0x08
    rlca
    jr      c, 29$
    rlca
    jr      c, 29$
    dec     c
    rlca
    jr      c, 29$
    rlca
    jr      c, 29$
    dec     c
    rlca
    and     #0xc0
    jr      nz, 29$
    dec     c
    jr      29$
20$:
    ld      a, l
    ld      c, #0x04
    rlca
    jr      c, 29$
    rlca
    jr      c, 29$
    dec     c
    rlca
    jr      c, 29$
    rlca
    jr      c, 29$
    dec     c
    rlca
    jr      c, 29$
    rlca
    jr      c, 29$
    dec     c
    rlca
    jr      c, 29$
    rlca
    jr      c, 29$
    ld      c, #0x08
;   jr      29$
29$:
    ld      a, c

    ; レジスタの復帰

    ; 終了
    ret

; スコアを表示する
;
GamePrintScore:

    ; レジスタの保存

    ; c < 色
    ; b < 桁数

    ; 位置の取得
    ld      a, #0x08
    sub     b
    add     a, a
    add     a, a
    ld      b, a

    ; スプライトの表示
    ld      a, (_game + GAME_FRAME)
    and     #0x03
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameScoreSprite
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_SCORE)
    ld      a, #0x04
10$:
    push    af
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    sub     b
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
;   ld      a, (hl)
    ld      a, c
    ld      (de), a
    inc     hl
    inc     de
    pop     af
    dec     a
    jr      nz, 10$

    ; レジスタの復帰

    ; 終了
    ret

; 数値を表示する
;
GamePrintNumber:

    ; レジスタの保存

    ; hl < 値
    ; de < 表示位置
    ; c  < 色

    ; 数値の表示
    ld      b, #0x00
    ld      a, h
    rlca
    rlca
    call    10$
    rlca
    rlca
    call    10$
    rlca
    rlca
    call    10$
    rlca
    rlca
    call    10$
    ld      a, l
    rlca
    rlca
    call    10$
    rlca
    rlca
    call    10$
    rlca
    rlca
    call    10$
    rlca
    rlca
    ld      b, c
    call    10$
    jr      19$
10$:
    push    af
    and     #0x03
    jr      z, 11$
    add     a, c
    ld      b, c
    jr      12$
11$:
    ld      a, b
12$:
    ld      (de), a
    inc     de
    pop     af
    ret
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameIdle
    .dw     GameStart
    .dw     GamePlay
    .dw     GameOver
    .dw     GameClear

; ゲームの初期値
;
gameDefault:

    .dw     GAME_PROC_NULL
    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     GAME_COUNT_NULL
    .dw     GAME_SCORE_MAXIMUM ; GAME_SCORE_NULL
    .dw     GAME_DIGIT_NULL

; スコア
;
gameScoreSprite:

    .db     0x58 - 0x01, 0x60, 0xf0, VDP_COLOR_TRANSPARENT
    .db     0x58 - 0x01, 0x70, 0xf4, VDP_COLOR_TRANSPARENT
    .db     0x58 - 0x01, 0x80, 0xf8, VDP_COLOR_TRANSPARENT
    .db     0x58 - 0x01, 0x90, 0xfc, VDP_COLOR_TRANSPARENT
    .db     0x58 - 0x01, 0x60, 0xf0, VDP_COLOR_TRANSPARENT
    .db     0x58 - 0x01, 0x70, 0xf4, VDP_COLOR_TRANSPARENT
    .db     0x58 - 0x01, 0x80, 0xf8, VDP_COLOR_TRANSPARENT

gameScoreColor:

    .db     VDP_COLOR_LIGHT_RED
    .db     VDP_COLOR_LIGHT_GREEN
    .db     VDP_COLOR_LIGHT_BLUE
    .db     VDP_COLOR_LIGHT_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::

    .ds     GAME_LENGTH

; スコア
;
gameScoreCharacter:

    .ds     0x0080

