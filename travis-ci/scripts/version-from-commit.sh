#!/bin/bash

# Parse commit message if custom Fedora version should be ran

[ -z "$TRAVIS_COMMIT" ] && echo "ERROR: TRAVIS_COMMIT must be set" >&2 && exit 1

grep -oP '(?<=\[fedora:)(.*)(?=\])' <<< $TRAVIS_COMMIT
