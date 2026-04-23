#!/usr/bin/env bash
# Output filter for compact.sh pipe-through rules.
# Usage: command 2>&1 | compact-filter.sh <filter-name>
# Strips ANSI, deduplicates, and applies filter-specific compression.
# Preserves ALL errors and failures — only strips passing/noise lines.
set -euo pipefail

FILTER="${1:-generic}"

strip_ansi() { sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'; }
dedup_lines() {
  awk '{
    if ($0 == prev) { count++ }
    else {
      if (NR > 1 && count >= 1) print prev
      if (count > 1) printf "  [repeated %d times]\n", count
      count = 1
    }
    prev = $0
  }
  END {
    if (count >= 1) print prev
    if (count > 1) printf "  [repeated %d times]\n", count
  }'
}

filter_pytest() {
  strip_ansi | awk '
    /^FAILED/   { failures = 1; print; next }
    /^ERROR/    { failures = 1; print; next }
    /^E /       { print; next }
    /^>>/       { print; next }
    /^>/        { print; next }
    /ERRORS/    { failures = 1; print; next }
    /FAILURES/  { failures = 1; print; next }
    /^=+ (ERRORS|FAILURES|short test summary)/ { failures = 1; print; next }
    /^=+ .* passed/  { print; next }
    /^=+ .* failed/  { print; next }
    /^=+ .* error/   { print; next }
    /^_+ /      { if (failures) print; next }
    /PASSED/    { next }
    /^tests\//  && /PASSED/ { next }
    /^\.+$/     { next }
    failures    { print; next }
    /^$/        { next }
    /^collecting/ { next }
    /^plugins:/ { next }
    /^platform/ { next }
    /^cachedir/ { next }
    /^rootdir/  { next }
    /^configfile/ { next }
    { print }
  '
}

filter_test() {
  strip_ansi | awk '
    /FAIL|FAILED|ERROR|Error:|✗|✕|×|REJECTED/ { print; show = 1; next }
    /^  (at |●|✓|✗|>|Expected|Received|Difference)/ { if (show) print; next }
    /^    / { if (show) print; next }
    /PASS/ && !/PASSED/ { next }
    /^✓|✔|√/ { next }
    /Test Suites:/ { print; next }
    /Tests:/ { print; next }
    /Snapshots:/ { print; next }
    /Time:/ { print; next }
    /^$/ { if (show) { print; show = 0 }; next }
    show { print }
  '
}

filter_cargo_test() {
  strip_ansi | awk '
    /^test .* FAILED/ { print; next }
    /^failures/ { show = 1; print; next }
    /^test result:/ { print; next }
    /^---- .* stdout ----/ { show = 1; print; next }
    /^$/ && show { print; show = 0; next }
    /^test .* ok$/ { next }
    /^running [0-9]+ test/ { print; next }
    /Compiling/ { next }
    /Finished/ { next }
    /Running/ && /target/ { print; next }
    show { print }
  '
}

filter_go_test() {
  strip_ansi | awk '
    /^--- FAIL/ { print; show = 1; next }
    /^FAIL/     { print; next }
    /^--- PASS/ { next }
    /^=== RUN/  { next }
    /^ok /      { print; next }
    /^PASS$/    { print; next }
    show { print; if (/^$/) show = 0 }
  '
}

filter_lint() {
  strip_ansi | awk '
    /^[\/.].*:[0-9]+:[0-9]+/ { print; next }
    /error|warning|✖|⚠/ { print; next }
    /problems?/ { print; next }
    /^$/ { next }
    /^\s/ { print; next }
  '
}

filter_tsc() {
  strip_ansi | awk '
    /error TS[0-9]+/ { print; next }
    /Found [0-9]+ error/ { print; next }
    /^[\/.].*\([0-9]+,[0-9]+\)/ { print; next }
    /^\s/ { print; next }
  '
}

filter_cargo_build() {
  strip_ansi | awk '
    /^error/    { print; show = 1; next }
    /^warning/  { print; show = 1; next }
    /^ *-->/ { print; next }
    /Compiling/ { next }
    /Downloading/ { next }
    /Downloaded/ { next }
    /Finished/  { print; next }
    show { print; if (/^$/) show = 0 }
  '
}

filter_docker_logs() { strip_ansi | dedup_lines; }
filter_k8s_logs()    { strip_ansi | dedup_lines; }
filter_generic()     { strip_ansi | dedup_lines; }

case "$FILTER" in
  pytest)       filter_pytest ;;
  test)         filter_test ;;
  cargo-test)   filter_cargo_test ;;
  go-test)      filter_go_test ;;
  lint)         filter_lint ;;
  tsc)          filter_tsc ;;
  cargo-build)  filter_cargo_build ;;
  docker-logs)  filter_docker_logs ;;
  k8s-logs)     filter_k8s_logs ;;
  *)            filter_generic ;;
esac
