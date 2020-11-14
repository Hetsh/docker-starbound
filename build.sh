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

# Build the image
APP_NAME="starbound"
IMG_NAME="hetsh/$APP_NAME"
docker build --tag "$IMG_NAME:latest" --tag "$IMG_NAME:$_NEXT_VERSION" .

case "${1-}" in
	# Test with default configuration
	"--test")
		# Set up temporary directory
		TMP_DIR=$(mktemp -d "/tmp/$APP_NAME-XXXXXXXXXX")
		add_cleanup "rm -rf $TMP_DIR"

		# Apply permissions, UID matches process user
		extract_var APP_UID "Dockerfile" "\K\d+"
		chown -R "$APP_UID":"$APP_UID" "$TMP_DIR"

		# Start the test
		extract_var DATA_DIR "Dockerfile" "\"\K[^\"]+"
		docker run \
		--rm \
		--tty \
		--interactive \
		--publish 27500:27500/udp \
		--publish 27500:27500/tcp \
		--publish 27015:27015/udp \
		--mount type=bind,source="$TMP_DIR",target="$DATA_DIR" \
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
