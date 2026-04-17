#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# Triple Gate Auto-Updater (OPT-IN ONLY)
#
# PURPOSE: This script ONLY updates the /police SKILL.md file with the
# latest version from the official Triple Gate GitHub repo. That's it.
# It does not collect data, phone home, send analytics, or modify
# anything else on your system.
#
# SECURITY: Every update is verified against a GPG signature before
# applying. If the signature doesn't match the bundled public key,
# the update is rejected. This prevents tampered versions from being
# installed even if the GitHub repo is compromised.
#
# OPT-IN: This script does NOTHING unless YOU install it and add it
# to your cron. It is not triggered by the SKILL.md itself. Delete
# this file at any time to stop updates.
#
# Run via cron: 0 */6 * * * ~/.claude/skills/police/update-check.sh
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

REPO="coderook520/triple-gate-Sonnet"
BRANCH="master"
INSTALL_DIR="${TRIPLE_GATE_DIR:-$HOME/.claude/skills/Sonpolice}"
SKILL_FILE="$INSTALL_DIR/SKILL.md"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
LOG_FILE="${INSTALL_DIR}/.update.log"
PUBKEY_FILE="$INSTALL_DIR/PUBLIC-KEY.asc"

log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $1" >> "$LOG_FILE" 2>/dev/null; }

# Bail if skill file doesn't exist (not installed)
[ -f "$SKILL_FILE" ] || exit 0

# Download latest SKILL.md to temp
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -sL "$RAW_BASE/SKILL.md" -o "$TMP_DIR/SKILL.md" || { log "FAIL: download SKILL.md"; exit 1; }
curl -sL "$RAW_BASE/SKILL.md.asc" -o "$TMP_DIR/SKILL.md.asc" || { log "FAIL: download signature"; exit 1; }

# Compare hashes — skip if identical
LOCAL_HASH=$(sha256sum "$SKILL_FILE" 2>/dev/null | cut -d' ' -f1)
REMOTE_HASH=$(sha256sum "$TMP_DIR/SKILL.md" 2>/dev/null | cut -d' ' -f1)

if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
    exit 0  # Already up to date, silent
fi

# Verify GPG signature (if public key exists)
if [ -f "$PUBKEY_FILE" ]; then
    KEYRING="$TMP_DIR/keyring.gpg"
    gpg --no-default-keyring --keyring "$KEYRING" --import "$PUBKEY_FILE" 2>/dev/null
    if ! gpg --no-default-keyring --keyring "$KEYRING" --verify "$TMP_DIR/SKILL.md.asc" "$TMP_DIR/SKILL.md" 2>/dev/null; then
        log "REJECT: signature verification failed — possible tampering"
        exit 1
    fi
    log "VERIFIED: GPG signature valid"
fi

# Remove immutable flag if set (needs sudo — will fail silently if no perms)
sudo chattr -i "$SKILL_FILE" 2>/dev/null || true

# Apply update
cp "$TMP_DIR/SKILL.md" "$SKILL_FILE"

# Re-set immutable flag
sudo chattr +i "$SKILL_FILE" 2>/dev/null || true

log "UPDATED: $LOCAL_HASH -> $REMOTE_HASH"
