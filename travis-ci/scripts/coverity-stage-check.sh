#!/bin/bash

# This script handles running coverity scans
#  It checks for type of job that has been ran and based on commit meta commands
#  and git labels decides whether to run coverity - this allows for real-time
#  midifications of build

# Environment check
[ -z $GITHUB_TOKEN ] && echo "ERROR: GITHUB_TOKEN environment variable has to be set" >&2 && exit 1
[ -z $TRAVIS_EVENT_TYPE ] && echo "ERROR: TRAVIS_EVENT_TYPE environment variable has to be set" >&2 && exit 1
[ -z $CI_SCRIPT_DIR ] && echo "ERROR: CI_SCRIPT_DIR environment variable has to be set" >&2 && exit 1
[ -z $TRAVIS_BUILD_NUMBER ] && echo "ERROR: TRAVIS_BUILD_NUMBER environment variable has to be set" >&2 && exit 1

# Coverity meta command in commit message and cron job guarantees coverity to run
[[ $COVERITY_COMMIT_FLAG -eq 1  || "$TRAVIS_EVENT_TYPE" = 'cron' ]] && exit 0

COVERITY_STAGE_NUMBER=5

# Otherwise allow only for pull request with coverity label
if [ "$TRAVIS_EVENT_TYPE" != 'pull' ]; then
	travis login -g $GITHUB_TOKEN  # FIXME Get systemd api token
	travis cancel "$TRAVIS_BUILD_NUMBER.$COVERITY_STAGE_NUMBER"
	exit $?
fi

# Otherwise check for coverity label
HAS_COVERITY_LABEL=$($CI_SCRIPT_DIR/has-git-label.sh coverity)

if [ $HAS_COVERITY_LABEL = 0 ]; then
	# Cancel coverity stage
	travis login -g $GITHUB_TOKEN  # FIXME Get systemd api token
	travis cancel "$TRAVIS_BUILD_NUMBER.$COVERITY_STAGE_NUMBER"
	exit $?
fi


exit 0
