#!/bin/bash

# Parse git label for Travis CI metadata

set -x

# Check environment
[ -z "$TRAVIS_COMMIT_MESSAGE" ] && echo "ERROR: TRAVIS_COMMIT_MESSAGE must be set" >&2 && exit 1
[ -z "$TRAVIS_PULL_REQUEST" ] && echo "ERROR: TRAVIS_PULL_REQUEST must be set" >&2 && exit 1

[ "$TRAVIS_PULL_REQUEST" = "false" ] && echo 0 && exit 0

[[ "$#" -le 0 || "$#" -gt 1 ]] && echo "ERROR: INCORRECT ARGUMENT NUMBER PROVIDED" >&2 && exit 1

PR_URL="https://api.github.com/repos/systemd/systemd/issues/$TRAVIS_PULL_REQUEST"

PR_LABEL_URL="$PR_URL/labels"

_has_label=0
# Check for coverity label
declare -a labels=$(curl -s $PR_LABEL_URL | jq -r '.[] | .name' 2>/dev/null)

for label in ${labels[@]}; do
	if [[ "${label,,}" = "${1,,}" ]]; then
		_has_label=1
		break
	fi

done

echo $_has_label
