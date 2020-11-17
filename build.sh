#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check access to docker daemon
assert_dependency "docker"
if ! docker version &> /dev/null; then
	echo "Docker daemon is not running or you have unsufficient permissions!"
	exit -1
fi

# Steam credentials
read -e -p "Enter steam username: " STEAM_USER
read -s -p "Enter steam password: " STEAM_PW && echo ""
read -e -p "Enter steam guard code: " STEAM_GUARD

# Build the image
APP_NAME="starbound"
IMG_NAME="hetsh/$APP_NAME"
docker build \
	--build-arg STEAM_USER="$STEAM_USER" \
	--build-arg STEAM_PW="$STEAM_PW" \
	--build-arg STEAM_GUARD="$STEAM_GUARD" \
	--tag "$IMG_NAME:latest" \
	--tag "$IMG_NAME:$_NEXT_VERSION" \
	.

case "${1-}" in
	# Test with default configuration
	"--test")
		docker run \
		--rm \
		--tty \
		--interactive \
		--publish 21025:21025/tcp \
		--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
		--name "$APP_NAME" \
		"$IMG_NAME"
	;;
	# Push image to docker hub
	"--upload")
		if ! tag_exists "$IMG_NAME"; then
			docker push "$IMG_NAME:latest"
			docker push "$IMG_NAME:$_NEXT_VERSION"
		fi
	;;
esac
