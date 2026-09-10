#!/usr/bin/env bash
set -euo pipefail

: "${SSH:?Set SSH}"
: "${APP_PATH:?Set APP_PATH}"
: "${SSH_APP_PATH:?Set SSH_APP_PATH}"

mkdir -p "$APP_PATH"
project_dir=$(cd "$APP_PATH" && pwd -P)
docker_dir=$(pwd -P)
if [[ "$project_dir" == "$docker_dir" ]]; then
    printf 'APP_PATH must not point to the Docker configuration directory itself.\n' >&2
    exit 1
fi

# Quote the remote path for the remote POSIX shell, including embedded apostrophes.
remote_path=$(printf '%s' "$SSH_APP_PATH" | sed "s/'/'\\\\''/g")
archive=$(mktemp)
trap 'rm -f "$archive"' EXIT
ssh "$SSH" "cd '$remote_path' && tar --exclude='.env' --exclude='docker' --exclude='.git' -czf - ." > "$archive"

# Download completely before extraction. Preserve local settings and Docker files.
exclude=(--exclude='.env' --exclude='.git' --exclude='docker')
case "$docker_dir" in
    "$project_dir"/*) exclude+=(--exclude="./${docker_dir#"$project_dir"/}") ;;
esac
tar -xzf "$archive" -C "$project_dir" "${exclude[@]}"
