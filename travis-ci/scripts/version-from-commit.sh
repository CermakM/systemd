#!/bin/bash

# Parse commit message if custom Fedora version should be ran

[ -z "$TRAVIS_COMMIT_MESSAGE" ] && echo "ERROR: TRAVIS_COMMIT_MESSAGE must be set" >&2 && exit 1

VERSION=`grep -oP '(?<=\[fedora:)(.*)(?=\])' <<< $TRAVIS_COMMIT_MESSAGE`

[ -e $VERSION ] && exit 0

declare -a FEDORA_WHITELIST=(25 26 27 latest rawhide)

for ver in ${FEDORA_WHITELIST[@]}
do
	[[ $ver = $VERSION ]] && echo $VERSION && exit 0
done
