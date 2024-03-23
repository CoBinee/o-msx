// 参照ファイルのインクルード
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>



// メインプログラムのエントリ
//
int main(int argc, const char *argv[])
{
    // 出力ファイル名の初期化
    const char *outname = NULL;
    
    // 名前の初期化
    const char *name = NULL;
    
    // 半径の初期化
    int r = 88;

    // 長さの初期化
    int length = 256;

    // 奥行きの初期化
    int depth = 256;

    int scale = 16;

    // 引数の取得
    while (--argc > 0) {
        ++argv;
        if (strcasecmp(*argv, "-r") == 0) {
            r = atoi(*++argv);
            --argc;
        } else if (strcasecmp(*argv, "-l") == 0) {
            length = atoi(*++argv);
            --argc;
        } else if (strcasecmp(*argv, "-d") == 0) {
            depth = atoi(*++argv);
            --argc;
        } else if (strcasecmp(*argv, "-s") == 0) {
            scale = atoi(*++argv);
            --argc;
        } else if (strcasecmp(*argv, "-o") == 0) {
            outname = *++argv;
            --argc;
        } else if (strcasecmp(*argv, "-n") == 0) {
            name = *++argv;
            --argc;
        }
    }

    // 出力ファイルを開く
    FILE *outfile = outname != NULL ? fopen(outname, "w") : stdout;
    
    // ヘッダの出力
    fprintf(outfile, "; %s\n;\n\n", outname != NULL ? outname : name);
    
    // ラベルの出力
    if (name != NULL) {
        fprintf(outfile, "    .module %s\n", name);
        fprintf(outfile, "    .area   _CODE\n\n");
    }
    
    // 位置テーブルの出力
    fprintf(outfile, "_%sPosition::\n\n", name);
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < length / 4; j++) {
            if ((j % 8) == 0) {
                fprintf(outfile, "    .db     ");
            }
            double theta = 2.0 * M_PI * (double)j / (double)length;
            unsigned char x = (unsigned char)((double)(i + 1) * sin(theta));
            unsigned char y = (unsigned char)((double)(i + 1) * cos(theta));
            fprintf(outfile, "0x%02x, 0x%02x", x, y);
            if ((j % 8) < 7) {
                fprintf(outfile, ", ");
            } else {
                fprintf(outfile, "\n");
            }
        }
    }
    fprintf(outfile, "\n");

    // 奥行きテーブルの出力
    fprintf(outfile, "_%sDepth::\n\n", name);
    for (int i = 0; i < depth; i++) {
        if ((i % 8) == 0) {
            fprintf(outfile, "    .db     ");
        }
        double z = (double)r / (((double)i / depth) * 4.0 + 1.0);
        fprintf(outfile, "0x%02x", (unsigned char)z);
        if ((i % 8) < 7) {
            fprintf(outfile, ", ");
        } else {
            fprintf(outfile, "\n");
        }
    }
    fprintf(outfile, "\n");

    // スケールテーブルの出力
    fprintf(outfile, "_%sScale::\n\n", name);
    for (int i = 0; i < depth; i++) {
        if ((i % 8) == 0) {
            fprintf(outfile, "    .db     ");
        }
        double s = (double)scale / (((double)i / depth) * 4.0 + 1.0);
        fprintf(outfile, "0x%02x", (unsigned char)s);
        if ((i % 8) < 7) {
            fprintf(outfile, ", ");
        } else {
            fprintf(outfile, "\n");
        }
    }
    fprintf(outfile, "\n");

    // ベクタテーブルの出力
    fprintf(outfile, "_%sVector::\n\n", name);
    for (int i = 0; i < length; i++) {
        if ((i % 8) == 0) {
            fprintf(outfile, "    .db     ");
        }
        double theta = 2.0 * M_PI * (double)i / (double)length;
        unsigned char x = (unsigned char)(-0x7f * sin(theta));
        unsigned char y = (unsigned char)(-0x7f * cos(theta));
        fprintf(outfile, "0x%02x, 0x%02x", x, y);
        if ((i % 8) < 7) {
            fprintf(outfile, ", ");
        } else {
            fprintf(outfile, "\n");
        }
    }
    fprintf(outfile, "\n");

    // 出力ファイルを閉じる
    if (outfile != stdout) {
        fclose(outfile);
    }
    
    // 終了
    return 0;
}


