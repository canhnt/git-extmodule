#!/bin/bash

set -e -x

git init

test -d "$REPOS/sub1"
$IT add "$REPOS/sub1" sub1
$IT init
test -f sub1/sub1-3

(
	set -e
	cd "$REPOS/sub1"
	touch banana
	git add banana
	git commit -m "one more file"
)

$IT update

test -f sub1/banana


