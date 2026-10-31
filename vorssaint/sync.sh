#!/usr/bin/env bash
# Vorssaint keeps its settings in a cfprefsd-managed plist, which can't be symlinked
# (cfprefsd caches it and replaces the file on write). Export/import with `defaults` instead.
#   ./sync.sh export   # mac -> repo
#   ./sync.sh import   # repo -> mac (quit Vorssaint first)
set -euo pipefail
DOMAIN=com.vorssaint.utils
FILE="$(cd "$(dirname "$0")" && pwd)/$DOMAIN.plist"

# usage history, window state and other per-machine noise
SKIP_KEYS=(
  NSNavPanelExpandedSizeForOpenMode NSOSPLastRootDirectory
  commandBarUsage commandBarQueryHabits commandBarQueryHabitKey
  keepAwakeUntilTime settingsWindowHeight settingsWindowWidth shelfItems
  bluetoothSleepRestorePending
)

case "${1:-}" in
  export)
    defaults export "$DOMAIN" "$FILE"
    for k in "${SKIP_KEYS[@]}"; do /usr/libexec/PlistBuddy -c "Delete :$k" "$FILE" 2>/dev/null || true; done
    plutil -convert xml1 "$FILE"
    echo "exported to $FILE"
    ;;
  import)
    if pgrep -xq Vorssaint; then echo "quit Vorssaint first"; exit 1; fi
    defaults import "$DOMAIN" "$FILE"
    echo "imported, start Vorssaint"
    ;;
  *) echo "usage: $0 export|import"; exit 1 ;;
esac
