# Coding is Gaming 🎮

> 一款 [peon-ping](https://github.com/peon-ping/peon-ping) 语音包，让你的 Claude Code 会话变成一场 RTS 即时战略游戏。

每当 Claude 思考、完成任务、等待你回答或遭遇错误，你就会听到一段来自红色警戒、魔兽争霸、星际争霸或 Portal 的随机语音。**470 个声音、7 种事件、永不重复。**

---

## 你会听到什么

| 事件 | 触发时机 | 示例声音 |
|------|---------|---------|
| `session.start` | 新建 Claude Code 会话 | *"Battle Control Online"*、*"基洛夫号，报到"*、农民 *"随时待命"* |
| `task.acknowledge` | Claude 开始处理任务 | Boris 移动指令、Tanya 攻击回应、苦工 *"Work work"* |
| `task.complete` | 任务完成 | *"建造完成"*、*"单位晋升"*、GLaDOS *"恭喜恭喜"* |
| `task.error` | 报错 / 失败 | *"单位损失"*、*"战场控制中断"*、Tanya 阵亡语音 |
| `input.required` | Claude 需要你的输入 | *"来电传输"*、所有角色的被选中语音 |
| `resource.limit` | 上下文 / 资源限制 | *"资金不足"*、*"电力不足"*、GLaDOS *"我是个土豆"* |
| `user.spam` | 你发消息太频繁 | *"警告：核弹已发射"*、*"All your base are belong to us"*、Tanya *"Yeah baby"* |

## 声音来源

| 游戏 | 角色 / EVA |
|------|-----------|
| **红色警戒 2** | EVA（盟军 + 苏联）、Tanya、Boris、Yuri、Yuri Prime、基洛夫、海豹突击队 |
| **红色警戒 3** | EVA（盟军/苏联/帝国）、Tanya、Natasha |
| **命令与征服 4** | EVA（GDI + Nod）|
| **命令与征服：将军** | EVA、经典语音片段 |
| **魔兽争霸 III** | 兽族苦工、人族农民 |
| **星际争霸** | Sarah Kerrigan、战列巡洋舰 |
| **Portal** | GLaDOS |

---

## 前置条件

1. 安装 **[peon-ping](https://github.com/peon-ping/peon-ping)**
2. 安装以下标准语音包：
   ```bash
   peon packs install peon,peasant,glados,sc_battlecruiser,sc_kerrigan
   ```
3. 准备好你拥有正版游戏的**红色警戒音频文件**（见下方说明）

---

## 获取音频文件

音频文件**不包含在本 repo 中**——它们是各游戏的版权资产。

请从你拥有的正版游戏中自行提取：

- **红色警戒 2 / 尤里的复仇**：用 [XCC Mixer](https://xhp.xwis.net/utilities.php) 解压 `ra2.mix` / `ra2md.mix`
- **红色警戒 3**：用 [FinalBIG](https://modenc.renegadeprojects.com/FinalBIG) 等工具解压游戏 `.big` 档案
- **命令与征服 4 / 将军**：方法类似，解压 `.big` 档案

你的红色警戒音频文件夹应具有以下结构：
```
red-alert-sounds/
├── RA2/
│   ├── ra2 ally/          ← 盟军 EVA 语音
│   ├── ra2 soviet/        ← 苏联 EVA 语音
│   └── unit/              ← 单位语音片段
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

## 安装方法

```bash
git clone https://github.com/keating666/coding-is-gaming
cd coding-is-gaming
./install.sh /path/to/red-alert-sounds
```

脚本会自动完成：
- 复制并重命名所有音频文件
- 从已安装的 peon-ping 包中借用魔兽 / 星际 / GLaDOS 语音
- 自动激活本语音包

验证是否正常运行：
```bash
peon preview --list
peon preview session.start
```

---

## 工作原理

7 个 peon-ping 事件各自对应一个声音池。每次触发时，引擎从池中随机抽取一个（同一声音不会连续播放两次）。

映射逻辑遵循游戏语义：
- **被选中回应**（`se*`、`VoiSel*`）→ `input.required`：单位被呼唤，等待命令
- **移动/攻击回应**（`mo*`、`at*`、`VoiMov*`、`VoiAtk*`）→ `task.acknowledge`：单位正在执行命令
- **创建/就绪回应**（`cr*`、`rea*`、`VoiCre*`）→ `session.start`：单位刚刚生成
- **死亡/恐惧回应**（`VoiDie*`、`VoiFear*`、`fe*`）→ `task.error`：出了问题
- **被惹烦的对话**（`dia*`）→ `user.spam`：单位受够了

---

## 版权声明

本项目（安装脚本与 openpeon.json 配置文件）采用 MIT 许可证。

音频文件的版权归各自版权方所有（艺电 EA、暴雪娱乐、Valve）。请仅在拥有原版游戏的前提下使用。

---

*灵感来自一个朴素的观察：写代码和指挥军队，感觉完全一样。*
