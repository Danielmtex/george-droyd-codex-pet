#!/usr/bin/env bash
set -euo pipefail

package_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/george-droyd"
pets_dir="${CODEX_HOME:-$HOME/.codex}/pets"
destination="$pets_dir/george-droyd"

for file in pet.json spritesheet.png; do
  if [[ ! -s "$package_dir/$file" ]]; then
    printf 'Missing package file: %s\n' "$package_dir/$file" >&2
    exit 1
  fi
done

mkdir -p -- "$pets_dir"
if ! mkdir -- "$destination" 2>/dev/null; then
  if [[ -d "$destination" && ! -L "$destination" ]] &&
    cmp -s -- "$package_dir/pet.json" "$destination/pet.json" &&
    cmp -s -- "$package_dir/spritesheet.png" "$destination/spritesheet.png"; then
    printf 'George Droyd is already installed at %s\n' "$destination"
    exit 0
  fi
  printf 'Could not create %s. Check permissions or move the existing entry before retrying.\n' "$destination" >&2
  exit 1
fi

cleanup() {
  rm -f -- "$destination/pet.json" "$destination/spritesheet.png"
  rmdir -- "$destination" 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

cp -- "$package_dir/spritesheet.png" "$destination/spritesheet.png"
cp -- "$package_dir/pet.json" "$destination/pet.json"
trap - EXIT INT TERM

printf 'Installed George Droyd at %s\n' "$destination"
printf 'In the desktop app, open Settings > Pets, select Refresh, then choose George Droyd.\n'
