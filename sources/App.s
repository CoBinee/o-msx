; App.s : アプリケーション
;


; モジュール宣言
;
    .module App

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Ring.inc"
    .include    "Game.inc"

; 外部変数宣言
;
    .globl  _patternTable
    

; CODE 領域
;
    .area   _CODE

; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    
    ; 画面表示の停止
    call    DISSCR
    
    ; ビデオの設定
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; 割り込みの禁止
    di
    
    ; VDP ポートの取得
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; スプライトジェネレータの転送
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_patternTable + 0x0000)
    ld      d, #0x08
10$:
    ld      e, #0x10
11$:
    push    de
    ld      b, #0x08
    otir
    ld      de, #0x78
    add     hl, de
    ld      b, #0x08
    otir
    ld      de, #0x80
    or      a
    sbc     hl, de
    pop     de
    dec     e
    jr      nz, 11$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 10$
    
    ; パターンジェネレータの転送
    ld      hl, #(_patternTable + 0x0800)
    ld      de, #APP_PATTERN_GENERATOR_TABLE
    ld      bc, #0x1000
    call    LDIRVM
    
    ; カラーテーブルの初期化
    ld      hl, #appColorRing
    ld      de, #APP_COLOR_TABLE
    ld      b, #0x04
20$:
    push    bc
    push    hl
    push    de
    ld      a, (hl)
    ld      hl, #appColorTable
    ld      de, #appColorWork
    ld      bc, #0x0100
    ldir
    pop     de
    ld      hl, #appColorWork
    ld      c, a
    ld      b, #0x00
21$:
    ld      a, (hl)
    or      a
    jr      nz, 22$
    ld      (hl), c
22$:
    inc     hl
    djnz    21$
    ld      hl, #appColorWork
    ld      b, #0x08
23$:
    push    bc
    push    hl
    push    de
    ld      bc, #0x0020
    call    LDIRVM
    pop     hl
    ld      bc, #0x0040
    add     hl, bc
    ex      de, hl
    pop     hl
    ld      bc, #0x0020
    add     hl, bc
    pop     bc
    djnz    23$
    pop     hl
    inc     hl
    pop     bc
    djnz    20$
    
    ; パターンネームの初期化
    ld      hl, #APP_PATTERN_NAME_TABLE
    xor     a
    ld      bc, #0x0300
    call    FILVRM
    
    ; 割り込み禁止の解除
    ei

    ; アプリケーションの初期化
    ld      hl, #appDefault
    ld      de, #_app
    ld      bc, #APP_LENGTH
    ldir
    
    ; 状態の初期化
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_app + APP_STATE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #appProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; 乱数を混ぜる
    call    _SystemGetRandom

;   ; デバッグ表示
;   call    AppPrintDebug

    ; 更新の終了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 処理なし
;
_AppNull::

    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; スコアを更新する
; 
_AppUpdateScore::

    ; レジスタの保存

    ; hl < スコア
    ; cf > 1 = 更新した

    ; スコアの更新
    ld      de, (_app + APP_SCORE_L)
    or      a
    sbc     hl, de
    jr      c, 18$
    jr      z, 18$
    add     hl, de
    ld      (_app + APP_SCORE_L), hl
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; デバッグ情報を表示する
;
AppPrintDebug:

    ; レジスタの保存

    ; デバッグ数値の表示
    ld      de, #(_patternName + 0x02e0)
    ld      hl, #appDebugStringNumber
    call    70$
    ld      hl, #_debug
    ld      b, #DEBUG_SIZE
10$:
    ld      a, (hl)
    call    80$
    inc     hl
    djnz    10$
    jr      90$

    ; 文字列の表示
70$:
    ld      a, (hl)
    sub     #0x20
    ret     c
    ld      (de), a
    inc     hl
    inc     de
    jr      70$

    ; 16 進数の表示
80$:
    push    af
    rrca
    rrca
    rrca
    rrca
    call    81$
    pop     af
    call    81$
    ret
81$:
    and     #0x0f
    cp      #0x0a
    jr      c, 82$
    add     a, #0x07
82$:
    add     a, #0x10
    ld      (de), a
    inc     de
    ret

    ; デバッグ表示の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; VDP レジスタ値（スクリーン１）
;
videoScreen1:

    .db     0b00000000
    .db     0b10100010
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000000 ; 0b00000111

; カラーテーブル
;
appColorTable:

    ; 0
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    ; 1
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    ; 2
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    ; 3
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    ; 4
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    ; 5
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    ; 6
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_GREEN << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT
    .db     (VDP_COLOR_TRANSPARENT  << 4) | VDP_COLOR_TRANSPARENT, (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_BLACK        << 4) | VDP_COLOR_BLACK
    ; 0
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK

appColorRing:

    .db     (VDP_COLOR_DARK_RED    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_GREEN  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_BLUE   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW << 4) | VDP_COLOR_BLACK

; 状態別の処理
;
appProc:
    
    .dw     _AppNull
    .dw     _GameInitialize
    .dw     _GameUpdate

; アプリケーションの初期値
;
appDefault:

    .db     APP_STATE_NULL
    .db     APP_FRAME_NULL
    .dw     0x0003 ; APP_SCORE_NULL

; デバッグ
;
appDebugStringNumber:

    .ascii  "DBG="
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; アプリケーション
;
_app::

    .ds     APP_LENGTH

; カラーテーブル
;
appColorWork:

    .ds     0x0100
