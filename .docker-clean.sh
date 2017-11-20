#!/bin/bash

# docker-clean.sh

NAMESPACE='repositories'
UNAME='cermakm'
UPASS='systemd'

DOCKER_REPO="$UNAME/systemd"
LIM_TAGS=5

#######

declare -a TAGS=()

# Read tags in directory
while IFS= read -r line; do
	TAGS+=( "$line" )
done < <( curl https://registry.hub.docker.com/v2/$NAMESPACE/$DOCKER_REPO/tags/?page=$i \
	2>/dev/null \
	| jq -r '.results[] | .name' \
	2>/dev/null )

NUM_TAGS=${#TAGS[@]}

#######

main() {
	print_tags
	ec=$?
	if [[ $NUM_TAGS -gt $LIM_TAGS ]]; then
		delete_tags $(get_token)
		(( ec |= $? ))
	fi

	return $ec
}

print_tags() {
	printf '%s\n' "${TAGS[@]}" >&2
	if [[ $NUM_TAGS -gt $LIM_TAGS ]]
	then
		echo -e "\033[33;1mNumber of tags in cermakm/systemd repository exceeded $LIM_TAGS. Cached tags should be deleted!\033[0m" >&2
	fi

	return $?
}

get_token() {
echo -e "\033[33;1mRetrieving token...\033[0m" >&2
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
ec=$?

echo $TOKEN
return $ec
}

delete_tags() {
	# Leave only the latest entry
	TOKEN=$1
	if [[ -z TOKEN ]]; then
		echo TOKEN was not provided 1>&2
		exit 2
	fi

	TAGS_TO_DELETE=(${TAGS[@]:1})

	for tag in ${TAGS_TO_DELETE[@]}
	do
		echo -e "\033[33;1mDeleting tag $tag...\033[0m" >&2
		curl -X DELETE -u "$UNAME:$UPASS" -H "Authorization: Bearer ${TOKEN}" "https://hub.docker.com/v2/repositories/$DOCKER_REPO/tags/$tag" | cat
	done

	return $?
}


#######

main

exit $?
