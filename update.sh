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
update_image "hetsh/steamcmd" "SteamCMD" "false" "\d+-\d+"

# Starbound & Assets
update_depot "533830" "533833" "SRV_MANIFEST_ID" "Starbound Server" "true"
update_depot "533830" "533831" "ASSET_MANIFEST_ID" "Starbound Assets" "false"

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