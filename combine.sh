#!/bin/bash

log_files=($(ls | grep '\.log$'))
num_log_files=${#log_files[@]}
page_size=10
page_num=0

# pm2ログディレクトリに移動
cd ~/.pm2/logs

# combined_logsというディレクトリが無ければ作成
if [ ! -d "combined_logs" ]; then
    mkdir combined_logs
fi

# show log files
function show_log_files() {
    start=$((page_size * page_num))
    end=$((start + page_size - 1))

    if [[ $end -gt $((num_log_files - 1)) ]]; then
        end=$((num_log_files - 1))
    fi

    echo "表示したいファイルを選択してください。"
    echo
    for i in $(seq $start $end); do
        echo "$((i + 1)). ${log_files[i]}"
    done
    echo
}

while true; do
    show_log_files

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
            echo "$((selected_index + 1)). $selected_log_file をまとめて表示します。よろしいですか？"
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
        gunzip -v "$log"
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
done >"combined_logs/$selected_file-combined.log"

# combined_logsディレクトリ内の$selected_file-combined.logを開く
less combined_logs/"$selected_file-combined.log"

# 2..10までを圧縮
# ./assyuku.sh

# # selected_log_file=3-initiatorStartPM2-error.log
# selected_file=$(echo $selected_log_file | sed 's/\.log$//')
# echo $selected_file
# # ls -v $selected_file # 拡張子がないために表示できない
# ls -v | grep $selected_file
# for log in $(ls -v | grep $selected_file); do
#     echo $log
# done
# echo "combined_logs/$selected_file-combined.log"
# less combined_logs/"$selected_file-combined.log"
