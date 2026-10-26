# Coding is Gaming 🎮

**[中文](README_CN.md) | 日本語 | [English](README.md)**

> [peon-ping](https://github.com/peon-ping/peon-ping) 用ボイスパック：レッドアラートとウォークラフトのボイスで Claude Code の 7 イベントを鳴らす。

バージョン 2 は厳選版。初版は 470 クリップを詰め込んだが、今回は 38 本だけ：どれも 3 秒以内、聞き分けやすく、イベントの意味に合わせて分類。イベントごとに 1 フォルダ、発火ごとにランダムで 1 本。

---

## 聴こえてくる声

| イベント | タイミング | ボイス例 |
|---------|-----------|---------|
| `session.start` | 新しい Claude Code ウィンドウ | Battle control online · Kirov reporting · Natasha here · Peon「Ready to work?」 |
| `task.acknowledge` | メッセージ送信ごと | Work work · Okie dokie · Roger that · Tanya「Move it out!」 |
| `task.complete` | Claude の応答完了 | Construction complete · Unit ready · Unit promoted |
| `task.error` | シェルコマンド失敗 | Unit lost · Tanya「Must resist」 |
| `input.required` | 承認や回答待ち | Peon「What you want?」·「More work!」· Tanya「You got a target?」 |
| `resource.limit` | コンテキスト圧縮の直前 | Insufficient funds · Low power |
| `user.spam` | 10 秒以内に 3 回送信 | 核ミサイル警告 · Tanya の笑い声 |

出典：レッドアラート 2 の EVA（連合軍・ソビエト）、レッドアラート 2/3 の Tanya、レッドアラート 3 の Natasha、キーロフ、ウォークラフト III の Peon と農民。

---

## 構成

```
coding-is-gaming/
├── openpeon.json   ← peon-ping が読むマニフェスト（生成物、手で編集しない）
├── sources.tsv     ← イベント ⇥ サウンドフォルダ内の元ファイル ⇥ インストール後の名前
├── install.sh      ← コピー、マニフェスト設置、パック有効化
├── rebuild.sh      ← sounds/ 各フォルダの実ファイルから openpeon.json を再生成
└── test.sh         ← ユニット + 統合 + E2E テスト
```

インストール後のパックは `~/.openpeon/packs/coding-is-gaming/sounds/` 以下に 7 つのイベントフォルダ。

音声ファイルはリポジトリに**含まれない**（ゲームの著作物）。必要なファイルと出所は `sources.tsv` に記載。

---

## インストール

1. [peon-ping](https://github.com/peon-ping/peon-ping) を導入。
2. ゲームから抽出した音声を 1 つのフォルダにまとめる（`RA2/ra2 ally/`、`RA2/ra2 soviet/`、その他は直下。ファイル名は `sources.tsv` 参照）。
3. 実行：

   ```bash
   git clone https://github.com/keating666/coding-is-gaming
   cd coding-is-gaming
   ./install.sh ~/path/to/sound
   ```

   足りないファイルは警告のみ。マニフェストは実際にコピーできたものから生成される。

   すでにパック構成（7 つのイベントフォルダ、例えばインストール済みパックのバックアップ）のフォルダを渡すと、`sources.tsv` を見ずにそのままコピーする。

4. 確認：`peon preview --list` / `peon preview task.complete`

---

## カスタマイズ

パックは 7 つのフォルダそのもの。ファイルを入れる・出す・名前を変える（ファイル名が peon-ping の表示ラベル）、その後：

```bash
~/.openpeon/packs/coding-is-gaming/rebuild.sh
```

再起動不要、次の発火から反映。リポジトリ側の厳選セットを変えるなら `sources.tsv` を編集して `./rebuild.sh --tsv`、続けて `./test.sh`。

---

## ライセンス

スクリプトとマニフェスト：MIT。音声ファイルの著作権は EA・Blizzard に帰属。原作ゲームを所有している場合のみ使用可。
