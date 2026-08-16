#!/usr/bin/env bash
set -euo pipefail

TARGET="ByeTunes/MusicManager/ManageBackupsView.swift"

test -f "$TARGET"
grep -Fq 'FILZA_MANAGE_BACKUPS_TYPECHECK_SPLIT' "$TARGET"
grep -Fq 'private var databaseSnapshotsSection: some View' "$TARGET"
grep -Fq 'private var playlistBackupsSection: some View' "$TARGET"
grep -Fq 'private var backupsContent: some View' "$TARGET"
grep -Fq $'var body: some View {\n        backupsContent' "$TARGET"

# Original UI/action contract must remain after the compiler-only split.
for marker in \
  'Text("DATABASE SNAPSHOTS")' \
  'restoreSnapshot(named: snap.folderName)' \
  'snapshotPendingDeletion = snap' \
  'showingRenameAlert = true' \
  'Text("PLAYLIST BACKUPS")' \
  'restorePlaylist(from: backup.fileURL)' \
  'ShareSheetHelper.share(items: [backup.fileURL])' \
  'playlistBackupPendingDeletion = backup' \
  '.navigationTitle("Manage Backups")' \
  '.sheet(isPresented: $showingImportPicker)' \
  '.alert("Delete Database Backup?"' \
  '.alert("Rename Backup"' \
  '.alert("Delete Playlist Backup?"' \
  '.alert("Restore Playlist"' \
  'if showToast {' \
  'snapshotProgressPopup'; do
  grep -Fq "$marker" "$TARGET" || {
    echo "ManageBackupsView split verification missing marker: $marker" >&2
    exit 1
  }
done

# The patch must be idempotent.
BEFORE="$(shasum -a 256 "$TARGET" | awk '{print $1}')"
bash scripts/patch-byetunes-manage-backups-typecheck.sh
AFTER="$(shasum -a 256 "$TARGET" | awk '{print $1}')"
test "$BEFORE" = "$AFTER"

echo "ManageBackupsView compiler-only split verified and idempotent"
