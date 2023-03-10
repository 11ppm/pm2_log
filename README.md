<br/>
<p align="center">
<img src="./img/img2.jpg" width="225" alt="PluginJapan">
</a>
</p>
<br/>

# pm2_log
このスクリプトは、特定のディレクトリ内のログファイルを結合して、1つのファイルにまとめて表示することができます。

以下は、スクリプトの使用方法の詳細です。

## 機能
PluginNodeのプロセスのログファイルを結合して、1つのファイルにまとめて表示します。

## 要件
* PluginNodeを維持管理している人が対象です
* ログファイルは`~/.pm2/logs/`ディレクトリにあり、拡張子が `.log` で終わっている必要があります
* 結合するログファイルのエンコーディングがUTF-8である必要があります

## 注意事項
* githubからクローンし、`pm2_log`ディレクトリでスクリプトを実行してください
* `combine.sh`に実行権限を与えて、実行します
* 結合するログファイルの選択すると、1つに結合したログファイルは `~/.pm2/logs/logs_combined` ディレクトリに保存されます。
* lessコマンドで表示されるログファイルは非常に大きい場合があるため、完全に読み込むまでに時間がかかることがあります。`less`がインストールされていない場合は、以下のコマンドでインストールしてください。
```
sudo apt install less
```

## 実行コマンド
1. スクリプトを実行するために、ターミナルを開き、任意のディレクトリに移動します。
   
2. リポジトリをgithubからクローンします
```
git clone https://github.com/11ppm/pm2_log.git
```

3. pm2_logディレクトリに移動します
```
cd pm2_log
```

4. combine.shファイルに実行権限を与えます
```
chmod +x combine.sh
```

5.combine.shを実行します
```
./combine.sh
```

6. まとめたいログファイルを選択します。


7. しばらく待つと`less`コマンドで表示されます。これで、`pm2_log` ディレクトリで選択したログファイルが `.pm2/logs/logs_combined`ディレクトリの中にひとつにまとめられて作成されます。

8. less表示をやめる時には、キーボードの「Q 」を押してください。スペースキーを押すと、下の方まで見ることができます。


## Author

* @11ppm



