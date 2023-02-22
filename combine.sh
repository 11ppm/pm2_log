#!/bin/bash

# 文字色を設定する変数
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 表示するログファイルに関する変数
log_files=($(ls $HOME/.pm2/logs/ | grep '\.log$'))
num_log_files=${#log_files[@]}
page_size=10
page_num=0
LOGS_COMBINED=$HOME/.pm2/logs/logs_combined

# pm2ログディレクトリに移動
cd ~/.pm2/logs

# logs_combinedというディレクトリが無ければ作成
if [ ! -d "$LOGS_COMBINED" ]; then
    mkdir $LOGS_COMBINED
fi

# 関数show_log_files
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

# logファイルを数字順にソートしてループ_1
for log in $(ls -v | grep $selected_file); do
    # 拡張子が.gzのlogファイルをunzipする
    if [[ "$log" == *.gz ]]; then
        gunzip -f "$log"
    fi
done

# logファイルを数字順にソートしてループ_2
for log in $(ls -v | grep $selected_file); do

    creation_date=$(stat -c %y $log | awk -F '.' '{print $1}')
    # 区切り線を出力
    echo
    echo "--------------------------------------------------------------------------------"
    echo "$creation_date created                $log"
    echo "--------------------------------------------------------------------------------"

    # grepコマンドを使って抽出したテキストを出力
    # grep -E 'HTTP status | ERROR | error' "$log"

    if [[ "$selected_file" = "2-nodeStartPM2-error" ]] || [[ "$selected_file" = "3-initiatorStartPM2-error" ]]; then
        grep -E 'HTTP status | ERROR | error' "$log"
    else
        cat "$log"
    fi
done >"$LOGS_COMBINED/$selected_file-combined.log"

# logs_combinedディレクトリ内の$selected_file-combined.logを開く
less $LOGS_COMBINED/"$selected_file-combined.log"
