#!/bin/bash

# docker-clean.sh

set -e

declare -a TAGS=()

while IFS= read -r line; do
	TAGS+=( "$line" )
done < <( curl https://registry.hub.docker.com/v2/repositories/cermakm/systemd/tags/?page=$i \
	2>/dev/null \
	| jq -r '.results[] | "Tag: " + .name + ", last update on: " + .last_updated' \
	2>/dev/null )

printf '%s\n' "${TAGS[@]}"

if [[ ${#TAGS[@]} -gt 5 ]]
then
	echo -e "\033[33;1mNumber of tags in cermakm/systemd repository exceeded 5. Cached tags should be deleted!\033[0m"
fi


# TODO delete Docker Hub

exit 0
