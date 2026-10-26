# Coding is Gaming 🎮

**[中文](README_CN.md) | [日本語](README_JP.md) | English**

> A [peon-ping](https://github.com/peon-ping/peon-ping) voice pack: Red Alert and Warcraft voice lines for the 7 Claude Code events.

Version 2 is a curated cut. The first release threw 470 clips at you; this one keeps 38 lines that are short (under 3 seconds), unmistakable, and sorted so that each event sounds like what it means. One folder per event, one random line per trigger.

---

## What you'll hear

| Event | When it fires | Lines (examples) |
|-------|---------------|------------------|
| `session.start` | New Claude Code window | Battle control online · Kirov reporting · Natasha here · Peon "Ready to work?" |
| `task.acknowledge` | You send a message | Work work · Okie dokie · Roger that · Tanya "Move it out!" |
| `task.complete` | Claude finishes a turn | Construction complete · Unit ready · Unit promoted |
| `task.error` | A shell command fails | Unit lost · Tanya "Must resist" |
| `input.required` | Claude needs your approval or answer | Peon "What you want?" · "More work!" · Tanya "You got a target?" |
| `resource.limit` | Context about to be compacted | Insufficient funds · Low power |
| `user.spam` | Three prompts within 10 seconds | Warning: nuclear missile launched · Tanya laughing |

Sources: Red Alert 2 EVA (Allied and Soviet), Red Alert 2/3 Tanya, Red Alert 3 Natasha, the Kirov, Warcraft III Peon and Peasant.

---

## Layout

```
coding-is-gaming/
├── openpeon.json   ← manifest peon-ping reads (generated, do not hand-edit)
├── sources.tsv     ← event ⇥ source file in your sound folder ⇥ installed name
├── install.sh      ← copies the sounds, installs the manifest, activates the pack
├── rebuild.sh      ← regenerates openpeon.json from the sounds/ folders
└── test.sh         ← unit + integration + end-to-end tests
```

Installed pack:

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

The sound files are **not** in this repository; they are copyrighted game assets. `sources.tsv` lists exactly which files are expected and where they come from.

---

## Install

1. Install [peon-ping](https://github.com/peon-ping/peon-ping).
2. Put your extracted game sounds in one folder with this shape (file names as listed in `sources.tsv`):

   ```
   sound/
   ├── RA2/ra2 ally/      battle control online.wav, construction complete.wav, ...
   ├── RA2/ra2 soviet/    same 19 EVA lines, Soviet announcer
   ├── PeonYes1.wav ... PeonWhat4.wav, ready to work.wav, more work.wav   (Warcraft III)
   ├── AUTanya_*.wav, SUNatas_*.wav                                      (Red Alert 3)
   ├── itan*.wav, itap*.wav, tanya-hahahahahaha.wav, kirov-kirov reporting.wav (Red Alert 2)
   └── RogerThat.mp3, RightAwaySir.mp3
   ```

3. Run the installer:

   ```bash
   git clone https://github.com/keating666/coding-is-gaming
   cd coding-is-gaming
   ./install.sh ~/path/to/sound
   ```

   Missing files are reported, not fatal: the manifest is then built from what was actually copied.

4. Check:

   ```bash
   peon preview --list
   peon preview task.complete
   ```

---

## Customize

The pack is just seven folders. Drag files in, drag files out, rename them (the file name is the label peon-ping shows), then:

```bash
~/.openpeon/packs/coding-is-gaming/rebuild.sh
```

No restart needed; the next trigger uses the new list.

To change the curated set in this repo instead, edit `sources.tsv` and run `./rebuild.sh --tsv`, then `./test.sh`.

---

## Tests

```bash
./test.sh
```

Unit tests check `sources.tsv` and `openpeon.json`. The integration test installs into a temporary peon directory with synthetic audio. The end-to-end test runs when a real sound folder exists (`SOUND_SRC`, default `~/Downloads/sound`): every installed file must decode, and `rebuild.sh` must reproduce the committed manifest.

---

## License

Installer, manifest and scripts: MIT. Sound files belong to their copyright holders (EA, Blizzard); use them only if you own the games.
