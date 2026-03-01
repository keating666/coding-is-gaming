# Coding is Gaming 🎮

> [peon-ping](https://github.com/peon-ping/peon-ping) 用ボイスパック — Claude Code のセッションをRTSの戦場に変える。

Claudeが考えるとき、タスクを完了するとき、入力を求めるとき、エラーが起きるとき——ランダムにレッドアラート・ウォークラフト・スタークラフト・Portalのボイスが流れる。**470サウンド・7イベント・飽きない多様性。**

---

## 聴こえてくる声

| イベント | トリガー | サウンド例 |
|---------|---------|-----------|
| `session.start` | 新しい Claude Code セッション開始 | *「Battle Control Online」*、*「キーロフ、報告します」*、農民 *「いつでも準備OK」* |
| `task.acknowledge` | Claude がタスク処理開始 | Borisの移動命令、Tanyaの攻撃応答、Peon の *「Work work」* |
| `task.complete` | タスク完了 | *「建設完了」*、*「ユニット昇格」*、GLaDOS *「おめでとうございます」* |
| `task.error` | エラー / 失敗 | *「ユニット消滅」*、*「戦場管制終了」*、Tanyaの戦死ボイス |
| `input.required` | Claude が入力待ち | *「受信中」*、各キャラクターの選択応答ボイス |
| `resource.limit` | コンテキスト / リソース上限 | *「資金不足」*、*「電力低下」*、GLaDOS *「私はジャガイモです」* |
| `user.spam` | メッセージを送りすぎたとき | *「警告：核ミサイル発射」*、*「All your base are belong to us」*、Tanya *「Yeah baby」* |

## サウンドの出典

| ゲーム | キャラクター / EVA |
|-------|------------------|
| **レッドアラート 2** | EVA（連合軍・ソビエト）、Tanya、Boris、Yuri、Yuri Prime、キーロフ、ネイビーシール |
| **レッドアラート 3** | EVA（連合軍・ソビエト・帝国軍）、Tanya、Natasha |
| **C&C 4** | EVA（GDI・Nod）|
| **C&C ジェネラルズ** | EVA、クラシック音声 |
| **ウォークラフト III** | オークのPeon、人間の農民 |
| **スタークラフト** | Sarah Kerrigan、バトルクルーザー |
| **Portal** | GLaDOS |

---

## 必要条件

1. **[peon-ping](https://github.com/peon-ping/peon-ping)** をインストール済み
2. 標準パックのインストール：
   ```bash
   peon packs install peon,peasant,glados,sc_battlecruiser,sc_kerrigan
   ```
3. 正規ゲームから抽出した**レッドアラートの音声ファイル**（下記参照）

---

## 音声ファイルの入手方法

音声ファイルは著作権保護されたゲームアセットのため、**本リポジトリには含まれていません**。

正規所有のゲームから自分で抽出してください：

- **レッドアラート 2 / ユーリの復讐**：[XCC Mixer](https://xhp.xwis.net/utilities.php) で `ra2.mix` / `ra2md.mix` を解凍
- **レッドアラート 3**：[FinalBIG](https://modenc.renegadeprojects.com/FinalBIG) などで `.big` アーカイブを解凍
- **C&C4 / ジェネラルズ**：同様に `.big` アーカイブを解凍

フォルダ構成は以下の通り：
```
red-alert-sounds/
├── RA2/
│   ├── ra2 ally/          ← 連合軍EVAボイス
│   ├── ra2 soviet/        ← ソビエトEVAボイス
│   └── unit/              ← ユニットボイス
├── RA3/
│   ├── ally/              ← Aeva_*.wav
│   ├── soviet/            ← Seva_*.wav
│   └── ers/               ← Ieva_*.wav
├── CC4/                   ← Geva_*.wav, Neva_*.wav
├── CCG/
│   ├── speech/
│   └── audio/
├── boris/                 ← ibor*.wav
├── tanya-ra2/             ← itan*.wav, itap*.wav
├── tanya-ra3/             ← AUTanya_*.wav
├── natasha/               ← SUNatas_*.wav
└── yuri/                  ← iyup*.wav, iyur*.wav
```

---

## インストール方法

```bash
git clone https://github.com/keating666/coding-is-gaming
cd coding-is-gaming
./install.sh /path/to/red-alert-sounds
```

スクリプトが自動的に：
- すべての音声ファイルをコピー・リネーム
- 既存のpeon-pingパックからWarcraft/StarCraft/GLaDOSボイスを流用
- パックを自動的にアクティブ化

動作確認：
```bash
peon preview --list
peon preview session.start
```

---

## 仕組み

7つのpeon-pingイベントそれぞれにサウンドプールが割り当てられています。トリガーのたびにプールからランダムに1つを選択（同じ音声が連続して再生されることはありません）。

マッピングはゲームのセマンティクスに従っています：
- **選択応答**（`se*`・`VoiSel*`）→ `input.required`：ユニットが呼ばれ、命令待ち
- **移動/攻撃応答**（`mo*`・`at*`・`VoiMov*`・`VoiAtk*`）→ `task.acknowledge`：命令を実行中
- **生成/準備完了**（`cr*`・`rea*`・`VoiCre*`）→ `session.start`：ユニットが登場
- **死亡/恐怖応答**（`VoiDie*`・`VoiFear*`・`fe*`）→ `task.error`：何かが壊れた
- **うんざり台詞**（`dia*`）→ `user.spam`：もう限界

---

## ライセンス

本プロジェクト（インストーラースクリプトとopenpeon.json）はMITライセンスです。

音声ファイルの著作権は各権利者（EA Games・Blizzard Entertainment・Valve）に帰属します。正規ゲームを所有している場合のみご利用ください。

---

*「コードを書くことと軍隊を指揮することは、まったく同じ感覚だ」という気づきから生まれました。*
