#!/usr/bin/env bash

PROJECT=esiqveland/picnic
TAG="latest"
TUTUM_UUID="89ea94d5"
URL="https://picnic.logisk.org/version"

function usage() {
	echo "Usage: $0 [test|build|run|pull|push|redeploy <TAG>]"
	echo "	Default TAG is '${TAG}'"
}

DEFAULT="\e[39m"
GREEN="\e[92m"
RED_BACK="\e[41m"
DEFAULT_BACK="\e[49m"

function version() {
	cur=$(git rev-parse --short HEAD)
	found=$(curl -s -k ${URL})
	if [ -x "$(command -v jq)" ]; then
		found=$(echo ${found} | jq -r .GIT_REV)
	fi

	color=${RED_BACK}
	if [[ $found == *"$cur"* ]] ; then
		color=${GREEN}
	fi
	echo "deployed: $found"
	echo -e "current:  ${color}${cur}${DEFAULT}${DEFAULT_BACK}"
}

function rev_parse() {
	mkdir -p public
	rm -f public/version
	GIT_REV=$(git rev-parse --short HEAD)
	echo "Tagging with git HEAD: ${GIT_REV}"
	echo "{ \"GIT_REV\": \"${GIT_REV}\" }" >> public/version
}

function assert_clean_workdir() {
	# in liue of something better:
	if git status | grep -qF 'working directory clean' ; then
		echo "All ready, working dir is clean."
	else
		echo -e "${RED_BACK}Please clean your working dir first!${DEFAULT_BACK}"
		exit 1
	fi
}

case "$1" in
	test)
		assert_clean_workdir
		rev_parse
		./$0 build
		;;
	build)
		rev_parse
		docker build -t "${PROJECT}:${TAG}" .
		;;
	run)
		docker run -d -p 3000:80 "${PROJECT}:${TAG}"
		;;
	login) docker login -e "${DOCKER_EMAIL}" -u "${DOCKER_USER}" -p "${DOCKER_PWD}"
		;;
	pull) docker pull $PROJECT
		;;
	push)
		docker push "${PROJECT}:${TAG}"
		;;
	v) ./$0 version
		;;
	version) version
		;;
	redeploy) tutum service redeploy ${TUTUM_UUID}
		;;
	l) ./$0 logs
		;;
	logs) tutum service logs ${TUTUM_UUID}
		;;
	deathray)
		./$0 build && ./$0 push
		;;
	*) usage
		;;
esac
