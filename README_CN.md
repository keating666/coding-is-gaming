# Coding is Gaming 🎮

**中文 | [日本語](README_JP.md) | [English](README.md)**

> 一款 [peon-ping](https://github.com/peon-ping/peon-ping) 语音包：用红警和魔兽的语音，给 Claude Code 的 7 种事件配音。

第二版是精选版。第一版一股脑塞了 470 条，这版只留 38 条：每条 3 秒以内、一听就分得清、按事件含义归类。一个事件一个文件夹，触发时从里面随机抽一条。

---

## 你会听到什么

| 事件 | 什么时候响 | 台词举例 |
|------|-----------|---------|
| `session.start` 开工 | 新开一个 Claude Code 窗口 | Battle control online · 基洛夫报到 · 娜塔莎报到 · 苦工 "Ready to work?" |
| `task.acknowledge` 收到指令 | 你每发一条消息 | Work work · Okie dokie · Roger that · 谭雅 "Move it out!" |
| `task.complete` 完成 | Claude 一轮回答结束 | Construction complete · Unit ready · Unit promoted |
| `task.error` 出错 | 终端命令失败 | Unit lost · 谭雅 "Must resist" |
| `input.required` 等你操作 | 要你批准或回答 | 苦工 "What you want?" · "More work!" · 谭雅 "You got a target?" |
| `resource.limit` 要压缩 | 对话太长，上下文即将压缩 | Insufficient funds · Low power |
| `user.spam` 连发 | 10 秒内连发 3 条 | 核弹警告 · 谭雅大笑 |

来源：红警 2 盟军与苏军 EVA 播音、红警 2/3 谭雅、红警 3 娜塔莎、基洛夫飞艇、魔兽争霸 III 苦工与农民。

---

## 文件结构

```
coding-is-gaming/
├── openpeon.json   ← peon-ping 读的清单（脚本生成，不要手改）
├── sources.tsv     ← 事件 ⇥ 你音频文件夹里的源文件 ⇥ 装进去后的文件名
├── install.sh      ← 拷音频、装清单、激活语音包
├── rebuild.sh      ← 按 sounds/ 各文件夹实际内容重新生成 openpeon.json
└── test.sh         ← 单元 + 集成 + 端到端测试
```

装好后的语音包：

```
~/.openpeon/packs/coding-is-gaming/sounds/
├── session.start/
├── task.acknowledge/
├── task.complete/
├── task.error/
├── input.required/
├── resource.limit/
└── user.spam/
```

仓库里**不含音频文件**，它们是游戏版权素材。`sources.tsv` 写明了需要哪些文件、从哪来。

---

## 安装

1. 先装好 [peon-ping](https://github.com/peon-ping/peon-ping)。
2. 把你从游戏里提取的音频放进一个文件夹，结构如下（文件名以 `sources.tsv` 为准）：

   ```
   sound/
   ├── RA2/ra2 ally/      battle control online.wav、construction complete.wav 等
   ├── RA2/ra2 soviet/    同样 19 句，苏军播音员
   ├── PeonYes1.wav … PeonWhat4.wav、ready to work.wav、more work.wav   （魔兽 III）
   ├── AUTanya_*.wav、SUNatas_*.wav                                   （红警 3）
   ├── itan*.wav、itap*.wav、tanya-hahahahahaha.wav、kirov-kirov reporting.wav（红警 2）
   └── RogerThat.mp3、RightAwaySir.mp3
   ```

3. 跑安装脚本：

   ```bash
   git clone https://github.com/keating666/coding-is-gaming
   cd coding-is-gaming
   ./install.sh ~/你的/sound
   ```

   缺文件只会提示，不会中断：清单会按实际拷进去的文件生成。

4. 验证：

   ```bash
   peon preview --list
   peon preview task.complete
   ```

---

## 自定义

语音包就是七个文件夹。往里拖文件、删文件、改名（文件名就是 peon-ping 显示的标签），然后跑：

```bash
~/.openpeon/packs/coding-is-gaming/rebuild.sh
```

不用重启，下一声就生效。

想改仓库里的精选集，改 `sources.tsv` 后跑 `./rebuild.sh --tsv`，再跑 `./test.sh`。

---

## 测试

```bash
./test.sh
```

单元测试检查 `sources.tsv` 与 `openpeon.json`；集成测试用合成音频装进临时目录；端到端测试在有真实音频文件夹时运行（`SOUND_SRC`，默认 `~/Downloads/sound`）：每个装入的文件必须能解码，`rebuild.sh` 必须能还原出仓库里的清单。

---

## 许可

安装脚本、清单与脚本：MIT。音频文件版权归 EA、暴雪所有，仅限拥有原版游戏的玩家自用。
