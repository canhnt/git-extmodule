#!/bin/bash

# change dir to where run.sh is
cd "$(dirname "$0")"

export IT="$PWD/../git-extmodule"

if [ -n "$*" ]
then
	tests=("$@")
else
	tests=$(ls test*.sh | sort)
fi

set -e

setup() (
	rm -rf TESTDIR TESTREPODIR
	repos='main sub1 sub2'
	mkdir TESTDIR 
	for r in main sub1 sub2; do
		(
			set -e
			mkdir -p TESTREPODIR/$r
			cd TESTREPODIR/$r
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
	done
)

runtest() (
	set -e
	PATH="$PWD:$PWD/..:$PATH" 
	export REPOS="$PWD/TESTREPODIR"
	setup >SETUP.OUT 2>&1
	cd TESTDIR
	echo "* Running test '$1'"
	if bash "$1" >RUN.OUT 2>&1 
	then
		exit 0
	else
		echo "* TEST '$1' FAILED.  OUTPUT:"
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
