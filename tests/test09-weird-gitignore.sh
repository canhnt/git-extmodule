#!/bin/sh

set -e -x

ign=.gitignore
orig_ign=_gitignore.orig

cat >.gitignore <<'EOF'
xizzy
'*'
'"'
\\x
white space
EOF
cp "$ign" "$orig_ign"

git init
$IT add "$REPOS/sub1" sub1
$IT init
$IT rm sub1

diff -u "$orig_ign" "$ign"
