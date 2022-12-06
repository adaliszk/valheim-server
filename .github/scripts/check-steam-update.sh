#!/usr/bin/env bash

GameAppId="892970"
ServerAppId="896660"
AppBranch="public"
VersionFile="steamapp-version"
BuildFile="steamapp-build"

main()
{
	local SteamData SteamLatestNews SteamVersionNews SteamDepotInfo LatestVersion CurrentBuild CachedBuild

	SteamData=$(curl -fsSL "https://api.steamcmd.net/v1/info/${ServerAppId}")
	SteamDepotInfo=$(jq ".data.\"${ServerAppId}\".depots.branches.public" <<<"${SteamData}")
	echo "${SteamDepotInfo}" >"steamapp-depot-rawdata.json" # debug data

	CurrentBuild=$(jq -r '.buildid' <<<"${SteamDepotInfo}")
	CachedBuild="${CurrentBuild}" # default for the check

	# Load the cached state
	[[ -e ${BuildFile} ]] && CachedBuild=$(cat "${BuildFile}")

	# Save the current state
	jq -r '.buildid' <<<"${SteamDepotInfo}" >"${BuildFile}"

	# Do the check
	if [[ ${CachedBuild} != "${CurrentBuild}" ]]; then
		# Get the version using the news
		SteamLatestNews=$(curl -fsSL "https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=${GameAppId}&count=10&maxlength=100&format=json")
		SteamVersionNews=$(jq '.appnews.newsitems' <<<"${SteamLatestNews}" | jq '[.[] | select(.tags != null) | select(.tags | index("patchnotes"))][0]')
		echo "${SteamVersionNews}" >"steamapp-version-rawdata.json" # debug data

		[[ $(jq -r '.title' <<<"${SteamVersionNews}") =~ ([0-9]+\.[0-9]+\.[0-9]+) ]] && LatestVersion="${BASH_REMATCH[1]}"
		echo "${LatestVersion}" >"${VersionFile}"

		echo "Version: ${LatestVersion}"
		echo "Build: ${CurrentBuild}"
	fi

	exit 0
}

usage()
{
	local ExitCode
	ExitCode=${1:-0}

	cat <<-HELP
		$0 [OPTIONS]

		A simple script to fetch depot information and compare it with already existing cached data.
		By default, it will have no output, but if there is an update, it will print out the latest
		build number and version.

		OPTIONS:
		--buildfile      Specify the generated build file [default: ${BuildFile}]
		--versionfile    Specify the generated version file [default: ${VersionFile}]
		--branch         Specify which branch do you want to use [default: ${AppBranch}]
		--help           Print usage information
	HELP

	exit "${ExitCode}"
}

# Parse the input parameters
while [[ $# -gt 0 ]]; do
	ARG=0

	[[ $1 =~ --buildfile(=| )(.*) ]] && ARG=1 && export BuildFile="${BASH_REMATCH[2]}"
	[[ $1 =~ --versionfile(=| )(.*) ]] && ARG=1 && export VersionFile="${BASH_REMATCH[2]}"
	[[ $1 =~ --branch(=| )(.*) ]] && ARG=1 && export AppBranch="${BASH_REMATCH[2]}"
	[[ $1 =~ --help ]] && ARG=1 && usage

	[[ $ARG ]] && echo -e "\nERROR: Unrecognised argument: $1\n" && usage 1

	shift
done

main
