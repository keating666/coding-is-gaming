#!/bin/bash
# install.sh — coding-is-gaming peon-ping voice pack installer
# https://github.com/keating666/coding-is-gaming
#
# Copies the sounds listed in sources.tsv from your own sound folder into the
# peon-ping pack directory (one sub-folder per event), installs the manifest and
# rebuild.sh, and activates the pack.
#
# Prerequisites:
#   1. peon-ping installed  (https://github.com/peon-ping/peon-ping)
#   2. Your extracted game sounds laid out as described in README.md
#
# Usage:
#   ./install.sh /path/to/your/sound-folder
#   PEON_DIR=/custom/peon/dir ./install.sh /path/to/your/sound-folder

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[coding-is-gaming]${NC} $*"; }
warn()    { echo -e "${YELLOW}[warning]${NC} $*"; }
error()   { echo -e "${RED}[error]${NC} $*"; exit 1; }

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCES="$REPO_DIR/sources.tsv"
[ -f "$SOURCES" ] || error "sources.tsv not found next to install.sh"

# ── Locate peon-ping (PEON_DIR env wins; otherwise the usual install paths) ──
PEON_DIR="${PEON_DIR:-}"
if [ -z "$PEON_DIR" ]; then
    for candidate in "$HOME/.claude/hooks/peon-ping" "$HOME/.openpeon"; do
        if [ -f "$candidate/peon.sh" ]; then PEON_DIR="$candidate"; break; fi
    done
fi
[ -n "$PEON_DIR" ] && [ -f "$PEON_DIR/peon.sh" ] || error "peon-ping not found. Install it first: https://github.com/peon-ping/peon-ping"
info "Found peon-ping at: $PEON_DIR"

PACK_DIR="$PEON_DIR/packs/coding-is-gaming"

# ── Source folder ────────────────────────────────────────────────────────────
SRC_DIR="${1:-}"
if [ -z "$SRC_DIR" ]; then
    echo ""
    echo "Usage: ./install.sh /path/to/your/sound-folder"
    echo ""
    echo "Expected layout (see README.md for the full file list):"
    echo "  RA2/ra2 ally/*.wav      RA2/ra2 soviet/*.wav"
    echo "  Peon*.wav  AUTanya_*.wav  SUNatas_*.wav  itan*.wav  itap*.wav  ..."
    echo ""
    exit 1
fi
[ -d "$SRC_DIR" ] || error "Directory not found: $SRC_DIR"

# ── Copy sounds, one event folder each ───────────────────────────────────────
mkdir -p "$PACK_DIR/sounds"
info "Installing to: $PACK_DIR"
copied=0; missing=0
while IFS=$'\t' read -r event source target; do
    [ -z "$event" ] && continue
    case "$event" in \#*) continue ;; esac
    mkdir -p "$PACK_DIR/sounds/$event"
    if [ -f "$SRC_DIR/$source" ]; then
        cp "$SRC_DIR/$source" "$PACK_DIR/sounds/$event/$target"
        copied=$((copied + 1))
    else
        warn "missing: $source  (wanted for $event/$target)"
        missing=$((missing + 1))
    fi
done < "$SOURCES"
info "$copied sounds installed, $missing missing"

# ── Manifest and helper, then activate ───────────────────────────────────────
cp "$REPO_DIR/rebuild.sh" "$PACK_DIR/rebuild.sh"
chmod +x "$PACK_DIR/rebuild.sh"
if [ "$missing" -eq 0 ]; then
    cp "$REPO_DIR/openpeon.json" "$PACK_DIR/openpeon.json"
else
    # Some sources were absent: build the manifest from what actually landed,
    # so peon-ping never references a file that is not there.
    warn "building manifest from installed files only"
    "$PACK_DIR/rebuild.sh" >/dev/null
fi

info "Activating pack..."
"$PEON_DIR/peon.sh" packs use coding-is-gaming

echo ""
info "Done. Verify with:"
echo "       peon preview --list"
echo "       peon preview task.complete"
echo "Customize: edit files under $PACK_DIR/sounds/<event>/ then run $PACK_DIR/rebuild.sh"
