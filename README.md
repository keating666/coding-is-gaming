# Coding is Gaming 🎮

> A [peon-ping](https://github.com/peon-ping/peon-ping) voice pack that turns your Claude Code session into an RTS battlefield.

Every time Claude thinks, finishes, asks a question, or hits an error — you hear a random voice from Red Alert, Warcraft III, StarCraft, or Portal. **470 sounds, 7 events, zero repetition boredom.**

---

## What you'll hear

| Event | What triggers it | Example sounds |
|-------|-----------------|----------------|
| `session.start` | New Claude Code session | *"Battle Control Online"*, *"Kirov reporting"*, Peon *"Ready to work?"* |
| `task.acknowledge` | Claude starts working | Boris move orders, Tanya attack responses, Peon *"Work work"* |
| `task.complete` | Task finished | *"Construction complete"*, *"Unit promoted"*, GLaDOS *"Congratulations"* |
| `task.error` | Error / failure | *"Unit lost"*, *"Battle Control Terminated"*, Tanya death cries |
| `input.required` | Claude needs your input | *"Incoming transmission"*, all characters' select responses |
| `resource.limit` | Context / resource limit | *"Insufficient funds"*, *"Low power"*, GLaDOS *"I'm a potato"* |
| `user.spam` | You message too fast | *"Warning: nuclear missile launched"*, *"All your base are belong to us"*, Tanya *"Yeah baby"* |

## Sound sources

| Game | Characters / EVA |
|------|-----------------|
| **Red Alert 2** | EVA (Ally + Soviet), Tanya, Boris, Yuri, Yuri Prime, Kirov, Navy SEAL |
| **Red Alert 3** | EVA (Ally/Soviet/ERS), Tanya, Natasha |
| **Command & Conquer 4** | EVA (GDI + Nod) |
| **C&C Generals** | EVA, *"All your base"*, classic clips |
| **Warcraft III** | Orc Peon, Human Peasant |
| **StarCraft** | Sarah Kerrigan, Battlecruiser |
| **Portal** | GLaDOS |

---

## Prerequisites

1. **[peon-ping](https://github.com/peon-ping/peon-ping)** installed
2. Standard peon-ping packs: `peon`, `peasant`, `glados`, `sc_battlecruiser`, `sc_kerrigan`
   ```bash
   peon packs install peon,peasant,glados,sc_battlecruiser,sc_kerrigan
   ```
3. **Red Alert sound files** from games you own (see below)

---

## Getting the sound files

The sound files are **not included** in this repo — they are copyrighted assets from their respective games.

Extract them from games you own using community modding tools:

- **Red Alert 2 / Yuris Revenge**: extract `ra2.mix` / `ra2md.mix` with [XCC Mixer](https://xhp.xwis.net/utilities.php)
- **Red Alert 3**: extract audio from the game's `.big` archives with [FinalBIG](https://modenc.renegadeprojects.com/FinalBIG) or similar
- **C&C4 / Generals**: similar `.big` archive extraction

Your Red Alert sounds folder should look like this:
```
red-alert-sounds/
├── RA2/
│   ├── ra2 ally/          ← EVA ally voice lines
│   ├── ra2 soviet/        ← EVA soviet voice lines
│   └── unit/              ← unit voice clips
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

## Install

```bash
git clone https://github.com/YOUR_USERNAME/coding-is-gaming
cd coding-is-gaming
./install.sh /path/to/your/red-alert-sounds
```

The script will:
- Copy and rename all sound files into the pack
- Borrow Warcraft/SC/GLaDOS sounds from your existing peon-ping packs
- Activate the pack automatically

Verify it's working:
```bash
peon preview --list
peon preview session.start
```

---

## How it works

Each of the 7 peon-ping events maps to a pool of sounds. On every trigger, the engine picks one at random (never playing the same sound twice in a row).

The mapping logic follows game semantics:
- **Select responses** (`se*`, `VoiSel*`) → `input.required` — unit is being called on
- **Move/attack responses** (`mo*`, `at*`, `VoiMov*`, `VoiAtk*`) → `task.acknowledge` — unit is executing orders
- **Create/ready responses** (`cr*`, `rea*`, `VoiCre*`) → `session.start` — unit just spawned
- **Death/fear responses** (`VoiDie*`, `VoiFear*`, `fe*`) → `task.error` — something went wrong
- **Pissed/dialog responses** (`dia*`) → `user.spam` — unit has had enough

---

## License

This project (the installer script and openpeon.json manifest) is MIT licensed.

The sound files themselves belong to their respective copyright holders (EA Games, Blizzard Entertainment, Valve). Use them only if you own the original games.

---

*Inspired by the idea that writing code and commanding an army feel exactly the same.*
