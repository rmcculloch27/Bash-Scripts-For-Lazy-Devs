#!/bin/bash
set -euo pipefail

# Resolve the provided path; fall back to raw if realpath is missing
if command -v realpath >/dev/null 2>&1; then
  USER_INPUT="$(realpath "${1:-}")"
else
  USER_INPUT="${1:-}"
  # Expand ~ manually if present
  USER_INPUT="${USER_INPUT/#\~/$HOME}"
fi

if [[ -z "${USER_INPUT}" ]]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

if [[ -d "${USER_INPUT}" ]]; then
    echo "✓ ${USER_INPUT} is a directory."

    # Use Bash globbing instead of find/grep so we can safely handle spaces and avoid BSD find quirks
    shopt -s nullglob

    # Collect matching files (top-level only)
    screenshots=( "${USER_INPUT}"/Screenshot* )

    if ((${#screenshots[@]} > 0)); then
        DEST="${HOME}/Documents/Screenshots"
        if [[ ! -d "$DEST" ]]; then
            mkdir "$DEST"
            echo "Created directory: $DEST"
        else
            echo "Directory already exists: $DEST"
        fi

        moved=0
        for f in "${screenshots[@]}"; do
            # Only move regular files that match the pattern
            if [[ -f "$f" ]]; then
                mv -n -- "$f" "$DEST"/
                ((moved++))
            fi
        done

        echo "📸 Moved ${moved} screenshot(s) to: $DEST"
    else
        echo "No screenshots here!"
    fi

elif [[ -f "${USER_INPUT}" ]]; then
    echo "✗ ${USER_INPUT} is a file. Please specify a directory."
    exit 1
else
    echo "✗ ${USER_INPUT} is not a file or a directory."
    exit 1
fi