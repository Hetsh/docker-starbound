#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Debian Stable with SteamCMD
update_image "hetsh/steamcmd" "SteamCMD" "false" "(\d+\.)+\d+-\d+"

# Starbound
MAN_ID="MANIFEST_ID" # Steam depot id for identification
MAN_REGEX="\d{17,19}"
CURRENT_SB_VERSION=$(cat Dockerfile | grep -P -o "$MAN_ID=\K$MAN_REGEX")
NEW_SB_VERSION=$(curl --silent --location "https://steamdb.info/depot/533833/" | grep -P -o "<td>\K$MAN_REGEX" | tail -n 1)
if [ "$CURRENT_SB_VERSION" != "$NEW_SB_VERSION" ]; then
	prepare_update "$MAN_ID" "Starbound" "$CURRENT_SB_VERSION" "$NEW_SB_VERSION"
	update_version "$NEW_SB_VERSION"
fi

if ! updates_available; then
	#echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi