#!/bin/bash

set -e -x

git init

$IT add "$REPOS/sub1" sub1
$IT add "$REPOS/sub2" sub2
$IT init

cat >EXPECTED <<EOF
sub1-1
sub1-2
sub1-3
sub2-1
sub2-2
sub2-3
EOF

$IT cmd ls | sort >GOT

cmp GOT EXPECTED
