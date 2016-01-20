#!/bin/sh

set -e -x

git init

$IT add "$REPOS/sub1" sub1
$IT init

(
	set -e
	cd "$REPOS/sub1"
	touch banana
	git add banana
	git commit -m banana
)

(
	cd sub1
	file=sub1-1
	test -f $file
	echo hello >$file
	git add $file
)

if $IT update; then
	echo it should have failed
	exit 1
else
	exit 0
fi


