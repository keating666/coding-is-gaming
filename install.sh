#!/bin/bash
# coding-is-gaming — peon-ping voice pack installer
# https://github.com/coding-is-gaming
#
# Prerequisites:
#   1. peon-ping installed  (https://github.com/peon-ping/peon-ping)
#   2. peon-ping standard packs: peon, peasant, glados, sc_battlecruiser, sc_kerrigan
#   3. Red Alert sound files extracted from your game (see README for folder structure)
#
# Usage:
#   ./install.sh /path/to/red-alert-sounds

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[coding-is-gaming]${NC} $*"; }
warn()    { echo -e "${YELLOW}[warning]${NC} $*"; }
error()   { echo -e "${RED}[error]${NC} $*"; exit 1; }

# ── Locate peon-ping ──────────────────────────────────────────────────────────
PEON_DIR=""
for candidate in \
    "$HOME/.claude/hooks/peon-ping" \
    "$HOME/.openpeon"; do
    if [ -f "$candidate/peon.sh" ]; then
        PEON_DIR="$candidate"
        break
    fi
done
[ -z "$PEON_DIR" ] && error "peon-ping not found. Install it first: https://github.com/peon-ping/peon-ping"
info "Found peon-ping at: $PEON_DIR"

PACKS_DIR="$PEON_DIR/packs"
PACK_DIR="$PACKS_DIR/coding-is-gaming"
SOUNDS_DIR="$PACK_DIR/sounds"

# ── Red Alert source directory ────────────────────────────────────────────────
RA_DIR="${1:-}"
if [ -z "$RA_DIR" ]; then
    echo ""
    echo "Usage: ./install.sh /path/to/red-alert-sounds"
    echo ""
    echo "The red-alert-sounds folder should contain subdirectories:"
    echo "  RA2/ra2 ally/     RA2/ra2 soviet/"
    echo "  RA3/ally/         RA3/soviet/       RA3/ers/"
    echo "  CC4/              CCG/speech/       CCG/audio/"
    echo "  RA2/unit/         boris/            tanya-ra2/"
    echo "  tanya-ra3/        natasha/          yuri/"
    echo ""
    exit 1
fi
[ -d "$RA_DIR" ] || error "Directory not found: $RA_DIR"

# ── Check required peon-ping packs ───────────────────────────────────────────
missing_packs=()
for p in peon peasant glados sc_battlecruiser sc_kerrigan; do
    [ -d "$PACKS_DIR/$p" ] || missing_packs+=("$p")
done
if [ ${#missing_packs[@]} -gt 0 ]; then
    warn "Missing peon-ping packs: ${missing_packs[*]}"
    warn "Install them with: peon packs install ${missing_packs[*]}"
    warn "Continuing — some sounds will be skipped."
fi

# ── Create pack directory ─────────────────────────────────────────────────────
mkdir -p "$SOUNDS_DIR"
info "Installing to: $PACK_DIR"
echo ""

copy_prefixed() {
    local src_dir="$1" prefix="$2"
    local count=0
    if [ -d "$src_dir" ]; then
        for f in "$src_dir"/*.wav "$src_dir"/*.mp3 2>/dev/null; do
            [ -f "$f" ] || continue
            cp "$f" "$SOUNDS_DIR/${prefix}$(basename "$f")"
            (( count++ )) || true
        done
    fi
    echo "  $count files  ← $src_dir"
}

copy_files() {
    local src_dir="$1"
    local count=0
    if [ -d "$src_dir" ]; then
        for f in "$src_dir"/*.wav "$src_dir"/*.mp3 2>/dev/null; do
            [ -f "$f" ] || continue
            cp "$f" "$SOUNDS_DIR/$(basename "$f")"
            (( count++ )) || true
        done
    fi
    echo "  $count files  ← $src_dir"
}

copy_voice_only() {
    # Natasha / Tanya RA3: skip weapon sound effects, keep voice lines
    local src_dir="$1" prefix="$2"
    local count=0
    if [ -d "$src_dir" ]; then
        for f in "$src_dir"/*.wav; do
            [ -f "$f" ] || continue
            fname="$(basename "$f")"
            # Skip obvious sound effects (weapon/ambient loops)
            case "$fname" in
                *paintBeam*|*paintFire*|*paintLP*|*rifle*|*bomb*|*snipe*|*pilot*| \
                *belt*|*C4*|*pistol*|*ambiLoop*|*movByLoop*) continue ;;
            esac
            cp "$f" "$SOUNDS_DIR/${prefix}${fname}"
            (( count++ )) || true
        done
    fi
    echo "  $count files  ← $src_dir"
}

copy_warcraft_pack() {
    local pack="$1" prefix="$2"
    local src="$PACKS_DIR/$pack/sounds"
    local count=0
    if [ -d "$src" ]; then
        for f in "$src"/*.wav "$src"/*.mp3 2>/dev/null; do
            [ -f "$f" ] || continue
            cp "$f" "$SOUNDS_DIR/${prefix}$(basename "$f")"
            (( count++ )) || true
        done
        echo "  $count files  ← peon-ping/$pack"
    else
        echo "  (skipped — peon-ping/$pack not installed)"
    fi
}

copy_ra2_unit_selected() {
    local src="$RA_DIR/RA2/unit"
    local count=0
    local selected=(
        "kirov-kirov reporting.wav"
        "tanya-hahahahahaha.wav"
        "tanya-shake it baby.wav"
        "tanya-yeah baby.wav"
        "tanya-wheres party.wav"
        "navy seal-whos your daddy.wav"
        "yuri-mind control.wav"
        "rhino-we will bury them.wav"
        "apoc-soviet power supreme.wav"
    )
    for fname in "${selected[@]}"; do
        f="$src/$fname"
        if [ -f "$f" ]; then
            cp "$f" "$SOUNDS_DIR/ra2u_${fname}"
            (( count++ )) || true
        fi
    done
    echo "  $count files  ← RA2/unit (curated)"
}

info "Copying Red Alert EVA voices..."
copy_prefixed "$RA_DIR/RA2/ra2 ally"   "ra2a_"
copy_prefixed "$RA_DIR/RA2/ra2 soviet" "ra2s_"
copy_files    "$RA_DIR/RA3/ally"
copy_files    "$RA_DIR/RA3/soviet"
copy_files    "$RA_DIR/RA3/ers"
copy_files    "$RA_DIR/CC4"
copy_prefixed "$RA_DIR/CCG/speech"     "ccgs_"
copy_prefixed "$RA_DIR/CCG/audio"      "ccga_"

echo ""
info "Copying Red Alert character voices..."
copy_files     "$RA_DIR/boris"
copy_files     "$RA_DIR/tanya-ra2"
copy_voice_only "$RA_DIR/tanya-ra3"   ""
copy_voice_only "$RA_DIR/natasha"     ""
copy_files     "$RA_DIR/yuri"
copy_ra2_unit_selected

echo ""
info "Copying peon-ping base packs (Warcraft / StarCraft / GLaDOS)..."
copy_warcraft_pack "peon"            "peon_"
copy_warcraft_pack "peasant"         "peas_"
copy_warcraft_pack "glados"          "glados_"
copy_warcraft_pack "sc_kerrigan"     "kerry_"
copy_warcraft_pack "sc_battlecruiser" "bcruis_"

echo ""
info "Installing openpeon.json..."
cp "$(dirname "$0")/openpeon.json" "$PACK_DIR/openpeon.json"

echo ""
info "Activating pack..."
"$PEON_DIR/peon.sh" packs use coding-is-gaming

echo ""
info "Done! Verify with:"
echo "       peon preview --list"
echo "       peon preview session.start"
