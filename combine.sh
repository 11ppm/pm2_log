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
    # 区切り線を出力
    echo
    echo "--------------------------------------------------------------------------------"
    echo "                                     $log"
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

# # 2..10までを圧縮
# # ./assyuku.sh

# # # selected_log_file=3-initiatorStartPM2-error.log
# # selected_file=$(echo $selected_log_file | sed 's/\.log$//')
# # echo $selected_file
# # # ls -v $selected_file # 拡張子がないために表示できない
# # ls -v | grep $selected_file
# # for log in $(ls -v | grep $selected_file); do
# #     echo $log
# # done
# # echo "combined_logs/$selected_file-combined.log"
# # less combined_logs/"$selected_file-combined.log"
