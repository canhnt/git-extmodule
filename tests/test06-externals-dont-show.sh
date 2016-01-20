#!/bin/bash

set -e -x

git init

test -d "$REPOS/sub1"
$IT add "$REPOS/sub1" sub1 master
$IT init

if git status | grep -q sub1
then
	exit 1
fi

$IT rm sub1

git status | grep -q sub1
