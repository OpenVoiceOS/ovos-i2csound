#!/bin/bash
# Lint every shell script in the repo: *.sh files plus extensionless scripts
# identified by a sh/bash shebang. The files are discovered, never listed: a
# list stops covering the repo on the day a script is added, and nobody
# re-reads it.
#
# `bash -n` runs first and on its own. shellcheck reports a parse error too,
# but it is a third-party tool at a chosen severity, and "does bash parse
# this file" is the question that matters for a script systemd runs. Keeping
# it separate means the gate still answers that question if the shellcheck
# step is ever loosened.
#
# Run locally with:
#   ./scripts/ci/run_shellcheck.sh
set -euo pipefail

cd "$(dirname "$0")/../.."

mapfile -t sh_files < <(find . -path ./.git -prune -o -name '*.sh' -print)
# The predicate is the first line of the FILE, not the first line that
# matches. `grep -rlI -m1 -E '^#!...'` anchors `^` to the start of a line, so
# any text file with a line beginning `#!` that mentions sh or bash is
# classified as a shell script: a fenced ```bash example in README.md was
# enough to hand the markdown to bash -n, which then failed on a table row
# the editor never touched. awk reads line 1 and leaves.
mapfile -t shebang_files < <(
    find . -path ./.git -prune -o -type f ! -name '*.sh' -print0 \
    | xargs -0 -r awk 'FNR==1 && /^#!.*(ba)?sh([[:space:]]|$)/ {print FILENAME}
                       FNR>1 {nextfile}' 2>/dev/null || true)

files=("${sh_files[@]}" "${shebang_files[@]}")

# This script is itself a *.sh file under the tree it scans, so it always
# finds at least itself. A count of one therefore means the discovery found
# nothing else, which is a broken gate and not a clean repo: the two scripts
# this repo ships (ovos-i2csound, install.sh) must both be in the list.
#
# The two classes are floored separately, because the union cannot see the
# entrypoint disappear. `sh_files` alone already holds this script and
# install.sh, so a union floor of 2 is met with `shebang_files` empty -- and
# the extensionless `ovos-i2csound`, the one file this gate exists for, is
# found only by the shebang scan. `grep -I` judging it binary is a realistic
# way to lose it, and with only the union floor the gate stays green.
# The class floor is necessary and not sufficient: a tree with ovos-i2csound
# absent and any other extensionless script present passes it with output
# byte-identical to a healthy run. The entrypoint is therefore named, which
# is what install.sh and i2csound.service already do.
entrypoint_found=no
for f in "${files[@]}"; do
    [ "$f" = "./ovos-i2csound" ] && entrypoint_found=yes
done

if [ "${#files[@]}" -lt 2 ] || [ "${#shebang_files[@]}" -lt 1 ] \
   || [ "$entrypoint_found" = no ]; then
    echo "discovery is broken: ${#sh_files[@]} *.sh file(s)," \
         "${#shebang_files[@]} shebang script(s)," \
         "entrypoint ./ovos-i2csound found: ${entrypoint_found}"
    printf '  %s\n' "${files[@]}"
    exit 1
fi

echo "Checking ${#sh_files[@]} *.sh files and ${#shebang_files[@]} shebang scripts"

# A syntax error means the script does not run at all.
for f in "${files[@]}"; do
    bash -n "$f"
done
echo "bash -n OK (${#files[@]} files)"

# Gate at error severity. Tighten to warning once the backlog is fixed.
shellcheck --severity=error "${files[@]}"
echo "shellcheck OK"
