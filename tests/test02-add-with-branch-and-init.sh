#!/bin/bash

set -e -x

git init

test -d "$REPOS/sub1"
$IT add "$REPOS/sub1" sub1 master
$IT init
test -f sub1/sub1-3


