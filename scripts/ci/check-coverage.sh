#!/usr/bin/env sh
# Fails when the line coverage of an lcov file is below the minimum (default 90).
# Usage: bash scripts/ci/check-coverage.sh coverage/lcov.info [minimum]
# `flutter test --coverage` only lists the files a test imports, so a file no test touches
# does not lower this number; the floor guards what is tested, not what is forgotten.
set -eu
lcov="${1:?usage: check-coverage.sh coverage/lcov.info [minimum]}"
minimum="${2:-90}"
total=$(awk -F: '/^LF:/ { found += $2 } /^LH:/ { hit += $2 } END { if (found == 0) exit 1; printf "%.2f", 100 * hit / found }' "$lcov")   || { echo "no coverage data in $lcov" >&2; exit 1; }
echo "line coverage: ${total}% (minimum ${minimum}%)"
awk -v total="$total" -v minimum="$minimum" 'BEGIN { exit (total + 0 >= minimum + 0) ? 0 : 1 }' \
  || { echo "coverage below the minimum" >&2; exit 1; }
