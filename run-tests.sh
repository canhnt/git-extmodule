#!/bin/bash

# change dir to where run.sh is
cd "$(dirname "$0")"

export IT="git extmodule"

export TESTSROOT="$PWD"
export TMPROOT="$PWD/TMP"
export REPOS="$TMPROOT"
export WORK="$TMPROOT/work"
export HOME="$WORK"

if [ -n "$*" ]
then
	tests=("$@")
else
	tests=$(ls tests/test*.sh | sort)
fi

set -e

setup() (
	rm -rf "$TMPROOT"
	mkdir -p "$WORK"
	git config --global user.email "run-tests.sh@example.com"
	git config --global user.name "Run Tests Sh"
	for r in sub1 sub2; do
		(
			REPO="$TMPROOT/$r"
			set -e
			mkdir -p "$REPO"
			cd "$REPO"
			git init
			for n in 1 2 3; do
				f="$r-$n"
				touch $f
				git add $f
				git commit -m "added $f"
			done
			git checkout -b alternate master^^
			touch alternate-$r
			git add alternate-$r
			git commit -m "added alternate-$r"
			git checkout master
		)
	done >"$WORK"/SETUP.OUT 2>&1
)

runtest() (
	set -e
	TEST="$TESTSROOT/$1"
	PATH="$PWD:$PATH"
	setup
	cd "$WORK"
	echo "* Running test '$TEST'"
	if "$TEST" >RUN.OUT 2>&1
	then
		exit 0
	else
		echo "* TEST '$TEST' FAILED.  OUTPUT:"
		echo
		cat RUN.OUT
		echo
		exit 1
	fi
)

for t in $tests
do
	runtest "$t"
done

echo "** All tests OK"
