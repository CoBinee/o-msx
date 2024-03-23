; Shot.s : 自弾
;


; モジュール宣言
;
    .module Shot

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Ring.inc"
    .include    "Game.inc"
    .include	"Shot.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 自弾を初期化する
;
_ShotInitialize::
    
    ; レジスタの保存
    
    ; 自弾の初期化
    ld      hl, #(_shot + 0x0000)
    ld      de, #(_shot + 0x0001)
    ld      bc, #(SHOT_LENGTH * SHOT_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; スプライトの初期化
    xor     a
    ld      (shotSpriteRotate), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 自弾を更新する
;
_ShotUpdate::
    
    ; レジスタの保存

    ; 自弾の走査
    ld      ix, #_shot
    ld      b, #SHOT_ENTRY
10$:
    push    bc

    ; 状態の判定
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$

    ; Z の移動
    ld      l, SHOT_POSITION_Z_L(ix)
    ld      h, SHOT_POSITION_Z_H(ix)
    ld      de, #SHOT_SPEED
    add     hl, de
    ld      a, h
    cp      #0xc0
    jr      nc, 18$
    ld      SHOT_POSITION_Z_L(ix), l
    ld      SHOT_POSITION_Z_H(ix), h

    ; 位置の更新
    ld      e, SHOT_POSITION_L_H(ix)
    ld      d, h
    call    _RingGetLZtoXY
    ld      SHOT_POSITION_X(ix), e
    ld      SHOT_POSITION_Y(ix), d

    ; 半径の更新
    ld      a, SHOT_POSITION_Z_H(ix)
    ld      c, a
    ld      b, #SHOT_R_ONE
    call    _RingGetRadius
    ld      SHOT_R(ix), a
    jr      19$

    ; 画面外の判定
18$:
    ld      SHOT_STATE(ix), #SHOT_STATE_NULL
;   jr      19$

    ; 次の自弾へ
19$:
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; 自弾を描画する
;
_ShotRender::

    ; レジスタの保存

    ; 自弾の走査
    ld      ix, #_shot
    ld      a, (shotSpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      b, #SHOT_ENTRY
10$:
    push    bc

    ; 描画の確認
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$

    ; スプライトの描画
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
    add     hl, de
    ex      de, hl
    ld      l, SHOT_POSITION_X(ix)
    ld      h, SHOT_POSITION_Y(ix)
    ld      b, SHOT_R(ix)
    ld      c, #SHOT_COLOR
    call    _RingPrintOne
    pop     de

    ; スプライトのローテート
    ld      a, e
    add     a, #0x04
    and     #(SHOT_ENTRY * 0x04 - 0x01)
    ld      e, a

    ; 次の自弾へ
19$:
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      a, (shotSpriteRotate)
    add     a, #0x04
    and     #(SHOT_ENTRY * 0x04 - 0x01)
    ld      (shotSpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; 自弾を撃つ
;
_ShotFire::

    ; レジスタの保存

    ; de < Z/L 位置

    ; 自弾の検索
    ld      ix, #_shot
    ld      b, #SHOT_ENTRY
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      19$

    ; 自弾の設定
11$:
    inc     SHOT_STATE(ix)
    ld      SHOT_FLAG(ix), #SHOT_FLAG_HIT ; SHOT_FLAG_NULL
    xor     a
    ld      SHOT_POSITION_L_L(ix), a
    ld      SHOT_POSITION_L_H(ix), e
    ld      SHOT_POSITION_Z_L(ix), a
    ld      SHOT_POSITION_Z_H(ix), d
    ld      SHOT_R(ix), a

    ; SE の再生
    ld      a, #SOUND_SE_SHOT
    call    _SoundPlaySe
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 自弾にヒットする
;
_ShotHit::

    ; レジスタの保存

    ; iy < 自弾

    ; 自弾の削除
    ld      SHOT_STATE(iy), #SHOT_STATE_NULL

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 自弾
;
_shot::
    
    .ds     SHOT_LENGTH * SHOT_ENTRY

; スプライト
;
shotSpriteRotate:

    .ds     0x01
