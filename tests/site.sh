#!/bin/bash
# Checks the landing page (docs/index.html) against docs/benchmark-report.md.
# Usage: bash tests/site.sh
cd "$(dirname "$0")/.." || exit 1
page=docs/index.html report=docs/benchmark-report.md fail=0
ok()   { echo "ok   $1"; }
bad()  { echo "FAIL $1"; fail=1; }
has()  { grep -qF -- "$2" "$1" && ok "$1 has $2" || bad "$1 missing $2"; }

[[ -f $page ]] || { bad "$page exists"; exit 1; }
has $page "/plugin marketplace add SubaashNair/lean-sdlc"
has $page "/plugin install lean-sdlc@lean-sdlc"
has $page '<meta name="viewport"'
for n in 1.00 0.63 0.76 1.38 6/6 0/3 '$14.01'; do has $page "$n"; has $report "$n"; done
# Every case in the report's Cases table appears on the page.
cases=$(awk -F'|' '/^## Cases/{t=1;next} /^## /{t=0} t && NR>1 && $2 ~ /[a-z]/ && $2 !~ /Case/ {gsub(/[ *\\]/,"",$2); print $2}' $report)
for c in $cases; do has $page "$c"; done
grep -qE '<script[^>]*src=' $page && bad "no external scripts" || ok "no external scripts"
grep -qE 'href="/' $page && bad "no root-relative links" || ok "no root-relative links"
ext=$(grep -oE '(src|href)="https?://[^"]*' $page | grep -v 'https://github.com/SubaashNair/lean-sdlc')
[[ -z $ext ]] && ok "only repo links are external" || bad "external links: $ext"
# README and its eval chart.
svg=docs/evals.svg
[[ -f $svg ]] && ok "$svg exists" || bad "$svg exists"
has $svg 'xmlns="http://www.w3.org/2000/svg"'
for c in $cases; do has $svg "$c"; done
for n in "https://subaashnair.github.io/lean-sdlc/" "docs/evals.svg" 6/6 0/3 1.38; do has README.md "$n"; done
exit $fail
