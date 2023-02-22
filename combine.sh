#!/bin/bash

# 文字色を設定する変数
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 表示するログファイルに関する変数
log_files=($(ls | grep '\.log$'))
num_log_files=${#log_files[@]}
page_size=10
page_num=0

# pm2ログディレクトリに移動
cd ~/.pm2/logs

# logs_combinedというディレクトリが無ければ作成
if [ ! -d "logs_combined" ]; then
    mkdir logs_combined
fi

# show log files
function show_log_files() {
    start=$((page_size * page_num))
    end=$((start + page_size - 1))

    if [[ $end -gt $((num_log_files - 1)) ]]; then
        end=$((num_log_files - 1))
    fi

    echo
    echo "表示したいファイルを選択してください。"
    echo
    echo -e "${YELLOW}--------------------------------------------------------------------------------"
    echo -e "${YELLOW}    lessで表示しますので、終了する時はキーボードの「Q 」を押してください。"
    echo -e "${YELLOW}--------------------------------------------------------------------------------${NC}"
    echo
    for i in $(seq $start $end); do
        echo "$((i + 1))) ${log_files[i]}"
    done
    echo
}

while true; do
    show_log_files
    # 関数呼び出し
    if [[ $page_num -eq $((num_log_files / page_size)) ]]; then
        read -p "これが最終ページです。番号を選択してください (qで終了): " choice
    else
        read -p "次のページを見るには「n 」を押してください (qで終了): " choice
    fi

    if [[ $choice == "q" ]]; then
        break
    elif [[ $choice =~ ^[0-9]+$ ]]; then
        selected_index=$((choice - 1))
        if [[ $selected_index -ge $num_log_files ]]; then
            echo
            echo "不正な番号です"
            echo
        else
            selected_log_file=${log_files[selected_index]}
            echo
            echo -e "${YELLOW}$((selected_index + 1))) $selected_log_file を1つのファイルにまとめます。"
            echo -e "${YELLOW}圧縮ファイルを解凍していますので、しばらくお待ちください。${NC}"
            echo
            break
        fi
    elif [[ $choice == "n" ]]; then
        page_num=$((page_num + 1))
    else
        echo "不正な入力です"
    fi
done

# ここから↑は前半、ここから↓は後半

# .logを外す
selected_file=$(echo $selected_log_file | sed 's/\.log$//')

# logファイルを数字順にソートしてループ
for log in $(ls -v | grep $selected_file); do
    # 拡張子が.gzのlogファイルをunzipする
    if [[ "$log" == *.gz ]]; then
        gunzip -f "$log"
    fi
done

# logファイルを数字順にソートしてループ
for log in $(ls -v | grep $selected_file); do

    # 圧縮されたファイルが作成された日時を取得する
    # `stat`コマンドは、ファイルやディレクトリの情報を取得
    # `-c %y`オプションは、ファイルの最終更新日時を表示するためのフォーマットを指定するオプション
    # `%y`は、以下のような形式で表示
    # YYYY-MM-DD HH:MM:SS
    # $ stat -c %y test.txt
    # 2021-06-08 12:34:56
    # https://atmarkit.itmedia.co.jp/ait/articles/1706/29/news027.html

    # `awk -F '.' '{print $1}'`はstat コマンドによって出力された文字列から . で区切られた左側の部分を取り出します。
    # つまり、小数点以下の情報を除外します。{print $1}は、awkプログラミング言語内での表記です。
    # これは、awkプログラミング言語で、入力テキストの各行を分割してフィールドとして取り扱うことができます。
    # $1は、各行の1番目のフィールドを参照することを意味します。
    # print $1は、各行の1番目のフィールドを出力することを意味する。
    # https://atmarkit.itmedia.co.jp/ait/articles/1706/02/news017.html

    creation_date=$(stat -c %y $log | awk -F '.' '{print $1}')
    # 区切り線を出力
    echo
    echo "--------------------------------------------------------------------------------"
    echo "$creation_date created                $log"
    echo "--------------------------------------------------------------------------------"

    # grepコマンドを使って抽出したテキストを出力
    grep -E 'HTTP status | ERROR | error' "$log"

    # if [[ "$selected_file" = "2-nodeStartPM2-error" ]] || [[ "$selected_file" = "3-initiatorStartPM2-error" ]]; then
    #     grep -E 'HTTP status | ERROR | error' "$log"
    # else
    #     cat "$log"
    # fi
done >"logs_combined/$selected_file-combined.log"

# logs_combinedディレクトリ内の$selected_file-combined.logを開く
less logs_combined/"$selected_file-combined.log"

# 2..10までを圧縮
# ./assyuku.sh
