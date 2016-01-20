#!/bin/bash

set -e -x

git init

test -d "$REPOS/sub1"
$IT add "$REPOS/sub1" sub1

[ "$($IT list | grep -c '^\[')" = 1 ]

$IT add "$REPOS/sub1" sub2 master

[ "$($IT list | grep -c '^\[')" = 2 ]

$IT list | fgrep '[sub1]'
$IT list | fgrep '[sub2]'

$IT rm sub1

[ "$($IT list | grep -c '^\[')" = 1 ]
