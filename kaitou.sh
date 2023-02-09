#!/bin/bash

# pm2ログディレクトリに移動
cd ~/.pm2/logs

# combined_logsというディレクトリが無ければ作成
if [ ! -d "combined_logs" ]; then
    mkdir combined_logs
fi

# logファイルを数字順にソートしてループ
for log in $(ls -v 2-nodeStartPM2-error.log*); do
    # 拡張子が.gzのlogファイルをunzipする
    if [[ "$log" == *.gz ]]; then
        gunzip "$log"
    fi
done

# logファイルを数字順にソートしてループ
for log in $(ls -v 2-nodeStartPM2-error.log*); do
    # 区切り線を出力
    echo
    echo "--------------------------------------------------------------------------------"
    echo "                                     $log"
    echo "--------------------------------------------------------------------------------"

    # grepコマンドを使って抽出したテキストを出力
    grep -E 'HTTP status | ERROR | error' "$log"
done >"combined_logs/2-nodeStartPM2-error-combined.log"

cd combined_logs
less 2-nodeStartPM2-error-combined.log

# 2..10までを圧縮
# ./assyuku.sh

# combined_logsディレクトリに移動して2-nodeStartPM2-error-combined.logを開く
cd combined_logs
less 2-nodeStartPM2-error-combined.log

# 2-nodeStartPM2-error.log
# 2-nodeStartPM2-error.log.1
# 2-nodeStartPM2-error.log.2
# 2-nodeStartPM2-error.log.3
# 2-nodeStartPM2-error.log.4
# 2-nodeStartPM2-error.log.5
# 2-nodeStartPM2-error.log.6
# 2-nodeStartPM2-error.log.7
# 2-nodeStartPM2-error.log.8
# 2-nodeStartPM2-error.log.9
# 2-nodeStartPM2-error.log.10