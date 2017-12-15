#!/bin/bash

# Parse commit message if custom Fedora version should be ran

[ -z "$TRAVIS_COMMIT_MESSAGE" ] && echo "ERROR: TRAVIS_COMMIT_MESSAGE must be set" >&2 && exit 1

META_CMDS=`grep -oP '(?<=\[ci )(.*)(?=\])' <<< $TRAVIS_COMMIT_MESSAGE`

for meta in ${META_CMDS}; do
	case "${meta,,}" in
		fedora*)

			FEDORA_VERSION=${meta#*:}

			declare -a FEDORA_WHITELIST=(25 26 27 latest rawhide)

			for ver in ${FEDORA_WHITELIST[@]}; do
				[[ $ver = $FEDORA_VERSION ]] && FEDORA_VERSION="$ver"
			done
			;;
		coverity)
			RUN_COVERITY=1
			;;
		clean)
			CLEAN_COMMIT_FLAG=1
			;;
	esac
done

FEDORA_VERSION=${FEDORA_VERSION:-latest}
RUN_COVERITY=${RUN_COVERITY:-0}

if [ "$#" -eq 0 ]; then
	echo "FEDORA_VERSION=$FEDORA_VERSION"
	echo "RUN_COVERITY=$RUN_COVERITY"
	exit 0
fi

for arg in "$@"; do
	printf '%s\n%s\n%s' \
		"FEDORA_VERSION=$FEDORA_VERSION" "RUN_COVERITY=$RUN_COVERITY" "CLEAN_COMMIT_FLAG=$CLEAN_COMMIT_FLAG" \
		| grep -i ${arg} | cut -d'=' -f2
done
