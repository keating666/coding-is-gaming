#!/bin/bash
# test.sh — coding-is-gaming test suite (unit + integration + end-to-end).
#
# Unit:        sources.tsv and openpeon.json are well-formed and agree with each other.
# Integration: install.sh copies a synthetic source tree into a throw-away peon dir
#              and activates the pack through a stub peon.sh.
# End-to-end:  with a real sound folder (SOUND_SRC, default ~/Downloads/sound) the
#              installed files are decodable audio and rebuild.sh reproduces the manifest.
#
# Usage: ./test.sh            (all suites; e2e is skipped when SOUND_SRC is absent)

set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

ok()   { PASS=$((PASS + 1)); echo "  ok   $*"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL $*"; }
# check <label> <command...>
check() { local label="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$label"; else fail "$label"; fi; }

# ── Unit: sources.tsv ────────────────────────────────────────────────────────
echo "[unit] sources.tsv"
python3 - "$REPO/sources.tsv" <<'PY' && ok "sources.tsv well-formed" || fail "sources.tsv well-formed"
import sys
events = {'session.start','task.acknowledge','task.complete','task.error','input.required','resource.limit','user.spam'}
rows = [l.rstrip('\n').split('\t') for l in open(sys.argv[1], encoding='utf-8') if l.strip() and not l.startswith('#')]
assert rows, 'no rows'
assert all(len(r) == 3 for r in rows), 'every row needs event<TAB>source<TAB>target'
assert {r[0] for r in rows} == events, 'all 7 events must be present'
targets = [r[2] for r in rows]
assert len(targets) == len(set(targets)), 'duplicate target names'
assert all(t.lower().endswith(('.wav', '.mp3')) for t in targets), 'targets must be wav/mp3'
PY

# ── Unit: openpeon.json ──────────────────────────────────────────────────────
echo "[unit] openpeon.json"
python3 - "$REPO" <<'PY' && ok "openpeon.json matches sources.tsv" || fail "openpeon.json matches sources.tsv"
import json, sys, os
repo = sys.argv[1]
m = json.load(open(os.path.join(repo, 'openpeon.json'), encoding='utf-8'))
assert m['name'] == 'coding-is-gaming' and m['cesp_version'] == '1.0'
rows = [l.rstrip('\n').split('\t') for l in open(os.path.join(repo, 'sources.tsv'), encoding='utf-8') if l.strip() and not l.startswith('#')]
expected = {f'sounds/{ev}/{tgt}' for ev, _, tgt in rows}
actual = {s['file'] for cat in m['categories'].values() for s in cat['sounds']}
assert actual == expected, f'manifest/tsv mismatch: {actual ^ expected}'
assert len(m['categories']) == 7
for ev, cat in m['categories'].items():
    assert all(s['file'].startswith(f'sounds/{ev}/') for s in cat['sounds']), f'{ev} has a sound filed under another event'
    assert all(s['label'] for s in cat['sounds']), 'empty label'
PY

# ── Integration: install.sh into a stub peon dir ─────────────────────────────
echo "[integration] install.sh"
SRC="$TMP/src"; PEON="$TMP/peon"
mkdir -p "$PEON"
cat > "$PEON/peon.sh" <<'SH'
#!/bin/bash
echo "$*" >> "$(dirname "$0")/calls.log"
SH
chmod +x "$PEON/peon.sh"
python3 - "$REPO/sources.tsv" "$SRC" <<'PY'
import sys, os, wave
tsv, src = sys.argv[1:]
for line in open(tsv, encoding='utf-8'):
    if not line.strip() or line.startswith('#'): continue
    _, source, _ = line.rstrip('\n').split('\t')
    path = os.path.join(src, source); os.makedirs(os.path.dirname(path), exist_ok=True)
    if source.lower().endswith('.wav'):
        with wave.open(path, 'wb') as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(8000); w.writeframes(b'\0' * 1600)
    else:
        open(path, 'wb').write(b'ID3' + b'\0' * 64)
PY
N_ROWS=$(grep -cv '^#' "$REPO/sources.tsv")
if PEON_DIR="$PEON" "$REPO/install.sh" "$SRC" >"$TMP/install.log" 2>&1; then ok "install.sh exits 0"; else fail "install.sh exits 0 ($(tail -1 "$TMP/install.log"))"; fi
PACK="$PEON/packs/coding-is-gaming"
N_INSTALLED=$(find "$PACK/sounds" -type f \( -name '*.wav' -o -name '*.mp3' \) 2>/dev/null | wc -l | tr -d ' ')
[ "$N_INSTALLED" = "$N_ROWS" ] && ok "all $N_ROWS sounds installed" || fail "installed $N_INSTALLED of $N_ROWS sounds"
check "manifest copied into pack"      test -f "$PACK/openpeon.json"
check "rebuild.sh copied and executable" test -x "$PACK/rebuild.sh"
check "pack activated via peon.sh"     grep -q "packs use coding-is-gaming" "$PEON/calls.log"
check "install summary printed"        grep -q "sounds installed" "$TMP/install.log"
# a missing source file must be reported and the manifest built from what landed
rm "$SRC/$(grep -v '^#' "$REPO/sources.tsv" | head -1 | cut -f2)"
PEON2="$TMP/peon2"; mkdir -p "$PEON2"; cp "$PEON/peon.sh" "$PEON2/"
PEON_DIR="$PEON2" "$REPO/install.sh" "$SRC" >"$TMP/install2.log" 2>&1 || true
check "missing source is reported"     grep -q "missing:" "$TMP/install2.log"
check "manifest rebuilt without the missing file" python3 -c "
import json,sys; m=json.load(open('$PEON2/packs/coding-is-gaming/openpeon.json'))
n=sum(len(c['sounds']) for c in m['categories'].values()); sys.exit(0 if n==$N_ROWS-1 else 1)"

# ── End-to-end: real sounds, real audio decode, manifest round trip ──────────
echo "[e2e] real sound folder"
SOUND_SRC="${SOUND_SRC:-$HOME/Downloads/sound}"
if [ -d "$SOUND_SRC" ] && command -v afinfo >/dev/null; then
    PEON3="$TMP/peon3"; mkdir -p "$PEON3"; cp "$PEON/peon.sh" "$PEON3/"
    PEON_DIR="$PEON3" "$REPO/install.sh" "$SOUND_SRC" >"$TMP/install3.log" 2>&1 && ok "install from $SOUND_SRC" || fail "install from $SOUND_SRC"
    BAD=0
    while IFS= read -r f; do afinfo "$f" >/dev/null 2>&1 || { BAD=$((BAD + 1)); echo "  undecodable: $f"; }; done \
        < <(find "$PEON3/packs/coding-is-gaming/sounds" -type f \( -name '*.wav' -o -name '*.mp3' \))
    [ "$BAD" = 0 ] && ok "every installed file decodes" || fail "$BAD files do not decode"
    "$PEON3/packs/coding-is-gaming/rebuild.sh" >/dev/null
    python3 - "$REPO/openpeon.json" "$PEON3/packs/coding-is-gaming/openpeon.json" <<'PY' && ok "rebuild.sh reproduces the manifest" || fail "rebuild.sh reproduces the manifest"
import json, sys
a, b = (json.load(open(p, encoding='utf-8')) for p in sys.argv[1:])
assert a['categories'] == b['categories'], 'categories differ'
PY
else
    echo "  skip (no $SOUND_SRC or no afinfo)"
fi

echo ""
echo "passed $PASS, failed $FAIL"
[ "$FAIL" = 0 ]
