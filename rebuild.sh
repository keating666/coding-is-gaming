#!/bin/bash
# rebuild.sh — regenerate openpeon.json for a coding-is-gaming pack.
#
# Default mode scans the seven event folders under sounds/ and lists every
# wav/mp3 it finds, so customizing the pack is: drag files in or out of the
# folders, then run this script. The label shown by peon-ping is the file name
# without extension.
#
# --tsv mode builds the manifest from sources.tsv instead; it is used inside the
# repository, where sound files are not committed.
#
# Usage: ./rebuild.sh [--tsv]        (run from anywhere; acts on its own directory)

set -euo pipefail
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-folders}"
command -v python3 >/dev/null || { echo "rebuild.sh: python3 is required" >&2; exit 1; }

python3 - "$PACK_DIR" "$MODE" <<'PY'
import json, os, sys
pack_dir, mode = sys.argv[1:]
EVENTS = ['session.start', 'task.acknowledge', 'task.complete', 'task.error',
          'input.required', 'resource.limit', 'user.spam']
AUDIO = ('.wav', '.mp3', '.m4a', '.aiff')

def from_folders():
    """One list per event folder; non-audio files (e.g. .DS_Store) are ignored."""
    files = {}
    for event in EVENTS:
        folder = os.path.join(pack_dir, 'sounds', event)
        names = sorted(n for n in os.listdir(folder) if n.lower().endswith(AUDIO)) if os.path.isdir(folder) else []
        files[event] = names
    return files

def from_tsv():
    """Targets listed in sources.tsv, grouped by event."""
    files = {event: [] for event in EVENTS}
    with open(os.path.join(pack_dir, 'sources.tsv'), encoding='utf-8') as tsv:
        for line in tsv:
            if not line.strip() or line.startswith('#'):
                continue
            event, _source, target = line.rstrip('\n').split('\t')
            if event not in files:
                sys.exit(f'sources.tsv: unknown event {event!r}')
            files[event].append(target)
    return files

files = from_tsv() if mode == '--tsv' else from_folders()
manifest = {
    "cesp_version": "1.0",
    "name": os.path.basename(pack_dir),
    "display_name": "Coding is Gaming",
    "version": "2.0.0",
    "author": {"name": "keating", "url": "https://github.com/keating666/coding-is-gaming"},
    "description": "Red Alert / Warcraft voice lines for peon-ping: one folder per event, one random line per trigger.",
    "license": "MIT (manifest and scripts); sound files belong to their copyright holders",
    "language": "en",
    "categories": {
        event: {"sounds": [{"file": f"sounds/{event}/{name}", "label": os.path.splitext(name)[0]} for name in names]}
        for event, names in files.items()
    },
}
with open(os.path.join(pack_dir, 'openpeon.json'), 'w', encoding='utf-8') as out:
    json.dump(manifest, out, ensure_ascii=False, indent=2)
    out.write('\n')
for event, names in files.items():
    print(f'{event:18s} {len(names)} sounds')
PY
